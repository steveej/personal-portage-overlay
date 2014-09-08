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
IUSE=""

DEPEND=">=dev-lang/go-1.2 app-text/ronn"

RDEPEND=""

src_compile() {
	ebegin "Building etcd"
	cd "${WORKDIR}"/etcd-"${PV}"
	if [ ! -h "${WORKDIR}"/etcd-"${PV}"/src/github.com/coreos/etcd ]; then
	mkdir -p "${WORKDIR}"/etcd-"${PV}"/src/github.com/coreos/
	ln -s ../../.. "${WORKDIR}"/etcd-"${PV}"/src/github.com/coreos/etcd
	fi
	export GOBIN="${WORKDIR}"/etcd-"${PV}"/bin
	export GOPATH="${WORKDIR}"/etcd-"${PV}"
	go install github.com/coreos/etcd
	go install github.com/coreos/etcd/bench
	ronn -m "${WORKDIR}"/etcd-"${PV}"/Documentation/configuration.md > "${T}"/etcd.1
	ronn -m "${WORKDIR}"/etcd-"${PV}"/Documentation/modules.md > "${T}"/etcd.2
	ronn -m "${WORKDIR}"/etcd-"${PV}"/Documentation/clustering.md > "${T}"/etcd.3
	ronn -m "${WORKDIR}"/etcd-"${PV}"/Documentation/api.md > "${T}"/etcd.4
	eend ${?}
}

src_install() {
	ebegin "Installing binaries and init scripts"
	dobin "${WORKDIR}"/etcd-"${PV}"/bin/etcd
	dobin "${WORKDIR}"/etcd-"${PV}"/bin/bench
	insinto /etc/"${PN}"
	doins "${FILESDIR}"/"${PN}".conf
	newinitd "${FILESDIR}"/etcd.initd etcd
	systemd_dounit "${FILESDIR}"/"${PN}".service
	systemd_dotmpfilesd "${FILESDIR}"/"${PN}".tmpdfsd.conf
	doman "${T}"/etcd.1
	doman "${T}"/etcd.2
	doman "${T}"/etcd.3
	doman "${T}"/etcd.4
	eend ${?}
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
	eend ${?}
}
