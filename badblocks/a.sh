i=/dev/disk/by-id/usb-XinTop_XT-U33502_20220826-0\:0;
badblocks -w -s  -b 512 -v "$i" $(($(blockdev --getsz "$i") - 1)) $(($(blockdev --getsz "$i") - 100000000)) | tee  badsectors.txt | grep .  ; l
badblocks -w -s   -v "$i" | tee  badsectors.txt | grep .  ; l


# & clear; cat
