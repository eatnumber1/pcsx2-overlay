# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
ESVN_REPO_URI="http://pcsx2.googlecode.com/svn/tags/0.9.6/plugins/CDVDnull"
inherit eutils games subversion multilib flag-o-matic

DESCRIPTION="PS2Emu null CDVD plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"
RESTRICT="mirror"

DEPEND="
	x86? (
		>=x11-libs/gtk+-2
	)
	amd64? (
		app-emulation/emul-linux-x86-gtklibs
	)"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/CDVDnull/Src"

pkg_setup() {
	games_pkg_setup

	if use amd64 && ! has_multilib_profile; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	use amd64 && multilib_toolchain_setup x86
}

src_unpack() {
	local S="${WORKDIR}/CDVDnull"
	subversion_src_unpack
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-custom-cflags.patch" || die "epatch failed"
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libCDVDnull.so || die
	if use doc; then
		dodoc ../ReadMe.txt || die
	fi
	prepgamesdirs
}
