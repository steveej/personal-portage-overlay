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

IUSE="dracut genkernel"

REQUIRED_USE="?? ( dracut genkernel )"

DEPEND="dracut? ( sys-kernel/dracut )
	genkernel? ( || ( sys-kernel/genkernel sys-kernel/genkernel-next ) )"


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

	if use savedconfig; then
		local kernel_config="kernel.config"
		if use dracut; then
			INITRAMFS_CONFIG="dracut.conf"
		elif use genkernel; then
			INITRAMFS_CONFIG="genkernel.conf"
		fi
		local savedconfig_files="${kernel_config} ${INITRAMFS_CONFIG}"
		einfo "Restoring ${savedconfig_files}"
		restore_config ${savedconfig_files}
		mv ${S}/${kernel_config} ${S}/.config
	fi

	# Only seems to be needed for headers
	# kernel-2_src_compile 

	ARCH=${KARCH} emake -j1 olddefconfig
	ARCH=${KARCH} emake all
}

kernel-builder_src_test() {
	kernel-2_src_test
}

kernel-builder_src_install() {
	local img_install_path=${ED}/boot
	local initramfs_basefilename=initramfs-${KV}
	mkdir -p ${img_install_path}
	ARCH=${KARCH} INSTALL_PATH=${img_install_path} \
		emake -j1 install

	mkdir -p ${ED}/lib/modules
	ARCH=${KARCH} INSTALL_MOD_PATH=${ED} \
		emake -j1 modules_install

	if use dracut; then
		addpredict /etc/ld.so.cache~
		dracut \
			${img_install_path}/${initramfs_basefilename}.img \
			--conf ${INITRAMFS_CONFIG} \
			--kmoddir ${ED}/lib/modules \
			--tmpdir ${T} || die

	elif use genkernel; then
		addwrite /etc/ld.so.cache
		addwrite /etc/ld.so.cache~
		genkernel \
			initramfs \
			--config=${INITRAMFS_CONFIG} \
			--compress-initramfs-type=gzip \
			--kerneldir="${S}" \
			--logfile=${T}/genkernel.log \
			--no-symlink \
			--no-mountboot \
			--bootdir="${ED}"/boot \
			--module-prefix="${ED}" \
			--tempdir="${T}" \
			--no-save-config \
			--bootloader="none" || die
	fi

	if [[ -f ${INITRAMFS_CONFIG} ]]; then
		mv ${INITRAMFS_CONFIG} \
			${img_install_path}/${initramfs_basefilename}.conf
	fi

	rm -Rf ${ED}/lib/firmware
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
