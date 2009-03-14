# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/nvidia-cg-toolkit/nvidia-cg-toolkit-2.1.0017.ebuild,v 1.1 2009/03/01 21:31:51 vapier Exp $

inherit versionator multilib

MY_PV="$(get_version_component_range 1-2)"
MY_DATE="February2009"
DESCRIPTION="NVIDIA's C graphics compiler toolkit"
HOMEPAGE="http://developer.nvidia.com/object/cg_toolkit.html"
X86_URI="http://developer.download.nvidia.com/cg/Cg_${MY_PV}/${PV}/Cg-${MY_PV}_${MY_DATE}_x86.tgz"
SRC_URI="x86? ( ${X86_URI} )
	amd64? ( http://developer.download.nvidia.com/cg/Cg_${MY_PV}/${PV}/Cg-${MY_PV}_${MY_DATE}_x86_64.tgz )"

LICENSE="NVIDIA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="strip"

DEPEND="virtual/glut"
if has_multilib_profile; then
	DEPEND="${DEPEND} amd64? ( app-emulation/emul-linux-x86-xlibs )"
	SRC_URI="${SRC_URI} amd64? ( ${X86_URI} )"
fi
RDEPEND="${DEPEND}"

S=${WORKDIR}

DEST=/opt/${PN}

src_install() {
	into ${DEST}
	dobin usr/bin/cgc || die
	dosym ${DEST}/bin/cgc /opt/bin/cgc || die

	exeinto ${DEST}/lib
	if use x86 ; then
		doexe usr/lib/* || die
	elif use amd64 ; then
		doexe usr/lib64/* || die
		if has_multilib_profile; then
			ABI="x86" dolib usr/lib/*
		fi
	fi

	doenvd "${FILESDIR}"/80cgc-opt

	insinto ${DEST}/include/Cg
	doins usr/include/Cg/*

	insinto ${DEST}/man/man3
	doins usr/share/man/man3/*

	insinto ${DEST}
	doins -r usr/local/Cg/{docs,examples,README}
}

pkg_postinst() {
	einfo "Starting with ${CATEGORY}/${PN}-2.1.0016, ${PN} is installed in"
	einfo "${DEST}.  Packages might have to add something like:"
	einfo "  append-cppflags -I${DEST}/include"
}
