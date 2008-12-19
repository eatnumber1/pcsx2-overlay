# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/pad/zeropad"
inherit eutils games subversion autotools

DESCRIPTION="PS2Emu pad plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug joystick"
RESTRICT="nomirror"

DEPEND=">=x11-libs/gtk+-2
	x11-proto/xproto
	joystick? ( media-libs/libsdl )"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/zeropad"

pkg_setup() {
	games_pkg_setup

	if use joystick && built_with_use media-libs/libsdl nojoystick; then
		eerror "You must have media-libs/libsdl built with USE=\"-nojoystick\""
		die "You must have media-libs/libsdl built with USE=\"-nojoystick\""
	fi
}

src_unpack() {
	subversion_src_unpack
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
	doexe libZeroPAD.so.* || die
	prepgamesdirs
}
