# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games

PCSX2="pcsx2-0.9.4"

DESCRIPTION="PS2Emu null CDVD plugin"
HOMEPAGE="http://www.pcsx2.net/"
SRC_URI="mirror://sourceforge/pcsx2/${PCSX2}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PCSX2}/plugins/cdvd/CDVDnull/Src"

src_unpack() {
	unpack ${A}
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
	exeinto "`games_get_libdir`/ps2emu/plugins"
	newexe libCDVDnull.so libCDVDnull.so.${PV} || die
	dodoc ../ReadMe.txt || die
	prepgamesdirs
}
