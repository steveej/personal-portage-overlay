# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit systemd vcs-snapshot

DESCRIPTION="A Distributed init System"
HOMEPAGE="https://github.com/coreos/fleet"
SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND=">=dev-lang/go-1.2"
RDEPEND=""

src_compile() {
	./build || die 'Build failed'
}

src_test() {
	./test || die 'Test failed'
}

src_install() {
	dobin "${S}"/bin/fleetd
	dobin "${S}"/bin/fleetctl
	systemd_dounit "${FILESDIR}"/fleetd.service

	insinto /etc/${PN}
	newins "${PN}".conf.sample "${PN}".conf

	dodoc README.md
	use doc && dodoc -r Documentation/*
}

pkg_postinst() {
	ewarn "If you're upgrading from a version < 0.8.0 please read this!"
	elog "The fleet systemd service and the binary changed their name to fleetd."
	elog "If your using systemd to start fleet automatically, please update your configuration:"
	elog "  systemctl disable fleet && systemctl enable fleetd"
}
