#!/bin/sh

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
