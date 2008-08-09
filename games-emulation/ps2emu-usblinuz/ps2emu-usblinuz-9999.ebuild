# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/usb/USBlinuz"
inherit eutils games subversion

DESCRIPTION="PS2Emu USB plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND=">=x11-libs/gtk+-2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/USBlinuz"

src_unpack() {
	subversion_src_unpack
	S="${S}/Linux"
	cd "${S}"
	
	sed -i \
		-e '/^CC =/d' \
		-e '/\bstrip\b/d' \
		-e 's/-O[0-9]\b//g' \
		-e 's/-fomit-frame-pointer\b//g' \
		-e 's/gtk-config --cflags/pkg-config --cflags gtk+-2.0/' \
		-e 's/gtk-config --libs/pkg-config --libs gtk+-2.0/' \
		-e 's/${CFLAGS}/& ${LDFLAGS}/g' \
		Makefile || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libUSBlinuz.so || die
	exeinto "$(games_get_libdir)/ps2emu/plugins/cfg"
	doexe cfgUSBlinuz || die
	use doc && dodoc ../ReadMe.txt || die
	prepgamesdirs
}
