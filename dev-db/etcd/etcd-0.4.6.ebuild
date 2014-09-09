# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit user
inherit systemd

DESCRIPTION="A highly-available key value store for shared configuration and service discovery"
HOMEPAGE="https://github.com/coreos/etcd"
SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=dev-lang/go-1.2"
RDEPEND=""

src_compile() {
	./build || die "Build failed"
}

# Does not run this successfully.
# Needs investigation by someone more experienced with Go and testing.
#src_test() {
# ./test.sh || die 'Test failed'
#}

src_install() {
	dobin "${WORKDIR}"/etcd-"${PV}"/bin/etcd
	dobin "${WORKDIR}"/etcd-"${PV}"/bin/bench

	insinto /etc/"${PN}"
	doins "${FILESDIR}"/"${PN}".conf

	newinitd "${FILESDIR}"/etcd.initd etcd
	systemd_dounit "${FILESDIR}"/"${PN}".service
	systemd_dotmpfilesd "${FILESDIR}"/"${PN}".tmpdfsd.conf

	dodoc README.md
	use doc && dodoc -r Documentation
}

pkg_postinst() {
	ebegin "Creating etcd user"
	enewgroup etcd
	enewuser etcd -1 -1 /var/lib/etcd etcd
	dodir /var/lib/etcd
	dodir /var/log/etcd
	dodir /var/run/etcd
	fowners etcd /var/run/etcd
	fowners etcd /var/log/etcd
}
