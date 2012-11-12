# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit games cmake-utils subversion

HOMEPAGE="http://www.pcsx2.net/"
DESCRIPTION="PlayStation2 emulator"
ESVN_REPO_URI="http://${PN}.googlecode.com/svn/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="debug nls"

DEPEND="
	media-libs/alsa-lib
	app-arch/bzip2
	sys-libs/zlib
	media-libs/glew
	x11-libs/wxGTK[X]
	virtual/jpeg
	media-libs/libsoundtouch
	media-libs/portaudio[alsa]
	media-libs/libsdl
	dev-cpp/sparsehash
	media-gfx/nvidia-cg-toolkit
	nls? ( virtual/libintl )"
RDEPEND="${DEPEND}"

LANGS="ar bg cz de du el es fr hb it ja pe pl po po_BR ro ru sh sw tc tr"

for i in ${LANGS}; do
	IUSE="${IUSE} linguas_${i}"
done

pkg_pretend() {
	if ! use x86; then
		eerror "PCSX2 currently does not support platforms other than 32bit x86."
		eerror "If you are running an amd64 based host and don't want to install"
		eerror "a full dual-boot you can use a chroot environment."
		eerror "For more information on setting up a 32bit chroot environment see:"
		eerror "http://www.gentoo.org/proj/en/base/amd64/howtos/index.xml?part=1&chap=2"
		die "Host platform unsupported."
	fi
}

pkg_setup() {
	if ! use nls; then
		for x in ${LANGS}; do
			if [ -n "$(usev linguas_${x})" ]; then
				eerror "Any language other than English is not supported with USE=\"-nls\""
				die "Language ${x} not supported with USE=\"-nls\""
			fi
		done
	fi
}

src_configure() {
	PREFIX=${GAMES_PREFIX}

	mycmakeargs="${mycmakeargs}"
	mycmakeargs+=(
		"-DPACKAGE_MODE=TRUE"
		"-DPLUGIN_DIR=$(games_get_libdir)/${PN}"
		"-DGAMEINDEX_DIR=${GAMES_DATADIR}/${PN}"
		"-DGLSL_SHADER_DIR=${GAMES_DATADIR}/${PN}"
		)

	if ! use debug; then
		CMAKE_BUILD_TYPE="Release"
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	prepgamesdirs
}
