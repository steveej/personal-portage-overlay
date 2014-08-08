# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/tinc/tinc-1.0.16.ebuild,v 1.2

EAPI="4"

[[ ${PV} = *9999* ]] && EXTRA_ECLASS="git-2 autotools" || EXTRA_ECLASS=""

inherit eutils ${EXTRA_ECLASS}

MY_P=${P/_/}

DESCRIPTION="tinc is an easy to configure VPN implementation"
HOMEPAGE="http://www.tinc-vpn.org/"

if [[ ${PV} == *9999* ]]; then
	EGIT_BRANCH="1.1"
	EGIT_REPO_URI="git://tinc-vpn.org/tinc"
else
	RELEASE_URI="http://www.tinc-vpn.org/packages/${MY_P}.tar.gz"
fi

SRC_URI="${RELEASE_URI}"

LICENSE="GPL-2"
SLOT="0"
if [[ ${PV} == *9999* ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
fi
IUSE="+lzo +zlib +jumboframes raw uml -tunemu gcrypt vde"

DEPEND="dev-libs/libevent
	sys-libs/ncurses
	!gcrypt? ( >=dev-libs/openssl-0.9.7c )
	 gcrypt? ( dev-libs/libgcrypt )
	lzo? ( dev-libs/lzo:2 )
	zlib? ( >=sys-libs/zlib-1.1.4-r2 )
	vde? ( net-misc/vde )"
RDEPEND="${DEPEND}"

if [[ ${PV} != *9999* ]]; then
	S="${WORKDIR}/${MY_P}"
fi

src_prepare() {
	if [[ ${PV} = *9999* ]]; then
		eautoreconf
	fi
}

src_configure() {
	econf  --enable-jumbograms \
		$(use_enable lzo)      \
		$(use_enable zlib)     \
		$(use_enable uml)	\
		$(use_enable vde)	\
		$(use_enable jumboframes) \
		${myconf}
}

src_compile() {
	emake all ChangeLog || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install
	dodir /etc/tinc
	dodoc AUTHORS ChangeLog COPYING.README NEWS README THANKS
	dodoc doc/{CONNECTIVITY,NETWORKING,PROTOCOL,SECURITY2,SPTPS}
	dodoc gui/README.gui
	dodoc -r doc/sample-config
	newinitd "${FILESDIR}"/tincd.1 tincd
	newinitd "${FILESDIR}"/tincd.lo.1 tincd.lo
	doconfd "${FILESDIR}"/tinc.networks
	newconfd "${FILESDIR}"/tincd.conf.1 tincd
}

pkg_postinst() {
	elog "This package requires the tun/tap kernel device."
	elog "Look at http://www.tinc-vpn.org/ for how to configure tinc"
}
