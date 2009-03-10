# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils games multilib

DESCRIPTION="P.E.Op.S PS2Emu sound plugin"
HOMEPAGE="http://www.pcsx2.net/"
PCSX2_VER="0.9.6"
SRC_URI="http://www.pcsx2.net/files/12310 -> Pcsx2_${PCSX2_VER}_source.7z"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa oss"
RESTRICT="primaryuri"

DEPEND="
	app-arch/p7zip
	alsa? (
		amd64? (
			app-emulation/emul-linux-x86-soundlibs[alsa]
		)
		!amd64? (
			media-libs/alsa-lib
		)
	)
	oss? (
		amd64? (
			app-emulation/emul-linux-x86-soundlibs[oss]
		)
	)"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/rc_${PCSX2_VER}/plugins/PeopsSPU2"

pkg_setup() {
	games_pkg_setup

	if ! use oss && ! use alsa; then
		die "Either the alsa or oss USE flag must be enabled!"
	fi

	if use amd64 && ! has_multilib_profile; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	use amd64 && multilib_toolchain_setup x86
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-custom-cflags.patch
}

src_compile() {
	if use alsa; then
		emake USEALSA=TRUE || die
	fi

	if use oss; then
		emake || die
	fi
}


src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"

	if use alsa; then
		newexe libspu2PeopsALSA.so.* libspu2PeopsALSA.so || die
	fi

	if use oss; then
		newexe libspu2PeopsOSS.so.* libspu2PeopsOSS.so || die
	fi

	prepgamesdirs
}
