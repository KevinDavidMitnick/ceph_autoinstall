-------------------------------------------
1.first of all,this is not perfect.i hope anyone can finished it.
2.when install,should run like: ansible-playbook -i hosts site.yaml --skip-tags="uninstall,erasure_code"
3.when you want to uninstall ,run like: ansible-playbook -i hosts site.yaml --tags=uninstall
4.all you need to do before above command is,finish hosts,disk.ini,group_vars/all,ceph.ini,crush_map.txt  5 files.
5.good luck.

