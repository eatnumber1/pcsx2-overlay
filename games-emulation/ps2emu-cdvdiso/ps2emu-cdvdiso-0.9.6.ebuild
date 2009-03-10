# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
ESVN_REPO_URI="http://pcsx2.googlecode.com/svn/tags/0.9.6/plugins/CDVDiso"
inherit eutils games subversion flag-o-matic

DESCRIPTION="PS2Emu ISO CDVD plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
RESTRICT="mirror"

DEPEND=">=app-arch/bzip2-1.0.0
	x86? (
		>=sys-libs/zlib-1.1.3
		>=x11-libs/gtk+-1.2.5
	)
	amd64? (
		app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-gtklibs
	)"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/CDVDiso/src/Linux"

pkg_setup() {
	games_pkg_setup

	if use amd64 && ! has_m32; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	ABI="x86"
	ABI_ALLOW="x86"
	append-flags -m32
}

src_unpack() {
	local S="${WORKDIR}/CDVDiso"
	subversion_src_unpack
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-custom-cflags.patch" || die "epatch failed"
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
