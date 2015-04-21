# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="Simulation of Multiprocessor Real-Time Scheduling with Overheads"
HOMEPAGE="http://homepages.laas.fr/mcheramy/simso/"
SRC_URI="http://homepages.laas.fr/mcheramy/simso/simulator.tar.gz -> ${P}.tar.gz"

LICENSE="CeCILL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

S="${WORKDIR}/SimSo"
RDEPEND="
~dev-python/simpy-2.3.1
>=dev-python/PyQt4-4.9[webkit]
>=dev-python/numpy-1.6"

#DEPEND="test? ( dev-python/pytest[${PYTHON_USEDEP}] )"
#
#python_test() {
#	esetup.py test
#}
