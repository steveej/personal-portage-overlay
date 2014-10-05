# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 eutils ${EXTRA_ECLASS}

DESCRIPTION="U-Boot Sources"
HOMEPAGE=""

EGIT_REPO_URI="git://git.denx.de/u-boot.git"

LICENSE=""
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_configure () { 
	true 
}

src_compile () { 
	true
}

src_install() {
	insinto /usr/src/${PN}-${PVR}/
	doins -r *
}
