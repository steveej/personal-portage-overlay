# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils flag-o-matic

DESCRIPTION="C object oriented SIP Stack."
HOMEPAGE="http://www.linphone.org/"
SRC_URI="mirror://nongnu/linphone/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"

SLOT="0"

IUSE="test examples"
REQUIRED_USE=""

DEPEND="${RDEPEND}
	~dev-libs/antlr-c-3.4
	dev-java/antlr:3
	virtual/pkgconfig
	test? ( >=dev-util/cunit-2.1_p2[ncurses] )"

src_prepare() {
eautoreconf
}

src_configure() {
strip-flags
}

#src_configure() {
##	local myeconfargs=(
##		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html
##		--datadir="${EPREFIX}"/usr/share/${PN}
##	)
#
#	econf "${myeconfargs[@]}"
#}

src_test() {
	default
	cd tester || die
	emake -C tester test
}

src_install() {
	default
	prune_libtool_files

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins tester/*.c
	fi
}
