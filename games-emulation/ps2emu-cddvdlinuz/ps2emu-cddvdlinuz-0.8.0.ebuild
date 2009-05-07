# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils games flag-o-matic multilib

DESCRIPTION="PSEmu2 CD/DVD plugin"
HOMEPAGE="http://www.pcsx2.net/"
PCSX2_VER="0.9.6"
SRC_URI="http://www.pcsx2.net/files/12310 -> Pcsx2_${PCSX2_VER}_source.7z"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"
RESTRICT="primaryuri"

DEPEND="
	app-arch/p7zip
	app-arch/bzip2
	x86? (
		>=sys-libs/zlib-1.1.3
		>=x11-libs/gtk+-2
	)
	amd64? (
		>=app-emulation/emul-linux-x86-baselibs-20081109
		app-emulation/emul-linux-x86-gtklibs
	)"

RDEPEND="${DEPEND}
	games-emulation/pcsx2"

S="${WORKDIR}/rc_${PCSX2_VER}/plugins/CDVDlinuz/Src/Linux"

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
