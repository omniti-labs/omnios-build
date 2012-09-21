--- clearsilver-0.10.5.orig/python/Makefile	Thu Jul 13 06:51:49 2006
+++ clearsilver-0.10.5/python/Makefile	Tue Sep 18 17:44:41 2012
@@ -25,7 +25,7 @@
 
 $(NEO_UTIL_SO): setup.py $(NEO_UTIL_SRC) $(DEP_LIBS)
 	rm -f $(NEO_UTIL_SO)
-	CC="$(CC)" LDSHARED="$(LDSHARED)" $(PYTHON) setup.py build_ext --inplace
+	CC="$(CC)" LDSHARED="$(LDSHARED) $(LDFLAGS)" $(PYTHON) setup.py build_ext --inplace
 
 OLD_NEO_UTIL_SO:
 	$(LDSHARED) -o $@ $(LDFLAGS) $(NEO_UTIL_OBJ) $(LIBS)
