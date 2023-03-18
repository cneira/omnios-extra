#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=cups
VER=2.4.2
PKG=ooce/print/cups
SUMMARY="Common UNIX Printing System"
DESC="Standards-based, open source printing system for UNIX operating systems"

[ $RELVER -ge 151041 ] && set_clangver

# getpwuid_r
set_standard XPG6

OPREFIX=$PREFIX
PREFIX+="/$PROG"
VARDIR="/var$PREFIX"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$OPREFIX
    --includedir=$OPREFIX/include
    --localstatedir=$VARDIR
    --with-logdir=/var/log$PREFIX
    --with-domainsocket=$VARDIR/run/cups
    --with-smfmanifestdir=/lib/svc/manifest/application
    --with-cups-user=lp
    --with-cups-group=lp
    --enable-debug
    --disable-static
    --without-bundledir
    --without-icondir
    --without-menudir
    --without-rcdir
    --without-dnssd
    --without-systemd
    --without-python
    --without-php
    --without-java
"
# cups only supports openssl 3+
[ $RELVER -lt 151041 ] && CONFIGURE_OPTS+=" --with-tls=gnutls"

# cups uses libusb_get_device_list to enumerate devices
# this currently fails in zones as it uses libdevinfo
CONFIGURE_OPTS+=" --disable-libusb"

CONFIGURE_OPTS[i386]="
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --libdir=$OPREFIX/lib/amd64
"

LDFLAGS[i386]+=" -L$OPREFIX/lib -Wl,-R$OPREFIX/lib -lsocket"
LDFLAGS[amd64]+=" -L$OPREFIX/lib/amd64 -Wl,-R$OPREFIX/lib/amd64 -lsocket"

pre_configure() {
    typeset arch=$1

    export DSOFLAGS="$LDFLAGS ${LDFLAGS[$arch]}"
}

init
download_source $PROG $PROG $VER-source
patch_source
prep_build
run_autoconf -f
build
strip_install
VER=${VER//op/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
