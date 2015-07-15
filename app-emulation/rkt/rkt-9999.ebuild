# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

AUTOTOOLS_AUTORECONF=yes
AUTOTOOLS_IN_SOURCE_BUILD=yes

inherit autotools-utils eutils flag-o-matic systemd toolchain-funcs

KEYWORDS=""

if [[ "${PV}" == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/coreos/rkt.git"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

DESCRIPTION="A CLI for running app containers, and an implementation of the App
Container Spec."
HOMEPAGE="https://github.com/coreos/rkt"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="doc examples rkt_stage1_coreos rkt_stage1_host +rkt_stage1_src +actool"
USE_REQUIRE="^^ ( rkt_stage1_coreos rkt_stage1_host rkt_stage1_src )"

DEPEND=">=dev-lang/go-1.4.1
	app-arch/cpio
	sys-fs/squashfs-tools
	dev-perl/Capture-Tiny
	rkt_stage1_host? (
		>=sys-apps/systemd-220
		app-shells/bash
	)"
RDEPEND="!app-emulation/rocket"

BUILDDIR="build-${P}"

src_configure() {
	local myeconfargs=(
		--with-stage1-image-path="/usr/share/rkt/stage1.aci"
	)

	if use rkt_stage1_host; then
		myeconfargs+=( --with-stage1="host" )
	fi
	if use rkt_stage1_src; then
		myeconfargs+=( --with-stage1="src" )
	fi
	if use rkt_stage1_coreos; then
		myeconfargs+=( --with-stage1="coreos" )
	fi

	# Go's 6l linker does not support PIE, disable so cgo binaries
	# which use 6l+gcc for linking can be built correctly.
	if gcc-specs-pie; then
		append-ldflags -nopie
	fi

	export CC=$(tc-getCC)
	export CGO_ENABLED=1
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CPPFLAGS="${CPPFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	export BUILDDIR

	autotools-utils_src_configure
}

src_install() {
	dodoc README.md
	use doc && dodoc -r Documentation
	use examples && dodoc -r examples
	use actool && dobin "${S}/${BUILDDIR}/bin/actool"

	dobin "${S}/${BUILDDIR}/bin/rkt"

	insinto /usr/share/rkt/
	doins "${S}/${BUILDDIR}/bin/stage1.aci"

	systemd_dounit "${S}"/dist/init/systemd/${PN}-gc.service
	systemd_dounit "${S}"/dist/init/systemd/${PN}-gc.timer
	systemd_dounit "${S}"/dist/init/systemd/${PN}-metadata.service
	systemd_dounit "${S}"/dist/init/systemd/${PN}-metadata.socket
}
