# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit systemd vcs-snapshot

DESCRIPTION="distributed init system"
HOMEPAGE="https://github.com/coreos/fleet"
SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc examples"

DEPEND=">=dev-lang/go-1.2"
RDEPEND=""

src_compile() {
	./build || die 'build'
}

src_test() {
	./test || die 'test'
}

src_install() {
	dobin "${S}"/bin/fleet
	dobin "${S}"/bin/fleetctl

	dodoc README.md || die "installing README"

	use doc && dodoc Documentation/*.*

	if use examples; then
	    mv fleet.conf.sample Documentation/examples/ || die "installing fleet.conf.sample"
		dodoc -r Documentation/examples || die "installing more examples"
	fi

	systemd_dounit "${FILESDIR}"/fleet.service || die "installing fleetd.service"
}
