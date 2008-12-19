# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games autotools

PCSX2="pcsx2-0.9.4"

DESCRIPTION="PS2Emu pad plugin"
HOMEPAGE="http://www.pcsx2.net/"
SRC_URI="mirror://sourceforge/pcsx2/${PCSX2}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
RESTRICT="nomirror"
KEYWORDS="~amd64 ~x86"
IUSE="debug joystick"

DEPEND=">=x11-libs/gtk+-2
	x11-proto/xproto
	joystick? ( media-libs/libsdl )"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/${PCSX2}/plugins/pad/zeropad"

pkg_setup() {
	games_pkg_setup

	if use joystick && built_with_use media-libs/libsdl nojoystick; then
		eerror "You must have media-libs/libsdl built with USE=\"-nojoystick\""
		die "You must have media-libs/libsdl built with USE=\"-nojoystick\""
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-consistent-naming.patch"
	epatch "${FILESDIR}/${PN}-custom-cflags.patch"
	epatch "${FILESDIR}/${PN}-add-joystick.patch"

	eautoreconf -v --install || die
}

src_compile() {
	egamesconf \
		$(use_enable debug) \
		$(use_enable joystick) \
		|| die
	emake || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libZeroPAD.so.${PV} || die
	prepgamesdirs
}
