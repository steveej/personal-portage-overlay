# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 eutils ${EXTRA_ECLASS}

DESCRIPTION="A simple certificate manager written in Go. Easy to use with limited capability"
HOMEPAGE="https://github.com/coreos/etcd-ca"

EGIT_REPO_URI="https://github.com/coreos/etcd-ca.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND=">=dev-lang/go-1.2"
RDEPEND=""

src_compile() {
	./build || "Build failed"
}

# Will abort with following error:
# go tool: no such tool "cover"; to install:
# 	go get code.google.com/p/go.tools/cmd/cover
#src_test() {
#	./test || die 'Test failed'
#}

src_install() {
	dobin "${S}"/bin/"${PN}"

	dodoc README.md
	use doc && dodoc -r Documentation/*
}
