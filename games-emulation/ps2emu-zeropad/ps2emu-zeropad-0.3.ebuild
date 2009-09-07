# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
MY_PV="1736"
MY_PN="zeropad"
SVN_PCSX2_URI="http://pcsx2.googlecode.com/svn/trunk"
ESVN_REPO_URI="${SVN_PCSX2_URI}/plugins/${MY_PN}@${MY_PV}"
inherit eutils games autotools multilib subversion

DESCRIPTION="PS2Emu pad plugin"
HOMEPAGE="http://www.pcsx2.net/"
SRC_URI=""
SVN_PCSX2_COMMONDIR="${SVN_PCSX2_URI}/common@${MY_PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"
RESTRICT="primaryuri"

DEPEND="
	app-arch/p7zip
	x86? (
		>=x11-libs/gtk+-2
		x11-proto/xproto
		media-libs/libsdl[joystick]
	)
	amd64? (
	    app-emulation/emul-linux-x86-xlibs
		app-emulation/emul-linux-x86-gtklibs
		app-emulation/emul-linux-x86-sdl
	)"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/plugins/${MY_PN}"

pkg_setup() {
	if use amd64 && ! has_multilib_profile; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	use amd64 && multilib_toolchain_setup x86
}

src_unpack() {
	subversion_src_unpack
	local S="${WORKDIR}"
	subversion_fetch "${SVN_PCSX2_COMMONDIR}" "common"
}

src_prepare() {
	epatch "${FILESDIR}/${P}_consistent-naming.patch"
	epatch "${FILESDIR}/${P}_custom-cflags.patch"

	eautoreconf -v --install || die
}

src_configure() {
	egamesconf \
		$(use_enable debug) \
		|| die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	newexe libZeroPAD.so.* libZeroPad.so || die
	prepgamesdirs
}
