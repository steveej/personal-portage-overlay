# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit systemd user

DESCRIPTION="A highly-available key value store for shared configuration and service discovery"
HOMEPAGE="https://github.com/coreos/etcd"
SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+etcd +etcdctl etcd-migrate doc etcd-dump-logs"
DEPEND="
	>=dev-lang/go-1.2
	etcdctl? ( !dev-db/etcdctl )
"
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

	use etcd && dobin "${WORKDIR}"/etcd-"${PV}"/bin/etcd
	use etcdctl && dobin "${WORKDIR}"/etcd-"${PV}"/bin/etcdctl
	use etcd-migrate && dobin "${WORKDIR}"/etcd-"${PV}"/bin/etcd-migrate
	use etcd-dump-logs && dobin "${WORKDIR}"/etcd-"${PV}"/bin/etcd-migrate

	insinto /etc/"${PN}"
	doins "${FILESDIR}"/"${PN}".env

	newinitd "${FILESDIR}"/${PN}.2.initd etcd
	systemd_newunit "${FILESDIR}"/"${PN}".2.service "${PN}".service
	systemd_dotmpfilesd "${FILESDIR}"/"${PN}".tmpdfsd.conf

	dodoc README.md
	use doc && dodoc -r Documentation/*

}

ETCD_DATA_DIR=${ROOT}/var/lib/etcd
pkg_postinst() {
	ebegin "Creating etcd user"
	enewgroup etcd
	enewuser etcd -1 -1 /var/lib/etcd etcd

	if [ ! -d ${ETCD_DATA_DIR} ]; then
		mkdir ${ETCD_DATA_DIR}
		chown etcd:etcd ${ETCD_DATA_DIR}
	fi

	elog "Starting with version 2, etcd does not support conf-Files. Instead it"
	elog "is now possible to provide ENVIRONMENT variables to the etcd process"
	elog "via the the file at /etc/etcd/etcd.env. You can provide one variable"
	elog "and value per line. For more information on the configuration options"
	elog "please see https://github.com/coreos/etcd/blob/master/Documentation/configuration.md#configuration-flags"
}
