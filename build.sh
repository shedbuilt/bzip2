#!/bin/bash
case "$SHED_BUILD_MODE" in
    toolchain)
        make -j $SHED_NUM_JOBS && \
        make PREFIX="${SHED_FAKE_ROOT}/tools" install || exit 1
        rm -v "${SHED_FAKE_ROOT}"/tools/bin/{bzcmp,bzegrep,bzfgrep,bzless}
        ln -sv bzdiff "${SHED_FAKE_ROOT}/tools/bin/bzcmp"
        ln -sv bzgrep "${SHED_FAKE_ROOT}/tools/bin/bzegrep"
        ln -sv bzgrep "${SHED_FAKE_ROOT}/tools/bin/bzfgrep"
        ln -sv bzmore "${SHED_FAKE_ROOT}/tools/bin/bzless"
        ;;
    *)
        patch -Np1 -i "${SHED_PKG_PATCH_DIR}/bzip2-1.0.6-install_docs-1.patch"
        sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
        sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
        make -j $SHED_NUM_JOBS -f Makefile-libbz2_so || return 1
        make clean
        make -j $SHED_NUM_JOBS || return 1
        make PREFIX="${SHED_FAKE_ROOT}/usr" install || return 1
        mkdir -pv "${SHED_FAKE_ROOT}"/{bin,lib}
        cp -v bzip2-shared "${SHED_FAKE_ROOT}/bin/bzip2"
        cp -av libbz2.so* "${SHED_FAKE_ROOT}/lib"
        ln -sv ../../lib/libbz2.so.1.0 "${SHED_FAKE_ROOT}/usr/lib/libbz2.so"
        rm -v "${SHED_FAKE_ROOT}"/usr/bin/{bunzip2,bzcat,bzip2}
        ln -sv bzip2 "${SHED_FAKE_ROOT}/bin/bunzip2"
        ln -sv bzip2 "${SHED_FAKE_ROOT}/bin/bzcat"
        ;;
esac
