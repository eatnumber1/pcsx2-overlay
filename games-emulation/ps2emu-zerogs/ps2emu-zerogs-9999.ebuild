# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/gs/zerogs/opengl"
inherit eutils games subversion autotools

DESCRIPTION="PS2Emu ZeroGS OpenGL plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
#  I'm seeing better grahics with devbuild on.
IUSE="debug devbuild sse2"

RDEPEND="media-gfx/nvidia-cg-toolkit
	media-libs/glew
	media-libs/jpeg
	sys-libs/zlib
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXxf86vm
	>=x11-libs/gtk+-2"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-proto/xf86vidmodeproto"

S="${WORKDIR}/opengl"

src_unpack() {
	subversion_src_unpack
	cd "${S}"

	epatch "${FILESDIR}/${PN}-gcc43.patch"
	epatch "${FILESDIR}/${PN}-devbuild-paths.patch"
	epatch "${FILESDIR}/${PN}-consistent-naming.patch"

	sed -r -i \
		-e 's/-O[0-9]\b//g' \
		-e 's/-fomit-frame-pointer\b//g' \
		-e 's/C(..)?FLAGS=/C\1FLAGS+=/' \
		configure.ac || die

	eautoreconf -v --install || die
	chmod +x configure
}

src_compile() {
	egamesconf  \
		$(use_enable devbuild) \
		$(use_enable debug) \
		$(use_enable sse2) \
		|| die

	emake || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	insinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libZeroGSogl.so.* || die
	if use devbuild; then
		doins ps2hw.fx || die
		doins ctx1/ps2hw_ctx.fx || die
	else
		doins Win32/ps2hw.dat || die
	fi
	prepgamesdirs
}
