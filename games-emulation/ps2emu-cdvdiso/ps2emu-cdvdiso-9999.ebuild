# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/cdvd/CDVDiso"
inherit eutils games subversion

DESCRIPTION="PS2Emu ISO CDVD plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"
RESTRICT="nomirror"

DEPEND=">=app-arch/bzip2-1.0.0
	>=sys-libs/zlib-1.1.3
	>=x11-libs/gtk+-1.2.5"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/CDVDiso"

src_unpack() {
	subversion_src_unpack
	S="${S}/src/Linux"
	cd "${S}"

	epatch "${FILESDIR}/${PN}-custom-cflags.patch"
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libCDVDiso.so || die
	exeinto "$(games_get_libdir)/ps2emu/plugins/cfg"
	doexe cfgCDVDiso || die
	if use doc; then
		dodoc ../../ReadMe.txt || die
	fi
	prepgamesdirs
}
