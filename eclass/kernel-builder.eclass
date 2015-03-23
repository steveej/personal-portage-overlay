# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Description: kernel-builder.eclass is an extention of kernel-2.eclass to include the ability to
#	actually build the kernel during merge.
#
# WARNING: Please don't inherit kernel-2 or mount-boot, all of that is already handled
#
# Maintainer: Zero_Chaos <zerochaos@gentoo.org>
#			  steveeJ <code@stefanjunker.de>

inherit kernel-2 mount-boot savedconfig

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_test src_install pkg_preinst pkg_postinst pkg_prerm pkg_postrm

IUSE="initramfs dracut genkernel"

REQUIRED_USE="initramfs? ( ^^ ( dracut genkernel ) )"

DEPEND="dracut? ( sys-kernel/dracut )
	genkernel? ( || ( sys-kernel/genkernel sys-kernel/genkernel-next ) )"

# What is $ED?
# GENKERNEL_OPTS="--kerneldir="${S}" --logfile=/dev/null --no-symlink \
# 				--no-mountboot --bootdir="${ED}"/boot --module-prefix="${ED}" \
# 				--tempdir="${T}" --no-save-config --makeopts="${MAKEOPTS}" \
# 				--bootloader=none"

MAKE_ARCH=${ARCH}

kernel-builder_pkg_setup() {
	kernel-2_pkg_setup
}

kernel-builder_src_unpack() {
	kernel-2_src_unpack
}

kernel-builder_src_compile() {
	if use build; then
		die "The 'build'-flag is set, aborting..."
	fi

	# kernel has no arch/amd64
	if [[ ${MAKE_ARCH} == "amd64" ]]; then
		MAKE_ARCH="x86_64"
	fi

	if use savedconfig; then
		local kernel_config="kernel.config"
		if use dracut; then
			INITRAMFS_CONFIG="dracut.config"
		elif use genkernel; then
			INITRAMFS_CONFIG="genkernel.config"
		fi
		local savedconfig_files="${kernel_config} ${INITRAMFS_CONFIG}"
		einfo "Restoring ${savedconfig_files}"
		restore_config ${savedconfig_files}
		mv ${S}/${kernel_config} ${S}/.config
	else
		ARCH=${MAKE_ARCH} emake -j1 defconfig
	fi

	# Only seems to be needed for headers
	# kernel-2_src_compile 

	ARCH=${MAKE_ARCH} emake all
}

kernel-builder_src_test() {
	kernel-2_src_test
}

kernel-builder_src_install() {
	local img_install_path=${D}/boot
	mkdir -p ${img_install_path}
	ARCH=${MAKE_ARCH} INSTALL_PATH=${img_install_path} \
		emake -j1 install

	mkdir -p ${D}/lib/modules
	ARCH=${MAKE_ARCH} INSTALL_MOD_PATH=${D} \
		emake -j1 modules_install

	if use dracut; then
		addpredict /etc/ld.so.cache~
		local dracut_tmpdir=${T}/dracut
		mkdir -p ${dracut_tmpdir}
		dracut \
			${img_install_path}/initramfs-$(make kernelversion).img \
			--conf ${INITRAMFS_CONFIG} \
			--kmoddir ${D}/lib/modules \
			--tmpdir ${dracut_tmpdir} || die
	elif use genkernel; then
		die "TODO: create initramfs with genkernel"
#		dodir /boot
#		dodir /lib/modules
#		#build out of tree with --kernel-outputdir=
#		genkernel all "${GENKERNEL_OPTS}"
#		#--install from src_install?
	fi

	kernel-2_src_install
}

kernel-builder_pkg_preinst() {
	kernel-2_pkg_preinst
	mount-boot_pkg_preinst
}

kernel-builder_pkg_postinst() {
	kernel-2_pkg_postinst
	mount-boot_pkg_postinst
}

kernel-builder_pkg_prerm() {
	mount-boot_pkg_prerm
}

kernel-builder_pkg_postrm() {
	kernel-2_pkg_postrm
	mount-boot_pkg_postrm
}
