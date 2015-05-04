# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils systemd

if [[ "${PV}" == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/steveeJ/rkt.git"
	EGIT_BRANCH="staging"
	KEYWORDS=""
else
	SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

DESCRIPTION="A CLI for running app containers, and an implementation of the App
Container Spec."
HOMEPAGE="https://github.com/coreos/rkt"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="doc examples +actool"

DEPEND=">=dev-lang/go-1.4.1
	sys-fs/squashfs-tools
	app-arch/cpio"
RDEPEND=""

src_compile() {
	RKT_STAGE1_IMAGE=/usr/share/rkt/stage1.aci \
	RKT_STAGE1_USR_FROM=src \
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
	use actool && dobin "${S}"/bin/actool
#	dobin "${S}"/bin/bridge
#	dobin "${S}"/bin/init
#	dobin "${S}"/bin/macvlan
#	dobin "${S}"/bin/static
#	dobin "${S}"/bin/veth

	insinto /usr/share/rkt/
	doins "${S}"/bin/stage1.aci

	systemd_dounit "${FILESDIR}"/rkt-metadata.service
	systemd_dounit "${FILESDIR}"/rkt-metadata.socket
}
