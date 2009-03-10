# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils games flag-o-matic multilib

DESCRIPTION="PS2Emu ISO CDVD EFP plugin"
HOMEPAGE="http://www.pcsx2.net/"
PCSX2_VER="0.9.6"
SRC_URI="http://www.pcsx2.net/files/12310 -> Pcsx2_${PCSX2_VER}_source.7z"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
RESTRICT="primaryuri"

DEPEND="
	x86? (
		>=x11-libs/gtk+-2.6.1
	)
	amd64? (
		app-emulation/emul-linux-x86-gtklibs
	)"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/rc_${PCSX2_VER}/plugins/CDVDisoEFP/src/Linux"

pkg_setup() {
	games_pkg_setup
	append-ldflags -Wl,--no-as-needed

	if use amd64 && ! has_multilib_profile; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	use amd64 && multilib_toolchain_setup x86
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-custom-cflags.patch" || die "epatch failed"
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libCDVDisoEFP.so || die
	exeinto "$(games_get_libdir)/ps2emu/plugins/cfg"
	doexe cfgCDVDisoEFP || die
	if use doc; then
		dodoc ../../readme.txt ../../ChangeLog.txt || die
	fi
	prepgamesdirs
}
