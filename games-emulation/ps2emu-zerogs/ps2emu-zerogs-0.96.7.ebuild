# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games autotools eutils flag-o-matic

PCSX2="pcsx2-0.9.4"

DESCRIPTION="PS2Emu ZeroGS OpenGL plugin"
HOMEPAGE="http://www.pcsx2.net/"
SRC_URI="mirror://sourceforge/pcsx2/${PCSX2}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug sse2 +shaders"

DEPEND="media-gfx/nvidia-cg-toolkit
	x11-libs/libX11
	media-libs/glew
	virtual/libstdc++
	virtual/opengl
	media-libs/jpeg
	sys-libs/zlib
	x11-libs/libXxf86vm
	x11-proto/xproto
	x11-proto/xf86vidmodeproto
	>=x11-libs/gtk+-2"

RDEPEND="${DEPEND}
	games-emulation/pcsx2"

S="${WORKDIR}/${PCSX2}/plugins/gs/zerogs/opengl"

pkg_setup() {
	if ! use debug && use shaders; then
		append-ldflags -Wl,--no-as-needed
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-gcc43.patch"
	epatch "${FILESDIR}/${PN}-devbuild-paths.patch"
	epatch "${FILESDIR}/${PN}-consistent-naming.patch"
	epatch "${FILESDIR}/${PN}-custom-cflags.patch"
	epatch "${FILESDIR}/${PN}-compile-shaders.patch"

	eautoreconf -v --install || die
	chmod +x configure
}

src_compile() {
	egamesconf  \
		$(use_enable debug devbuild) \
		$(use_enable debug) \
		$(use_enable sse2) \
		|| die

	emake || die

	if ! use debug && use shaders; then
		einfo "Compiling shaders..."
		emake -C ZeroGSShaders
		./ZeroGSShaders/zgsbuild ps2hw.fx ps2hw.dat || \
			die "Unable to compile shaders"
	fi
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	insinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libZeroGSogl.so.* || die
	if use debug; then
		doins ps2hw.fx || die
		doins ctx1/ps2hw_ctx.fx || die
	else
		if use shaders; then
			doins ps2hw.dat || die
		else
			doins Win32/ps2hw.dat || die
		fi
	fi
	prepgamesdirs
}
