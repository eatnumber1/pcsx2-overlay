# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/cdvd/CDVDnull"
inherit eutils games subversion

DESCRIPTION="PS2Emu null CDVD plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/CDVDnull"

src_unpack() {
	subversion_src_unpack
	S="${S}/Src"
	cd "${S}"
	
	sed -i \
		-e '/^CC =/d' \
		-e '/\${STRIP}/d' \
		-e 's/-O[0-9]\b//g' \
		-e 's/-fomit-frame-pointer\b//g' \
		-e 's/-ffast-math\b//g' \
		-e "s/^OPTIMIZE = /OPTIMIZE = ${CFLAGS} /" \
		Makefile || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libCDVDnull.so || die
	use doc && dodoc ../ReadMe.txt || die
	prepgamesdirs
}
