EAPI=5

inherit git-2 eutils ${EXTRA_ECLASS}

DESCRIPTION="A simple certificate manager written in Go. Easy to use with limited capability"
HOMEPAGE="https://github.com/coreos/etcd-ca"

EGIT_REPO_URI="https://github.com/coreos/etcd-ca.git"

EGIT_COMMIT="812f3626796be16d9db052720ce9c54f5a40bb26"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=">=dev-lang/go-1.2"

RDEPEND=""

src_compile() {
	./build
}

src_install() {
	dobin ${S}/bin/${PN}
}
