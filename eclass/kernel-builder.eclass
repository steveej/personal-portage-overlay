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

IUSE="make dracut genkernel minimal"

REQUIRED_USE="?? ( dracut genkernel )
dracut? ( make )"

DEPEND="dracut? ( sys-kernel/dracut )
	genkernel? ( || ( sys-kernel/genkernel sys-kernel/genkernel-next ) )"

KERNEL_CONFIG="kernel.config"
DRACUT_CONFIG="dracut.conf"
GENKERNEL_CONFIG="genkernel.conf"

DRACUT_ARGUMENTS="\
 --kmoddir ${ED}lib/modules/${KV} \
 --kver ${KV} \
 --tmpdir ${T} \
"
GENKERNEL_ARGUMENTS="\
 --compress-initramfs-type=gzip \
 --kerneldir=${S} \
 --logfile=${T}/genkernel.log \
 --no-symlink \
 --no-mountboot \
 --bootdir={ED}boot \
 --module-prefix=${ED} \
 --tempdir=${T} \
 --no-save-config \
 --bootloader=none \
"


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
		local savedconfig_files="${KERNEL_CONFIG}"
		if use dracut; then
			savedconfig_files+=" ${DRACUT_CONFIG}"
		elif use genkernel; then
			savedconfig_files+=" ${GENKERNEL_CONFIG}"
		fi
		elog "Restoring ${savedconfig_files}"
		restore_config ${savedconfig_files}
		mv ${S}/${KERNEL_CONFIG} ${S}/.config
	fi

	# Only seems to be needed for headers
	# kernel-2_src_compile 

	if use make; then
		ARCH=${KARCH} emake -j1 olddefconfig
		ARCH=${KARCH} emake all
	fi
}

kernel-builder_src_test() {
	kernel-2_src_test
}

kernel-builder_src_install() {
	local img_install_path=${ED}boot
	local initramfs_basefilename=initramfs-${KV}
	local initramfs_config=""

	# make kernel
	if use make; then
		mkdir -p ${img_install_path}

		# Install kernel image
		ARCH=${KARCH} INSTALL_PATH=${img_install_path} \
			emake -j1 install

		# Install modules
		if [[ $(grep CONFIG_MODULES=y .config) ]];then
			elog "Installing kernel modules"
			mkdir -p ${ED}/lib/modules
			ARCH=${KARCH} INSTALL_MOD_PATH=${ED} \
				emake -j1 modules_install
			rm ${ED}lib/modules/${KV}/build
			rm ${ED}lib/modules/${KV}/source
			ln -sf ${ROOT}usr/src/linux-${KV_FULL} ${ED}lib/modules/${KV}/build
			ln -sf ${ROOT}usr/src/linux-${KV_FULL} ${ED}lib/modules/${KV}/source
			depmod -b ${ED} ${KV}
		fi

		# Dracut initramfs
		if use dracut; then
			# Sandbox does not detect chroot'ed paths. See Bug 431038
			addwrite /etc/ld.so.cache
			addwrite /etc/ld.so.cache~
			if [[ -f ${DRACUT_CONFIG} ]]; then
				initramfs_config=${DRACUT_CONFIG}
				DRACUT_ARGUMENTS+=" --conf ${DRACUT_CONFIG}"
			fi
			elog Running dracut \ 
				${img_install_path}/${initramfs_basefilename}.img \
				${DRACUT_ARGUMENTS}
			dracut \
				${img_install_path}/${initramfs_basefilename}.img \
				${DRACUT_ARGUMENTS} || die

			mv ${DRACUT_CONFIG} \
				${img_install_path}/${initramfs_basefilename}-dracut.conf
		fi

		# Cleanup
		rm -Rf ${ED}/lib/firmware 2>&1 > /dev/null
		ARCH=${KARCH} emake -j1 clean
	fi

	if use genkernel; then
		mkdir -p ${img_install_path}
		if [[ -f ${GENKERNEL_CONFIG} ]]; then
			initramfs_config=${GENKERNEL_CONFIG}
			GENKERNEL_ARGUMENTS+=" --config ${GENKERNEL_CONFIG}"
		fi
		# Genkernel Initramfs
		if use make; then
			genkernel initramfs \
				"${GENKERNEL_ARGUMENTS}" || die
		# Genkernel all
		else
			ewarn "genkernel kernel build is not supported yet"
		fi

		mv ${DRACUT_CONFIG} \
			${img_install_path}/${initramfs_basefilename}-genkernel.conf
	fi

	if use minimal; then
		ewarn "Minimal install is not supported yet."
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
