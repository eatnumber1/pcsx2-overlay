# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/spu2/PeopsSPU2"
inherit eutils games subversion

DESCRIPTION="P.E.Op.S PS2Emu sound plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="alsa oss"

DEPEND="alsa? ( media-libs/alsa-lib )"

RDEPEND="${DEPEND}
	games-emulation/pcsx2"

S="${WORKDIR}/PeopsSPU2"

pkg_setup() {
	games_pkg_setup

	if ! use oss && ! use alsa; then
		die "Either the alsa or oss USE flag must be enabled!"
	fi
}

src_unpack() {
	subversion_src_unpack
	cd "${S}"

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
