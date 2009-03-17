# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator multilib

MY_PV="$(get_version_component_range 1-2)"
MY_DATE="October2008"
DESCRIPTION="nvidia's c graphics compiler toolkit"
HOMEPAGE="http://developer.nvidia.com/object/cg_toolkit.html"
X86_URI="http://developer.download.nvidia.com/cg/Cg_2.0/${PV}/Cg-${MY_PV}_${MY_DATE}_x86.tgz"
# Doesn't work for some reason
#SRC_URI="x86? ( ${X86_URI} )
#	amd64? ( http://developer.download.nvidia.com/cg/Cg_2.0/${PV}/Cg-${MY_PV}_${MY_DATE}_x86_64.tgz )"
SRC_URI="x86? ( ${X86_URI} )
	amd64? (
		http://developer.download.nvidia.com/cg/Cg_2.0/${PV}/Cg-${MY_PV}_${MY_DATE}_x86_64.tgz
		multilib? ( ${X86_URI} )
	)"

LICENSE="NVIDIA"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="multilib"
#IUSE=""
RESTRICT="strip"

DEPEND="virtual/glut
	multilib? ( amd64? ( app-emulation/emul-linux-x86-xlibs ) )"
# Doesn't work for some reason
#DEPEND="virtual/glut"
#if has_multilib_profile; then
#	DEPEND="${DEPEND} amd64? ( app-emulation/emul-linux-x86-xlibs )"
#	SRC_URI="amd64? ( ${X86_URI} ) ${SRC_URI}"
#fi
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack() {
	if use multilib && use amd64; then
		for i in $A; do
			if [[ "$i" =~ .*x86_64.* ]]; then
				mkdir 64bit
				cd 64bit
				unpack "$i"
				cd ..
			else
				mkdir 32bit
				cd 32bit
				unpack "$i"
				cd ..
			fi
		done
	else
		default
	fi
}

src_install() {
	if use multilib && use amd64; then
		cd 64bit
	fi

	dobin usr/bin/cgc

	if use x86; then
		dolib usr/lib/*
	elif use amd64; then
		dolib usr/lib64/*
		if use multilib && use amd64; then
			cd ../32bit
			ABI="x86" dolib usr/lib/*
			cd ../64bit
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
