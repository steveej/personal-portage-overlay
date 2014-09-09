# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit user
inherit systemd

DESCRIPTION="Control utility for ectd"
HOMEPAGE="https://github.com/coreos/etcdctl"
SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

DEPEND=">=dev-lang/go-1.2"
RDEPEND=""

src_compile() {
	./build || die "Build failed"
}

src_test() {
	./test || die 'Test failed'
}

src_install() {
	dobin "${S}"/bin/"${PN}"

	dodoc README.md
	use examples && dodoc -r examples
}
