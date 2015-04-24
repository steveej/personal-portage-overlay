# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="A CLI for running app containers, and an implementation of the App
Container Spec."
HOMEPAGE="https://github.com/coreos/rkt"
SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc examples"

DEPEND=">=dev-lang/go-1.4.1
	sys-fs/squashfs-tools"
RDEPEND=""

src_compile() {
	RKT_STAGE1_IMAGE=/usr/share/rkt/stage1.aci \
		./build || die 'Build failed'
}

#RESTRICT="test"  # Tests fail due to Gentoo bug #500452
src_test() {
	./test || die 'Tests failed'
}

src_install() {
	dobin "${S}"/bin/rkt

	dodoc README.md
	use doc && dodoc -r Documentation
	use examples && dodoc -r examples

	into /usr/share/rkt
	dobin "${S}"/bin/actool
	dobin "${S}"/bin/bridge
	dobin "${S}"/bin/init
	dobin "${S}"/bin/macvlan
	dobin "${S}"/bin/static
	dobin "${S}"/bin/veth

	insinto /usr/share/rkt/
	doins "${S}"/bin/stage1.aci
}
