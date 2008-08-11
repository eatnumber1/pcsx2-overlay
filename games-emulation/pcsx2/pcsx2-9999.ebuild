# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/${PN}/${PN}"
inherit games autotools eutils subversion

DESCRIPTION="PlayStation2 emulator"
HOMEPAGE="http://www.pcsx2.net/"
SVN_PCSX2_BINDIR="https://pcsx2.svn.sourceforge.net/svnroot/${PN}/bin"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug nls sse3 sse mmx doc"

DEPEND="sys-libs/zlib
	>=x11-libs/gtk+-2
	virtual/libstdc++
	x11-proto/xproto
	nls? ( virtual/libintl )"

LANGS="ar bg cz de du el es fr hb it ja pe pl po po_BR ro ru sh sw tc tr"

for i in ${LANGS}; do
	IUSE="${IUSE} linguas_${i}"
done

S="${WORKDIR}/${P}/${PN}"

pkg_setup() {
	local x

	if ! use nls; then
		for x in ${LANGS}; do
			if [ -n "$(usev linguas_${x})" ]; then
				eerror "Any language other than English is not supported with USE=\"-nls\""
				die "Language ${x} not supported with USE=\"-nls\""
			fi
		done
	fi
}

src_unpack() {
	subversion_src_unpack
	subversion_fetch ${SVN_PCSX2_BINDIR} "../bin"
	cd "${S}"

	# Preserve custom CFLAGS passed to configure.
	epatch "${FILESDIR}"/${PN}-custom-cflags.patch

	# Add nls support to the configure script.
	epatch "${FILESDIR}"/${PN}-add-nls.patch

	# Allow plugin inis to be stored in ~/.pcsx2/inis.
	epatch "${FILESDIR}"/${PN}-plugin-inis.patch

	epatch "${FILESDIR}"/${PN}-gcc43.patch

	eautoreconf -v --install || die
}

src_compile() {
	local myconf

	if ! use x86 && ! use amd64; then
		einfo "Recompiler not supported on this architecture. Disabling."
		myconf=" --disable-recbuild"
	elif ! use mmx || ! use sse; then
		einfo "Recompiler requires USE=\"mmx sse\". Disabling."
		myconf=" --disable-recbuild"
	fi

	egamesconf  \
		$(use_enable debug devbuild) \
		$(use_enable debug) \
		$(use_enable nls) \
		$(use_enable sse3) \
		${myconf} \
		|| die

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
	if use doc; then
		dohtml -r compat_list/* || die
	fi
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r *.xml .pixmaps patches || die

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
