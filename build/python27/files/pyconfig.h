/*
 * This file and its contents are supplied under the terms of the
 * Common Development and Distribution License ("CDDL"), version 1.0.
 * You may only use this file in accordance with the terms of version
 * 1.0 of the CDDL.
 *
 * A full copy of the text of the CDDL should have accompanied this
 * source.  A copy of the CDDL is also available via the Internet at
 * http://www.illumos.org/license/CDDL.
 */

/*
 * Copyright 2016 OmniTI Computer Consulting, Inc.
 */

/* Python2.7 doesn't understand it can be a dual 32/64-bit binary on OmniOS. */

#ifdef _LP64
#include <python2.7/pyconfig-64.h>
#else
#include <python2.7/pyconfig-32.h>
#endif
