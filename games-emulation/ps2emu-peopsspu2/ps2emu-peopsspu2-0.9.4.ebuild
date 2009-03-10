# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
ESVN_REPO_URI="http://pcsx2.googlecode.com/svn/tags/0.9.6/plugins/PeopsSPU2"
inherit eutils games subversion flag-o-matic multilib

DESCRIPTION="P.E.Op.S PS2Emu sound plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa oss"
RESTRICT="mirror"

DEPEND="
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

S="${WORKDIR}/PeopsSPU2"

pkg_setup() {
	games_pkg_setup

	if ! use oss && ! use alsa; then
		die "Either the alsa or oss USE flag must be enabled!"
	fi

	if use amd64 && ! has_m32; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	ABI="x86"
	ABI_ALLOW="x86"
	append-flags -m32
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
		newexe libspu2PeopsALSA.so.* libspu2PeopsALSA.so.${PV} || die
	fi

	if use oss; then
		newexe libspu2PeopsOSS.so.* libspu2PeopsOSS.so.${PV} || die
	fi

	prepgamesdirs
}
