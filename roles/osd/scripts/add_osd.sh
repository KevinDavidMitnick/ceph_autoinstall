#!/bin/sh
host=$1
sdx=$2
jsize=$3
#parted disk,and mkfs
parted -s /dev/${sdx} mklabel gpt
parted -s /dev/${sdx} mkpart journal 1  ${jsize}G
parted -s /dev/${sdx} mkpart data    ${jsize}G -- -1
mkfs.xfs -f  /dev/${sdx}1
chown -R ceph:ceph /dev/${sdx}1
mkfs.xfs -f  /dev/${sdx}2

#create osd and mount
id=`ceph osd create`
mkdir /var/lib/ceph/osd/ceph-${id}
mount -t xfs -o "rw,noexec,nodev,noatime,nodiratime,nobarrier,inode64,logbufs=8,logbsize=256k,delaylog,allocsize=4M" /dev/${sdx}2  /var/lib/ceph/osd/ceph-${id}/
ceph-osd -i ${id} --mkfs --mkkey
rm -rf /var/lib/ceph/osd/ceph-${id}/journal
ln -s /dev/vdb1  /var/lib/ceph/osd/ceph-${id}/journal
ceph-osd --mkjournal -i ${id}
ceph auth add osd.${id} osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-${id}/keyring

#modify crush map
ceph osd crush add-bucket ${host} host
ceph osd crush move ${host} root=default
ceph osd crush add osd.${id} 1.0 host=${host}
ceph osd crush reweight osd.${id} 1.0
ceph osd in osd.${id}
chown -R ceph:ceph /var/lib/ceph/
systemctl reset-failed ceph-osd@${id}
systemctl start ceph-osd@${id}

uuid=`blkid /dev/${sdx}2|awk '{print $2}'`
echo "${uuid}  /var/lib/ceph/osd/ceph-${id} xfs    rw,noexec,nodev,noatime,nodiratime,barrier=0  0 0" >> /etc/fstab
