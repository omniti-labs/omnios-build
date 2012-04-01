#!/bin/sh
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Use is subject to license terms.
#

CFILE=/tmp/makeisa.$$.c

DPATH=$1
BIN=$2
echo "Making isaexec wrapper for $DPATH/$BIN"
cat > $CFILE << EOF
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <sys/systeminfo.h>
#include <string.h>
#include <stdio.h>

int
main(int argc, char *argv[], char *envp[]) {
  char path[PATH_MAX], *p, *isalist;
  char isabuf[PATH_MAX];
  char trypath[PATH_MAX];
  char *bin, *is;
  ssize_t s;

  if ((isalist = getenv("ISALIST")) == NULL) {
    int x;
    x = sysinfo(SI_ISALIST, isabuf, sizeof(isabuf));
    if (x == -1 || x > sizeof(isabuf)) {
      return 2;
    }
  } else {
    /* copy it, as we're going to strtok */
    strcpy(isabuf, isalist);
  }
  isalist = isabuf;

  snprintf(path, sizeof(path), "/proc/%u/path/a.out", getpid());
  s = readlink(path, trypath, sizeof(trypath));
  if (s >= 0) {
	  trypath[s] = '\0';
  } else {
	  trypath[0] = '\0';
  }
  if((s == -1) ||
     (p = realpath(trypath, path)) == NULL) {
    strcpy(path, "$DPATH/$BIN");
    p = path;
  }

  /* crack the path into dir and name */
  bin = strrchr(p, '/');
  if (!bin) {
    return 1;
  }

  *bin = '\0';
  bin++;

  is = strtok(isalist, " ");
  while (is) {
    snprintf(trypath, sizeof(trypath), "%s/%s/%s", p, is, bin);
    if (0 == access(trypath, X_OK)) {
      return execve(trypath, argv, envp);
    }
   
    is = strtok(NULL, " ");
  }
  
  return 1;
}
EOF

$CC -o $BIN $CFILE
rm $CFILE
