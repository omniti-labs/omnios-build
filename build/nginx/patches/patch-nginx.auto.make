diff -ur nginx-1.2.6.pristine/auto/make nginx-1.2.6/auto/make
--- nginx-1.2.6.pristine/auto/make	2012-11-12 18:39:51.000000000 +0000
+++ nginx-1.2.6/auto/make	2013-01-19 23:18:02.101674418 +0000
@@ -22,7 +22,7 @@
 CC =	$CC
 CFLAGS = $CFLAGS
 CPP =	$CPP
-LINK =	$LINK
+LINK =	$LINK $CFLAGS
 
 END
 
