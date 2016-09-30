#!/bin/bash
#安装chroot编译环境
DESTDIR=`pwd`
if [ "$1" == "powerpc" ]; then
    ARCH=powerpc
    QEMU_STATIC_BIN=qemu-ppc-static
    LIB_ARCH=powerpc-linux-gnu
    OPTION="--foreign --arch ${ARCH}"
elif [ "$1" == "armel" ]; then
    ARCH=armel
    QEMU_STATIC_BIN=qemu-arm-static
    LIB_ARCH=armel-linux-gnu
    OPTION="--foreign --arch ${ARCH}"
    #OPTION="--no-resolve-deps --variant minbase --foreign --arch ${ARCH}"
elif [ "$1" == "x86_64" ]; then
    ARCH=x86_64
    QEMU_STATIC_BIN=qemu-x86_64-static
    LIB_ARCH=x86_64-linux-gnu
    OPTION="--foreign --arch amd64"
elif [ "$1" == "arm64" ]; then
    ARCH=aarch64
    QEMU_STATIC_BIN=qemu-aarch64-static
    LIB_ARCH=aarch64-linux-gnu
    OPTION="--foreign --arch arm64"
else
    echo 'usage:'
    echo '       ./create_rootfs.sh {powerpc|armel|arm64|x86_64}'
    echo ' '
    exit 1
fi
SUITE=jessie
TARGET=${DESTDIR}/${ARCH}-rootfs
MIRROR=http://ftp.cn.debian.org/debian/
if [ -e /usr/bin/${QEMU_STATIC_BIN} ];then
    echo "find /usr/bin/${QEMU_STATIC_BIN} success"
else
    echo "cant find /usr/bin/${QEMU_STATIC_BIN},please:"
    echo 'sudo apt-get install qemu-user-static qemu'
    exit 1
fi
if [ -e ${TARGET} ];then
    echo "please rm  ${TARGET} first"
    exit 2
fi
echo "ARCH:            ${ARCH}"
echo "QEMU_STATIC_BIN: ${QEMU_STATIC_BIN}"
echo "LIB_ARCH:        ${LIB_ARCH}"
echo "OPTION:          ${OPTION}"
echo "SUITE:           ${SUITE}"
echo "TARGET:          ${TARGET}"
echo "MIRROR:          ${MIRROR}"
 
#清理工作
echo '#!/bin/bash' > clean.sh
echo "apt-get clean" >>clean.sh
echo "apt-get autoclean" >>clean.sh
echo "rm -rf /var/cache/apt/" >>clean.sh
echo "rm -rf /var/lib/apt/lists/" >>clean.sh
echo "rm -rf /usr/share/man/ /usr/share/info/ /usr/share/doc" >>clean.sh
echo "cd /usr/share/locale; find . -maxdepth 1 -type d | tail -n +2 | sed -e 's/\.\///g' | grep -E -v '^(en|currency|default|l10n).*' | while read d; do rm -rf \$d; done " >>clean.sh
chmod u+x clean.sh
#修改root密码
echo "#!/bin/sh" > changepasswd.sh
echo "passwd root <<EOF" >>changepasswd.sh
echo "root" >>changepasswd.sh
echo "root" >>changepasswd.sh
echo "EOF" >>changepasswd.sh
chmod u+x changepasswd.sh
#创建inittab
echo "::sysinit:/etc/init.d/rcS">inittab
echo "::askfirst:-/bin/login">>inittab
echo "tty1::askfirst:-/bin/login">>inittab
echo "tty2::askfirst:-/bin/login">>inittab
echo "::restart:/sbin/init">>inittab
echo "::ctrlaltdel:/sbin/reboot">>inittab
echo "::shutdown:/bin/umount -a -r">>inittab
echo "::shutdown:/sbin/swapoff -a">>inittab
 
CHROOT="sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C chroot "
LOCAL_CHROOT="${CHROOT} ${TARGET}"
    sudo debootstrap ${OPTION} ${SUITE} ${TARGET} ${MIRROR} \
    && sudo cp /usr/bin/${QEMU_STATIC_BIN} ${TARGET}/usr/bin/ \
    && sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C chroot ${TARGET}/ /debootstrap/debootstrap --second-stage \
    && ${LOCAL_CHROOT} sh -c 'echo "deb http://ftp.cn.debian.org/debian/ jessie main non-free contrib">/etc/apt/sources.list' \
    && ${LOCAL_CHROOT} sh -c 'echo "deb http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib">>/etc/apt/sources.list' \
    && ${LOCAL_CHROOT} sh -c 'echo "deb-src http://ftp.cn.debian.org/debian/ jessie main non-free contrib">>/etc/apt/sources.list' \
    && ${LOCAL_CHROOT} sh -c 'echo "deb-src http://ftp.cn.debian.org/debian/ jessie-updates main non-free contrib">>/etc/apt/sources.list' \
    && ${LOCAL_CHROOT} apt-get update \
    && ${LOCAL_CHROOT} apt-get --force-yes -y purge libboost-iostreams1.55.0 cpio cron gcc-4.8-base libgdbm3 \
       groff-base libicu52 init-system-helpers libxtables10 iptables libjson-c2 \
       libestr0 libidn11 liblogging-stdlog0 liblognorm1 libmnl0 libnetfilter-acct1 \
       libnfnetlink0 libpipeline1 libpsl0 libsigc++-2.0-0c2a libtext-charwidth-perl \
       libtext-iconv-perl libtext-wrapi18n-perl logrotate man-db manpages nano \
       netcat-traditional libnewt0.52 nfacct libssl1.0.0 libpopt0 tasksel-data tasksel wget \
       librtas1 librtasevent1 mac-fdisk powerpc-ibm-utils powerpc-utils yaboot debconf-i18n \
    && ${LOCAL_CHROOT} apt-get install --force-yes -y --no-install-recommends openssh-server \
       ftp telnet ssh libxslt1.1 libxml2 libidn11 librtmp1 libssh2-1 libldap-2.4-2 libcurl4-openssl-dev vim \
       tree openssl ntp  binutils gcc sudo psmisc gdb \
    && ${LOCAL_CHROOT} apt-get upgrade \
    && ${LOCAL_CHROOT} apt-get download busybox \
    && ${LOCAL_CHROOT} sh -c 'dpkg -X busybox*.deb /busybox' \
    && ${LOCAL_CHROOT} sh -c 'rm -f busybox*.deb' \
    && ${LOCAL_CHROOT} sh -c 'cp /busybox/bin/busybox /bin/busybox' \
    && ${LOCAL_CHROOT} sh -c 'rm -f /bin/login' \
    && ${LOCAL_CHROOT} sh -c 'ln -s /bin/busybox /bin/login' \
    && ${LOCAL_CHROOT} sh -c 'rm -f /sbin/sulogin' \
    && ${LOCAL_CHROOT} sh -c 'ln -s /bin/busybox /sbin/sulogin' \
    && ${LOCAL_CHROOT} sh -c 'rm -f /linuxrc' \
    && ${LOCAL_CHROOT} sh -c 'ln -s /bin/busybox /linuxrc' \
    && ${LOCAL_CHROOT} sh -c 'rm /sbin/init' \
    && ${LOCAL_CHROOT} sh -c 'ln -s /bin/busybox /sbin/init' \
    && ${LOCAL_CHROOT} sh -c 'rm -rf /busybox' \
    && sudo cp inittab ${TARGET}/etc/ \
    && sudo cp clean.sh ${TARGET}/ \
    && sudo cp changepasswd.sh ${TARGET}/ \
    && ${LOCAL_CHROOT} /clean.sh \
    && ${LOCAL_CHROOT} /changepasswd.sh \
    && sudo rm ${TARGET}/clean.sh \
    && sudo rm ${TARGET}/changepasswd.sh \
    && ${LOCAL_CHROOT} sh -c 'echo "pts/x" >> /etc/securetty' \
    && ${LOCAL_CHROOT} sh -c 'echo "CE" > /etc/hostname' \
    && ${LOCAL_CHROOT} sh -c 'echo "127.0.0.1 CE" >> /etc/hosts' \
    && ${LOCAL_CHROOT} sh -c 'hostname CE' \
    && ${LOCAL_CHROOT} sh -c 'sed -ie "s/^trap - EXIT # Disable emergency handler$/\/etc\/init.d\/ssh restart \ntrap - EXIT # Disable emergency handler/" /etc/init.d/rc' \
    && ${LOCAL_CHROOT} sh -c 'sed -ie "s/^PermitRootLogin without-password$/PermitRootLogin yes/" /etc/ssh/sshd_config' \
    && sudo rm ${TARGET}/usr/bin/${QEMU_STATIC_BIN} \
    && rm clean.sh changepasswd.sh inittab \
    && ROOTFS_NAME="${TARGET}-`date +'%Y-%m-%d-%H-%M'`".tar.gz \
    && echo ${ROOTFS_NAME} \
    && sudo tar -czf ${ROOTFS_NAME} ${TARGET}/ \
    && echo "create rootfs success!" \
    && exit 0
 
 
    echo "create rootfs failed!"
    exit 1
