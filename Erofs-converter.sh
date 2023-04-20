#!/bin/bash

#Usage:
#sudo bash Erofs-converter.sh [/path/to/system.img] 

umount d

set -ex
srcFile="$1"



cp "$srcFile" s-ab-raw.img

rm -Rf tmp
mkdir -p d tmp
e2fsck -y -f s-ab-raw.img
resize2fs s-ab-raw.img 5000M
e2fsck -E unshare_blocks -y -f s-ab-raw.img
mount -o loop,rw s-ab-raw.img d
(
	cd d
	
	
	cd system
		
		
		
	# Remove non use apex vndk
	rm -rf "system_ext/apex/com.android.vndk.v29"
	rm -rf "system_ext/apex/com.android.vndk.v30"
	rm -rf "system_ext/apex/com.android.vndk.v31"
	rm -rf "system_ext/apex/com.android.vndk.v32"
	

        # Remove Superuser 
	touch phh/secure
	rm bin/phh-su || true
	rm etc/init/su.rc
	#rm bin/phh-securize.sh || true
	rm bin/phh-root.sh || true
	rm -Rf priv-app/SuperUser || true
	rm -Rf {app,priv-app}/me.phh.superuser/ || true
	rm xbin/su || true
	
	
	cd ../d

	

)

sleep 1
rm -Rf s-erofs.img

mkfs.erofs -E legacy-compress -zlz4hc -d2 s-erofs.img d/
umount d
