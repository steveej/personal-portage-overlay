EAPI=5

inherit git-2 eutils ${EXTRA_ECLASS}

DESCRIPTION="A simple certificate manager written in Go. Easy to use with limited capability."
HOMEPAGE="https://github.com/coreos/etcd-ca"

EGIT_REPO_URI="https://github.com/coreos/etcd-ca.git"

EGIT_BRANCH="master"
if [[ ${PV} == *9999* ]]; then
	EGIT_COMMIT="master"
	KEYWORDS="~amd64"
elif [[ ${PV} == "20140907" ]]; then
	EGIT_COMMIT="812f3626796be16d9db052720ce9c54f5a40bb26"
	KEYWORDS="*"
fi


LICENSE="Apache"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/go-1.2"

RDEPEND=""

src_compile() {
	./build
}

src_install() {
	dobin ${S}/bin/${PN}
}
