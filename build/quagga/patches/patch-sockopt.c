diff --git a/lib/sockopt.c b/lib/sockopt.c
index be22827..545a66d 100644
--- a/lib/sockopt.c
+++ b/lib/sockopt.c
@@ -20,6 +20,11 @@
  */
 
 #include <zebra.h>
+
+#ifdef SUNOS_5
+#include <ifaddrs.h>
+#endif
+
 #include "log.h"
 #include "sockopt.h"
 #include "sockunion.h"
@@ -339,6 +344,35 @@ setsockopt_ipv4_multicast_if(int sock,
   m.s_addr = htonl(ifindex);
 
   return setsockopt (sock, IPPROTO_IP, IP_MULTICAST_IF, (void *)&m, sizeof(m));
+#elif defined(SUNOS_5)
+  char ifname[IF_NAMESIZE];
+  struct ifaddrs *ifa, *ifap;
+  struct in_addr ifaddr;
+
+  if (if_indextoname(ifindex, ifname) == NULL)
+    return -1;
+
+  if (getifaddrs(&ifa) != 0)
+    return -1;
+
+  for (ifap = ifa; ifap != NULL; ifap = ifap->ifa_next)
+    {
+      struct sockaddr_in *sa;
+
+      if (strcmp(ifap->ifa_name, ifname) != 0)
+        continue;
+      if (ifap->ifa_addr->sa_family != AF_INET)
+        continue;
+      sa = (struct sockaddr_in*)ifap->ifa_addr;
+      memcpy(&ifaddr, &sa->sin_addr, sizeof(ifaddr));
+      break;
+    }
+
+  freeifaddrs(ifa);
+  if (!ifap) /* This means we did not find an IP */
+    return -1;
+
+  return setsockopt(sock, IPPROTO_IP, IP_MULTICAST_IF, (void *)&ifaddr, sizeof(ifaddr));
 #else
   #error "Unsupported multicast API"
 #endif
-- 
1.7.10.4
