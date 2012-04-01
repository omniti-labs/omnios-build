/* Copyright 1999-2004 The Apache Software Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Adds RotateLogs and supporting directives that allow logs to be rotated by
 * the server without having to pipe them through rotatelogs.
 *
 * RotateLogs On|Off    Enable / disable automatic log rotation. Once enabled
 *                      mod_log_rotate takes responsibility for all log output
 *                      server wide even if RotateLogs Off is subsequently
 *                      used. That means that the BufferedLogs directive that
 *                      is implemented by mod_log_config will be ignored.
 *
 * RotateLogsLocalTime  Normally the log rotation interval is based on UTC.
 *                      For example an interval of 86400 (one day) will cause
 *                      the logs to rotate at UTC 00:00. When this option is
 *                      on, log rotation is timed relative to the local time.
 *
 * RotateInterval       Set the interval in seconds for log rotation. The
 *                      default is 86400 (one day). The shortest interval that
 *                      can be specified is 60 seconds. An optional second
 *                      argument specifies an offset in minutes which is
 *                      applied to UTC (or local time if RotateLogsLocalTime
 *                      is on). For example RotateInterval 86400 60 will
 *                      cause logs to be rotated at 23:00 UTC.
 *
 * The current version of this module is available at:
 *   http://www.hexten.net/sw/mod_log_rotate/index.mhtml
 */

/* 2004/12/02 1.00      andya@apache.org    Initial release.
 */
#include "apr_anylock.h"
#include "apr_file_io.h"
#include "apr_pools.h"
#include "apr_strings.h"
#include "apr_time.h"

#include "httpd.h"
#include "http_config.h"
#include "http_log.h"
#include "ap_mpm.h"

#include "mod_log_config.h"

#ifndef APR_LARGEFILE
#define APR_LARGEFILE 0
#endif

#define INTERVAL_DEFAULT    (APR_USEC_PER_SEC * APR_TIME_C(3600) * APR_TIME_C(24))
#define INTERVAL_MIN        (APR_USEC_PER_SEC * APR_TIME_C(60))

static int xfer_flags = (APR_WRITE | APR_APPEND | APR_CREATE | APR_LARGEFILE);
static apr_fileperms_t xfer_perms = APR_OS_DEFAULT;

module AP_MODULE_DECLARE_DATA log_rotate_module;

typedef struct {
    int             enabled;        /* Rotation enabled                     */
    apr_time_t      interval;       /* Rotation interval                    */
    apr_time_t      offset;         /* Offset from midnight                 */
    int             localt;         /* Use local time instead of GMT        */
} log_options;

typedef struct {
    apr_pool_t      *pool;          /* Our working pool                     */
    const char      *fname;         /* Basename for logs without extension  */
    apr_file_t      *fd;            /* Current open log file                */
    apr_time_t      logtime;        /* Quantised time of current log file   */
    apr_anylock_t   mutex;

    log_options     st;             /* Embedded config options              */
} rotated_log;

static const char *ap_pstrftime(apr_pool_t *p, const char *format, apr_time_exp_t *tm) {
    size_t got, len = strlen(format) + 1;
    const char *fp = strchr(format, '%');
    char *buf = NULL;
    while (NULL != fp) {
        len += 10;   /* approx only, will fail if anything generates a huge expansion */
        fp = strchr(fp + 1, '%');
    }

    buf = apr_palloc(p, len);
    apr_strftime(buf, &got, len, format, tm);
    return buf;
}

static apr_file_t *ap_open_log(apr_pool_t *p, server_rec *s, const char *base, log_options *ls, apr_time_t tm) {
    if (*base == '|') {
        /* We have piped log handling here because once log rotation has been
         * enabled we become responsible for /all/ transfer log output server
         * wide. That's a consequence of the way the log output hooks in
         * mod_log_config are implemented. Unfortunately this means we have to
         * duplicate functionality from mod_log_config. Note that we don't
         * support the buffered logging mode that mlc implements.
         */
        piped_log *pl;

        if (ls->enabled) {
            /* Can't rotate a piped log */
            ls->enabled = 0;
            ap_log_error(APLOG_MARK, APLOG_WARNING, APR_SUCCESS, s,
                            "disabled log rotation for piped log %s.", base);
        }

        if (pl = ap_open_piped_log(p, base + 1), NULL == pl) {
           return NULL;
        }

        return ap_piped_log_write_fd(pl);
    } else {
        apr_file_t *fd;
        apr_status_t rv;
        const char *name = ap_server_root_relative(p, base);

        if (NULL == name) {
            ap_log_error(APLOG_MARK, APLOG_ERR, APR_EBADPATH, s,
                            "invalid transfer log path %s.", base);
            return NULL;
        }

        if (ls->enabled) {
            apr_time_t log_time = tm - ls->offset;
            if (strchr(base, '%') != NULL) {
                apr_time_exp_t e;

                apr_time_exp_gmt(&e, log_time);
                name = ap_pstrftime(p, name, &e);
            } else {
                /* Synthesize the log name using the specified time in seconds as a
                 * suffix.  We subtract the offset here because it was added when
                 * quantizing the time but we want the name to reflect the actual
                 * time when the log rotated. We don't reverse the local time
                 * adjustment because, presumably, if you've specified local time
                 * logging you want the filenames to use local time.
                 */
                name = apr_psprintf(p, "%s.%" APR_TIME_T_FMT, name, apr_time_sec(log_time));
            }
        }

        if (rv = apr_file_open(&fd, name, xfer_flags, xfer_perms, p), APR_SUCCESS != rv) {
            ap_log_error(APLOG_MARK, APLOG_ERR, rv, s,
                            "could not open transfer log file %s.", name);
            return NULL;
        }

        return fd;
    }
}

static apr_status_t ap_close_log(server_rec *s, apr_file_t *fd) {
    apr_status_t rv;

    if (rv = apr_file_close(fd), APR_SUCCESS != rv) {
        ap_log_error(APLOG_MARK, APLOG_ERR, rv, s,
                        "error closing transfer log file.");
    }

    return rv;
}

/* Quantize the supplied time to the log rotation interval applying offsets as
 * specified in the config.
 */
static apr_time_t ap_get_quantized_time(rotated_log *rl, apr_time_t tm) {
    apr_time_t localadj = 0;

    if (rl->st.localt) {
        apr_time_exp_t lt;
        apr_time_exp_lt(&lt, tm);
        localadj = (apr_time_t) lt.tm_gmtoff * APR_USEC_PER_SEC;
    }

    return ((tm + rl->st.offset + localadj) / rl->st.interval) * rl->st.interval;
}

/* Called by mod_log_config to write a log file line.
 */
static apr_status_t ap_rotated_log_writer(request_rec *r, void *handle,
                                          const char **strs, int *strl,
                                          int nelts, apr_size_t len) {
    char *str;
    char *s;
    int i;
    apr_status_t rv = 0;
    rotated_log *rl = (rotated_log *) handle;

    if (NULL != rl && NULL != rl->fd) {
        if (rl->st.enabled) {
            apr_time_t logt = ap_get_quantized_time(rl, r->request_time);
            /*ap_log_error(APLOG_MARK, APLOG_DEBUG, rv, r->server, "New: %lu, old: %lu",
            (unsigned long) logt, (unsigned long) rl->logtime);*/
            /* Decide if the quantized time has rolled over into a new slot. */
            if (logt != rl->logtime) {
                /* Get the mutex */
                if (rv = APR_ANYLOCK_LOCK(&rl->mutex), APR_SUCCESS != rv) {
                    return rv;
                }

                /* Now check again in case someone else rotated the log while we waited
                 * for the mutex.
                 */
                if (logt != rl->logtime) {
                    apr_file_t *ofd = rl->fd;
                    apr_pool_t *par, *np;
                    rl->logtime = logt;

                    /* Create a new pool to provide storage for the new file.
                     * Once we have the new file open we'll destroy the old
                     * pool and make this one current.
                     */
                    par = apr_pool_parent_get(rl->pool);
                    if (rv = apr_pool_create(&np, par), APR_SUCCESS != rv) {
                        APR_ANYLOCK_UNLOCK(&rl->mutex);
                        return rv;
                    }

                    /* Atomically replace the current log file because other
                     * threads, perhaps those responsible for a long lived
                     * request, won't have blocked on the mutex.
                     */
                    if (rl->fd = ap_open_log(np, r->server, rl->fname, &rl->st, logt), NULL == rl->fd) {
                        /* Open failed so keep going with the old log... */
                        rl->fd = ofd;
                        /* ...and destroy the new pool. */
                        apr_pool_destroy(np);
                    } else {
                        /* Close the old log... */
                        ap_close_log(r->server, ofd);
                        /* ...and switch to the new pool. */
                        apr_pool_destroy(rl->pool);
                        rl->pool = np;
                    }
                }

                APR_ANYLOCK_UNLOCK(&rl->mutex);
            }
        }

        str = apr_palloc(r->pool, len + 1);

        for (i = 0, s = str; i < nelts; ++i) {
            memcpy(s, strs[i], strl[i]);
            s += strl[i];
        }

        rv = apr_file_write(rl->fd, str, &len);

        return rv;
    } else {
        return APR_SUCCESS; /* Should we complain? */
    }
}

/* Called my mod_log_config to initialise a log writer.
 */
static void *ap_rotated_log_writer_init(apr_pool_t *p, server_rec *s, const char* name) {
    rotated_log *rl;
    apr_status_t rv;
    log_options *ls = ap_get_module_config(s->module_config, &log_rotate_module);

    rl = apr_palloc(p, sizeof(rotated_log));
    rl->fname = apr_pstrdup(p, name);

    if (rv = apr_pool_create(&rl->pool, p), APR_SUCCESS != rv) {
        ap_log_error(APLOG_MARK, APLOG_ERR, rv, s, "can't make log rotation pool.");
        return NULL;
    }

    rl->mutex.type = apr_anylock_none;

#if APR_HAS_THREADS
    {
        int mpm_threads;

        ap_mpm_query(AP_MPMQ_MAX_THREADS, &mpm_threads);
        if (mpm_threads > 1) {
            apr_status_t rv;

            rl->mutex.type = apr_anylock_threadmutex;
            rv = apr_thread_mutex_create(&rl->mutex.lock.tm, APR_THREAD_MUTEX_DEFAULT, p);
            if (rv != APR_SUCCESS) {
                ap_log_error(APLOG_MARK, APLOG_CRIT, rv, s,
                        "could not initialize log rotation mutex, "
                        "transfer log may become corrupted");
                rl->mutex.type = apr_anylock_none;
            }
        }
    }
#endif

    rl->st          = *ls;
    rl->logtime     = ap_get_quantized_time(rl, apr_time_now());

    if (rl->fd = ap_open_log(rl->pool, s, rl->fname, &rl->st, rl->logtime), NULL == rl->fd) {
        return NULL;
    }

    return rl;
}

static const char *set_rotated_logs(cmd_parms *cmd, void *dummy, int flag) {
    log_options *ls = ap_get_module_config(cmd->server->module_config, &log_rotate_module);
    if (flag) {
        /* Always hook the writer functions when we're enabled even if we've
         * done it already. We can't unhook which means that once we've been
         * enabled we become responsible for all transfer log output. Note that
         * a subsequent BufferedLogs On in conf will clobber these hooks and
         * disable us.
         */
        APR_OPTIONAL_FN_TYPE(ap_log_set_writer_init) *set_writer_init;
        APR_OPTIONAL_FN_TYPE(ap_log_set_writer)      *set_writer;

        set_writer_init = APR_RETRIEVE_OPTIONAL_FN(ap_log_set_writer_init);
        set_writer      = APR_RETRIEVE_OPTIONAL_FN(ap_log_set_writer);

        if (NULL != set_writer_init && NULL != set_writer) {
            set_writer_init(ap_rotated_log_writer_init);
            set_writer(ap_rotated_log_writer);
            ls->enabled = 1;
        } else {
            ap_log_error(APLOG_MARK, APLOG_ERR, APR_SUCCESS, cmd->server,
                    "can't install log rotator - ap_log_set_writer not available");
            ls->enabled = 0;
        }
    } else {
        ls->enabled = 0;
    }

    return NULL;
}

static const char *set_localtime(cmd_parms *cmd, void *dummy, int flag) {
    log_options *ls = ap_get_module_config(cmd->server->module_config, &log_rotate_module);
    ls->localt = flag;
    return NULL;
}

static const char *set_interval(cmd_parms *cmd, void *dummy,
                                const char *inte, const char *offs) {
    log_options *ls = ap_get_module_config(cmd->server->module_config, &log_rotate_module);
    if (NULL != inte) {
        /* Interval in seconds */
        ls->interval = APR_USEC_PER_SEC * (apr_time_t) atol(inte);
        if (ls->interval < INTERVAL_MIN) {
            ls->interval = INTERVAL_MIN;
        }
    }

    if (NULL != offs) {
        /* Offset in minutes */
        ls->offset = APR_USEC_PER_SEC * 60 * (apr_time_t) atol(offs);
    }

    return NULL;
}

static const command_rec rotate_log_cmds[] = {
    AP_INIT_FLAG(  "RotateLogs", set_rotated_logs, NULL, RSRC_CONF,
                   "Enable rotated logging"),
    AP_INIT_FLAG(  "RotateLogsLocalTime", set_localtime, NULL, RSRC_CONF,
                   "Rotate relative to local time"),
    AP_INIT_TAKE12("RotateInterval", set_interval, NULL, RSRC_CONF,
                   "Set rotation interval in seconds with"
                   " optional offset in minutes"),
    {NULL}
};

static void *make_log_options(apr_pool_t *p, server_rec *s) {
    log_options *ls;

    ls = (log_options *) apr_palloc(p, sizeof(log_options));
    ls->enabled     = 1;
    ls->interval    = INTERVAL_DEFAULT;
    ls->offset      = 0;
    ls->localt      = 0;

    return ls;
}

static void *merge_log_options(apr_pool_t *p, void *basev, void *addv) {
    log_options *base = (log_options *) basev;
    log_options *add  = (log_options *) addv;

    *add = *base;

    return add;
}

module AP_MODULE_DECLARE_DATA log_rotate_module = {
    STANDARD20_MODULE_STUFF,
    NULL,                       /* create per-dir config */
    NULL,                       /* merge per-dir config */
    make_log_options,           /* server config */
    merge_log_options,          /* merge server config */
    rotate_log_cmds,            /* command apr_table_t */
    NULL                        /* register hooks */
};

