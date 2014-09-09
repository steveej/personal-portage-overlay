# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/fleet/fleet-9999.ebuild,v 1.1 2014/07/19 19:43:53 alunduil Exp $

EAPI=5

inherit git-2 systemd

EGIT_REPO_URI="git://github.com/coreos/fleet.git"

DESCRIPTION="A Distributed init System"
HOMEPAGE="https://github.com/coreos/fleet"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="doc examples"

DEPEND=">=dev-lang/go-1.2"
RDEPEND=""

src_compile() {
	./build || die 'Build failed'
}

# Will abort with following error:
# go tool: no such tool "cover"; to install:
# 	go get code.google.com/p/go.tools/cmd/cover
#src_test() {
#	./test || die 'Test failed'
#}

src_install() {
	dobin "${S}"/bin/fleetd
	dobin "${S}"/bin/fleetctl
	systemd_dounit "${FILESDIR}"/fleetd.service

	insinto /etc/${PN}
	newins "${PN}".conf.sample "${PN}".conf

	dodoc README.md
	use doc && dodoc Documentation/*.*
	use examples && dodoc -r Documentation/examples
}

pkg_postinst() {
	ewarn "If you're upgrading from a version < 0.8.0 please read the messages!"
	elog ""
	elog "The fleet systemd service and the binary changed their name to fleetd."
	elog "If your using systemd to start fleet automatically, please update your configuration:"
	elog "  systemctl disable fleet; systemctl enable fleetd"
}
