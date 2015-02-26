# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit distutils-r1

DESCRIPTION="Python decorator for automatically assigning arguments to class
variables."
HOMEPAGE="https://github.com/steveeJ/python-easy_init"
SRC_URI="https://github.com/steveeJ/python-easy_init/archive/${PV}.tar.gz"

LICENSE="gpl3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_COMPAT=( python2_7 )

function_test() {
	esetup.py test
}
