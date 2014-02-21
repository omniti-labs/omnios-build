--- psycopg2-2.4.5/psycopg/config.h.orig	Wed Mar 28 21:09:15 2012
+++ psycopg2-2.4.5/psycopg/config.h	Tue Sep 11 15:31:27 2012
@@ -141,25 +141,11 @@
 #endif
 #endif
 
-#if (defined(__FreeBSD__) && __FreeBSD_version < 503000) || (defined(_WIN32) && !defined(__GNUC__)) || defined(__sun__) || defined(sun)
-/* what's this, we have no round function either? */
-static double round(double num)
-{
-  return (num >= 0) ? floor(num + 0.5) : ceil(num - 0.5);
-}
-#endif
-
 /* postgresql < 7.4 does not have PQfreemem */
 #ifndef HAVE_PQFREEMEM
 #define PQfreemem free
 #endif
 
-/* resolve missing isinf() function for Solaris */
-#if defined (__SVR4) && defined (__sun)
-#include <ieeefp.h>
-#define isinf(x) (!finite((x)) && (x)==(x))
-#endif
-
 /* decorators for the gcc cpychecker plugin */
 #if defined(WITH_CPYCHECKER_RETURNS_BORROWED_REF_ATTRIBUTE)
 #define BORROWED \
