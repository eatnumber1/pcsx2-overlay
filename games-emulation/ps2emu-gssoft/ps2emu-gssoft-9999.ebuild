# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="http://pcsx2.googlecode.com/svn/trunk/plugins/gs/GSsoft"
inherit eutils games subversion autotools

DESCRIPTION="PS2Emu null sound plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc debug"
RESTRICT="nomirror"

DEPEND=">=x11-libs/gtk+-2
	x11-libs/libXxf86vm
	sys-libs/zlib
	media-libs/libsdl"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/${PCSX2}/GSsoft"

src_unpack() {
	subversion_src_unpack
	S="${S}/Src"
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-custom-cflags.patch

	eautoreconf --install || die
}

src_compile() {
	egamesconf  \
		$(use_enable debug devbuild) \
		$(use_enable debug) \
		|| die

	emake || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	newexe libGSSoftr.so.* libGSSoftr.so.${PV} || die
	if use doc; then
		dodoc ../ReadMe.txt || die
	fi
	prepgamesdirs
}
