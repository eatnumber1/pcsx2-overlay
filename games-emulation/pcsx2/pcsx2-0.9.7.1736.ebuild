# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
MY_PV="1736"
SVN_PCSX2_URI="http://${PN}.googlecode.com/svn/trunk"
ESVN_REPO_URI="${SVN_PCSX2_URI}/pcsx2@${MY_PV}"
inherit games autotools eutils multilib subversion

DESCRIPTION="PlayStation2 emulator"
HOMEPAGE="http://www.pcsx2.net/"
SRC_URI=""
SVN_PCSX2_BINDIR="${SVN_PCSX2_URI}/bin@${MY_PV}"
SVN_PCSX2_3RDPARTYDIR="${SVN_PCSX2_URI}/3rdparty@${MY_PV}"
SVN_PCSX2_COMMONDIR="${SVN_PCSX2_URI}/common@${MY_PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="primaryuri"
IUSE="debug nls doc"

DEPEND="
	x11-proto/xproto
	x86? (
		sys-libs/zlib
		>=x11-libs/gtk+-2
	)
	amd64? (
		>=app-emulation/emul-linux-x86-baselibs-20081109
		app-emulation/emul-linux-x86-gtklibs
	)
	nls? ( virtual/libintl )"
RDEPEND="${DEPEND}
	games-emulation/ps2emu-cdvdnull
	games-emulation/ps2emu-dev9null
	games-emulation/ps2emu-fwnull
	games-emulation/ps2emu-gsnull
	games-emulation/ps2emu-padnull
	games-emulation/ps2emu-spu2null
	games-emulation/ps2emu-usbnull"

LANGS="ar bg cz de du el es fr hb it ja pe pl po po_BR ro ru sh sw tc tr"

for i in ${LANGS}; do
	IUSE="${IUSE} linguas_${i}"
done

S="${WORKDIR}/pcsx2"

pkg_setup() {
	local x

	games_pkg_setup

	if ! use nls; then
		for x in ${LANGS}; do
			if [ -n "$(usev linguas_${x})" ]; then
				eerror "Any language other than English is not supported with USE=\"-nls\""
				die "Language ${x} not supported with USE=\"-nls\""
			fi
		done
	fi

	if use amd64 && ! has_multilib_profile; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	use amd64 && multilib_toolchain_setup x86
}

src_unpack() {
	subversion_src_unpack
	subversion_fetch ${SVN_PCSX2_BINDIR} "../bin"
	subversion_fetch ${SVN_PCSX2_3RDPARTYDIR} "../3rdparty"
	subversion_fetch ${SVN_PCSX2_COMMONDIR} "../common"
}

src_prepare() {
	epatch "${FILESDIR}/${P}_version-number.patch"
	epatch "${FILESDIR}/${P}_local-inis.patch"
	sed -i -e "s/^svnrev=.*$/svnrev=\"Revision: ${MY_PV}\"/" configure.ac
	eautoreconf --install || die
}

src_configure() {
	local myconf="--enable-customcflags --enable-local-inis"

	egamesconf \
		$(use_enable debug devbuild) \
		$(use_enable debug) \
		$(use_enable nls) \
		${myconf} \
		|| die
}

src_compile() {
	emake || die
}

src_install() {
	local x

	keepdir "$(games_get_libdir)/ps2emu/plugins"
	if use doc; then
		dodoc Docs/*.txt || die
	fi
	newgamesbin Linux/${PN} ${PN}.bin || die

	sed \
		-e "s:%GAMES_BINDIR%:${GAMES_BINDIR}:" \
		-e "s:%GAMES_DATADIR%:${GAMES_DATADIR}:" \
		-e "s:%GAMES_LIBDIR%:$(games_get_libdir):" \
		"${FILESDIR}/${PN}" > "${D}${GAMES_BINDIR}/${PN}" || die

	cd ../bin
	find . -name "\.svn" -type d -exec rm -r {} +
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r .pixmaps patches || die

	insinto "${GAMES_DATADIR}/${PN}/Langs"
	for x in ${LANGS}; do
		if use linguas_${x}; then
			[[ "${x/_/}" == "${x}" ]] && x=${x}_$(echo ${x} | tr 'a-z' 'A-Z')
			doins -r Langs/${x} || die "Unable to install language ${x}."
		fi
	done

	prepgamesdirs
}

pkg_postinst() {
	if ! use debug; then
		ewarn "If this package exhibits random crashes, recompile ${PN}"
		ewarn "with the debug use flag enabled. If that fixes it, file a bug."
		echo
	fi

	elog "Please note that this ebuild does not install any plugins."
	elog "You will need to install ps2emu plugins in order for the emulator"
	elog "to be usable."
}
