# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/dev9/DEV9linuz"
inherit eutils games subversion

DESCRIPTION="PS2Emu dev9 plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=">=x11-libs/gtk+-2.0"
RDEPEND="${DEPEND}"

S="${WORKDIR}/DEV9linuz"

src_unpack() {
	subversion_src_unpack
	S="${S}/Linux"
	cd "${S}"
	
	sed -i \
		-e '/^CC =/d' \
		-e '/\bstrip\b/d' \
		-e 's/-O[0-9]\b//g' \
		-e 's/-fomit-frame-pointer\b//g' \
		-e 's/-O[0-9]//g' \
		-e 's/-o dev9net.o/${CFLAGS} ${LDFLAGS} &/' \
		-e 's/-Wl/${LDFLAGS} &/g' \
		-e 's/gtk-config --cflags/pkg-config --cflags gtk+-2.0/g' \
		Makefile || die

#	sed -i \
#		-e 's/return fread(dest, 1, size, f);/return fread(dest, 1, size, handle);/' \
#		-e 's/int _readfile(void *handle, u8 *dest, u64 offset, int size) {/int _readfile(void *handle, u8 *dest, int size) {' \
#		-e 's/fseek(handle, offset, SEEK_SET);/fseek(handle, 0, SEEK_SET);/g' \
#		../DEV9.c || die

#	sed -i -e 's/index/indexi/g' socks.c || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libDEV9linuz.so || die
	exeinto "$(games_get_libdir)/ps2emu/plugins/cfg"
	doexe cfgDEV9linuz || die
	prepgamesdirs
}
