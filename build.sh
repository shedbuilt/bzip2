#!/bin/bash
case "$SHED_BUILDMODE" in
    toolchain)
        make -j $SHED_NUMJOBS || return 1
        make PREFIX="${SHED_FAKEROOT}/tools" install || return 1
        ;;
    *)
        patch -Np1 -i "${SHED_PATCHDIR}/bzip2-1.0.6-install_docs-1.patch"
        sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
        sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
        make -j $SHED_NUMJOBS -f Makefile-libbz2_so || return 1
        make clean
        make -j $SHED_NUMJOBS || return 1
        make PREFIX="${SHED_FAKEROOT}/usr" install || return 1
        mkdir -pv ${SHED_FAKEROOT}/{bin,lib}
        cp -v bzip2-shared ${SHED_FAKEROOT}/bin/bzip2
        cp -av libbz2.so* ${SHED_FAKEROOT}/lib
        ln -sv ../../lib/libbz2.so.1.0 ${SHED_FAKEROOT}/usr/lib/libbz2.so
        rm -v ${SHED_FAKEROOT}/usr/bin/{bunzip2,bzcat,bzip2}
        ln -sv bzip2 ${SHED_FAKEROOT}/bin/bunzip2
        ln -sv bzip2 ${SHED_FAKEROOT}/bin/bzcat
        ;;
esac
