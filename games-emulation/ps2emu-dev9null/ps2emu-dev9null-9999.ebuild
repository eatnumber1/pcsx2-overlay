# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/dev9/dev9null"
inherit eutils games subversion

DESCRIPTION="PS2Emu null DEV9 plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND=""

RDEPEND="${DEPEND}
	games-emulation/pcsx2"

S="${WORKDIR}/dev9null"

src_unpack() {
	subversion_src_unpack
	S="${S}/src"
	cd "${S}"
	
	epatch "${FILESDIR}"/${PN}-custom-cflags.patch
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libDEV9null.so || die
	use doc && dodoc ../ReadMe.txt || die
	prepgamesdirs
}
