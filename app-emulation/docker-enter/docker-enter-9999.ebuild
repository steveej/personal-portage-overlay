# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/openggsn/openggsn-9999.ebuild,v 1.1 2014/05/01 16:58:36 zx2c4 Exp $

EAPI=5

inherit git-2

DESCRIPTION="Let's a user enter an already running container"
HOMEPAGE="https://github.com/Pithikos/docker-enter/tree/master"
EGIT_REPO_URI="https://github.com/Pithikos/docker-enter.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="app-emulation/docker"

src_compile() {
	$(tc-getCC) ${LDFLAGS} ${CFLAGS} -o ${PN} ${PN}.c || die
}

src_install() {
	dodoc README.md
	dobin docker-enter
}

