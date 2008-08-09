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
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2"
DEPEND="${RDEPEND}
	x11-proto/xproto
	media-libs/libsdl"

S="${WORKDIR}/${PCSX2}/plugins/pad/zeropad"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-consistent-naming.patch"
	
	sed -r -i \
		-e '/C(..)?FLAGS=/d' \
		-e 's/-O[0-9]\b//g' \
		-e 's/-fomit-frame-pointer\b//g' \
		-e 's/C(..)?FLAGS\+="/C\1FLAGS+=" /' \
		configure.ac || die
	
	eautoreconf -v --install || die
}

src_compile() {
	egamesconf $(use_enable debug) || die
	emake || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libZeroPAD.so.${PV} || die
	prepgamesdirs
}
