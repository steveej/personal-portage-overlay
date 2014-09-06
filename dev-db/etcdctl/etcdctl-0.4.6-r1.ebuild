EAPI=5
inherit git-2
inherit user
inherit systemd

DESCRIPTION="Control utility for ectd"
HOMEPAGE="https://github.com/coreos/etcdctl"
SRC_URI=""

SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

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
