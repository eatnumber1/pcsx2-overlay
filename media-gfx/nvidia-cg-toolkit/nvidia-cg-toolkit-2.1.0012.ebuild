# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/nvidia-cg-toolkit/nvidia-cg-toolkit-2.1.0012.ebuild,v 1.3 2008/12/22 20:45:48 maekke Exp $

inherit versionator multilib

MY_PV="$(get_version_component_range 1-2)"
MY_DATE="October2008"
DESCRIPTION="nvidia's c graphics compiler toolkit"
HOMEPAGE="http://developer.nvidia.com/object/cg_toolkit.html"
X86_URI="http://developer.download.nvidia.com/cg/Cg_2.0/${PV}/Cg-${MY_PV}_${MY_DATE}_x86.tgz"
SRC_URI="x86? (
	${X86_URI} )
	amd64? (
	http://developer.download.nvidia.com/cg/Cg_2.0/${PV}/Cg-${MY_PV}_${MY_DATE}_x86_64.tgz
	multilib? ( ${X86_URI} ) )"

LICENSE="NVIDIA"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""
RESTRICT="strip"

if has_multilib_profile && use amd64; then
	DEPEND="app-emulation/emul-linux-x86-xlibs"
else
	DEPEND="virtual/glut"
fi
RDEPEND="virtual/glut"

S="${WORKDIR}"

src_install() {
	dobin usr/bin/cgc

	if use x86; then
		dolib usr/lib/*
	elif use amd64; then
		dolib usr/lib64/*
		if has_multilib_profile; then
			local abi_save="${ABI}"
			ABI="x86"
			dolib usr/lib/* || die
			ABI="${abi_save}"
		fi
	fi

	doenvd "${FILESDIR}"/80cgc

	insinto /usr/include/Cg
	doins usr/include/Cg/*

	doman 	usr/share/man/man3/*

	dodoc usr/local/Cg/MANIFEST usr/local/Cg/README \
	      usr/local/Cg/docs/*.pdf usr/local/Cg/docs/CgReferenceManual.chm

	docinto html
	dohtml	usr/local/Cg/docs/html/*

	docinto examples
	dodoc   usr/local/Cg/examples/README

	docinto include/GL
	dodoc   usr/local/Cg/include/GL/*

	# Copy all the example code.
	cd usr/local/Cg/examples
	insinto /usr/share/doc/${PF}/examples
	doins Makefile
	for dir in $(find * -type d) ; do
		insinto usr/share/doc/${PF}/examples/"${dir}"
		doins "${dir}"/*
	done
}
