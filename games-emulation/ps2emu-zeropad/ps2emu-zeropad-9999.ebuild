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

RDEPEND=">=x11-libs/gtk+-2"
DEPEND="${RDEPEND}
	x11-proto/xproto
	media-libs/libsdl"

S="${WORKDIR}/zeropad"

src_unpack() {
	subversion_src_unpack
	cd "${S}"

	epatch "${FILESDIR}/${PN}-consistent-naming.patch"
	
	sed -r -i \
		-e '/C(..)?FLAGS=/d' \
		-e 's/-O[0-9]\b//g' \
		-e 's/-fomit-frame-pointer\b//g' \
		-e 's/C(..)?FLAGS\+="/C\1FLAGS+=" /' \
		configure.ac || die

	if built_with_use media-libs/libsdl nojoystick && use joystick; then
		die "You must have media-libs/libsdl built with -nojoystick"
	fi

	use joystick || sed -i -e 's/#define JOYSTICK_SUPPORT//' Linux/linux.cpp
	
	eautoreconf -v --install || die
}

src_compile() {
	egamesconf $(use_enable debug) || die
	emake || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libZeroPAD.so.* || die
	prepgamesdirs
}
