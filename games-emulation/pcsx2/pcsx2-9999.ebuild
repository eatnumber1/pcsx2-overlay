# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/${PN}/${PN}"
inherit games autotools eutils flag-o-matic subversion

DESCRIPTION="PlayStation2 emulator"
HOMEPAGE="http://www.pcsx2.net/"
SVN_PCSX2_BINDIR="https://pcsx2.svn.sourceforge.net/svnroot/${PN}/bin"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="alsa debug devbuild nls oss vmbuild"

CDEPEND="sys-libs/zlib
	>=x11-libs/gtk+-2"

DEPEND="${CDEPEND}
	x11-proto/xproto"

RDEPEND="${CDEPEND}
	games-emulation/ps2emu-zerogs
	games-emulation/ps2emu-zeropad
	games-emulation/ps2emu-cdvdnull
	games-emulation/ps2emu-dev9null
	games-emulation/ps2emu-spu2null
	games-emulation/ps2emu-fwnull
	>=games-emulation/ps2emu-usbnull-0.4-r1
	alsa? ( games-emulation/ps2emu-peopsspu2 )
	oss? ( games-emulation/ps2emu-peopsspu2 )"

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

	if use vmbuild; then
		ewarn "Warning: Compilation is known to fail with the vmbuild use flag"
		ewarn "enabled. The recommended use flags are USE=\"sse2 -vmbuild\"."
		ewarn "Do not file a bug unless you are using the above USE flags."
		ewarn "If you can get it to compile however, please file a bug or "
		ewarn "contact me at eatnumber1@gmail.com. (i'll give you a cookie)"
		ebeep 5
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
	filter-flags -O0
	
	if ! use x86 && ! use amd64; then
		einfo "Recompiler not supported on this architecture. Disabling."
		myconf=" --disable-recbuild"
	fi
	
	egamesconf  \
		$(use_enable devbuild) \
		$(use_enable debug) \
		$(use_enable nls) \
		$(use_enable vmbuild) \
		${myconf} \
		|| die

	emake || die
}

src_install() {
	local x

	keepdir "$(games_get_libdir)/ps2emu/plugins"
	dodoc Docs/*.txt || die "dodoc failed"
	newgamesbin Linux/${PN} ${PN}.bin || die

	sed \
		-e "s:%GAMES_BINDIR%:${GAMES_BINDIR}:" \
		-e "s:%GAMES_DATADIR%:${GAMES_DATADIR}:" \
		-e "s:%GAMES_LIBDIR%:$(games_get_libdir):" \
		"${FILESDIR}/${PN}" > "${D}${GAMES_BINDIR}/${PN}" || die

	cd ../bin
	dohtml -r compat_list/* || die
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r *.xml .pixmaps patches || die
	insinto "${GAMES_DATADIR}/${PN}/Langs"

	for x in ${LANGS}; do
		if use linguas_${x}; then
			[[ "${x/_/}" == "${x}" ]] && x=${x}_$(echo ${x} | tr 'a-z' 'A-Z')
			doins -r Langs/${x} || die "doins for language ${x} failed"
		fi
	done

	prepgamesdirs
}

pkg_postinst() {
	if ! use devbuild; then
		ewarn "If this package exhibits random crashes, recompile ${PN}"
		ewarn "with the devbuild use flag enabled. If that fixes it, file a bug."
		echo
	fi

	elog "Please note that this ebuild does not install all the available plugins."
	elog "You will need to install other ps2emu plugins in order for the emulator"
	elog "to be usable."
}
