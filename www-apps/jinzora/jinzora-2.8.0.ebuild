# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator webapp depend.php

MY_PV="$(delete_all_version_separators ${PV} )"

DESCRIPTION="Web-based media streamer, designed to stream mp3s (or any streaming capable media/video)"
HOMEPAGE="http://www.jinzora.org/"
SRC_URI="mirror://sourceforge/${PN}/jz${MY_PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="mssql mysql postgres sqlite"

DEPEND=""
RDEPEND="virtual/httpd-cgi"

need_php_httpd

MY_PVS="$(get_major_version)"
S=${WORKDIR}/${PN}${MY_PVS}

pkg_setup() {
	local flags
	has_php

	for i in mssql mysql postgres ; do
		use ${i} && flags="${flags} ${i}"
	done
	if [[ -n ${flags} ]] ; then
		diemsg="${flags} and either gd or gd-external in USE."
	else
		diemsg="either gd or gd-external in USE."
	fi

	if ( [[ -n ${flags} ]] && ! PHPCHECKNODIE="yes" require_php_with_use ${flags} ) || \
		! PHPCHECKNODIE="yes" require_php_with_any_use gd gd-external ; then
			die "Re-install ${PHP_PKG} with ${diemsg}"
	fi
	use sqlite && require_sqlite
	webapp_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix default locations
	for file in docs/english/lofi.html install/defaultsettings.php \
		services/services/tagdata/getid3/module.audio.shorten.php lib/snoopy.class.php ; do
			sed -i -e "s:/usr/local:/usr:g" ${file} || die "sed failed"
	done
}

src_install() {
	webapp_src_preinst

	# install htdocs
	touch "${S}"/settings.php
	cp -R . "${D}"/${MY_HTDOCSDIR}

	webapp_configfile ${MY_HTDOCSDIR}/settings.php
	for a in $(find .  -name settings.php); do
		webapp_serverowned ${MY_HTDOCSDIR}/${a};
	done
	for b in $(find {data,temp} -type d); do
		webapp_serverowned ${MY_HTDOCSDIR}/${b};
	done

	webapp_postinst_txt en "${FILESDIR}"/postinstall-en.txt
	webapp_src_install
}

pkg_postinst() {
	elog
	elog "${PN} can optionally utilize the following applications:"
	elog "\t media-sound/lame (lame)"
	elog "\t media-libs/flac (flac)"
	elog "\t media-sound/mpc (mppdec)"
	elog "\t media-sound/wavpack (wavunpack)"
	elog "\t media-sound/vorbis-tools (oggdec, oggenc)"
	elog "\t media-sound/shorten (shorten)"
	elog "\t media-video/mplayer (faad)"
	elog
	elog "Emerge the above ebuilds if you want those optional features!"
	elog
	webapp_pkg_postinst
}
