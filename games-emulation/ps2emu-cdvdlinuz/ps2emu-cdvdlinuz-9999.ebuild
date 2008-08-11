# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/cdvd/CDVDlinuz"
inherit eutils games subversion flag-o-matic

DESCRIPTION="PS2Emu CDVD plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND="app-arch/bzip2
	sys-libs/zlib
	>=x11-libs/gtk+-2"

RDEPEND="${DEPEND}
	games-emulation/pcsx2"

S="${WORKDIR}/CDVDlinuz"

pkg_setup() {
	append-ldflags -Wl,--no-as-needed
}

src_unpack() {
	subversion_src_unpack
	S="${S}/Src/Linux"
	cd "${S}"

	epatch "${FILESDIR}/${PN}-custom-cflags.patch"
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libCDVDlinuz.so || die
	exeinto "$(games_get_libdir)/ps2emu/plugins/cfg"
	doexe cfgCDVDlinuz || die
	if use doc; then
		dodoc ../../readme.txt ../../ChangeLog.txt || die
	fi
	prepgamesdirs
}
