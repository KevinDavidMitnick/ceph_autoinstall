#!/bin/sh
host=$1
#addr=$2

monmaptool --create --add NodeA 192.168.0.207  --add NodeB 192.168.0.208 --add NodeC 192.168.0.209 --fsid d5a3e28d-1274-462a-b932-7011bbbd11c8 --clobber /tmp/monmap
mkdir /var/lib/ceph/mon/ceph-${host}
ceph-mon --mkfs -i ${host} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
touch /var/lib/ceph/mon/ceph-${host}/done
chown -R ceph:ceph   /etc/ceph /var/lib/ceph
systemctl reset-failed ceph-mon@${host}
systemctl start ceph-mon@${host}
