#!/usr/bin/bash
#
# {{{ CDDL HEADER START
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
# CDDL HEADER END }}}
#
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=ooceapps
VER=0.4.0
VERHUMAN=$VER
PKG=ooce/ooceapps
SUMMARY="Web integrations for OmniOSce"
DESC=$SUMMARY
BUILDARCH=64
PREFIX=/opt/ooce
MIRROR="https://github.com/omniosorg/$PROG/releases/download"

RUN_DEPENDS_IPS="runtime/perl-64 ooce/application/texlive"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

reset_configure_opts

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
"

add_extra_files() {
    # copy config template
    logcmd mkdir -p $DESTDIR/var/$PREFIX
    logcmd cp $DESTDIR/etc/$PREFIX/$PROG.conf.dist \
        $DESTDIR/etc/$PREFIX/$PROG.conf \
        || logerr "--- cannot copy config file template"
}

init
download_source "v$VER" $PROG $VER
patch_source
prep_build
build
add_extra_files
install_smf network ooceapps.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
