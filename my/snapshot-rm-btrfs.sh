#!/bin/sh


case $1 in
	--) shift;;
	--help) printf %s\\n "Usage: $0 <subvol-dir>..."; exit;;
	-*) printf %s\\n >&2 "no options, see --help for usage"; exit 2;;
esac


errs=0
fail() {
	case ${1+1} in 1)
		printf %s\\n >&2 "$0: fail: $1"
	esac
	errs=$(( errs + 1 ))
}

for i; do
	btrfs subvolume delete "$i" || fail "when removing '$i'"
done

case $errs in
	0) exit 0;;
	*) printf %s\\n "$0: $errs errs"; exit 1;;
esac

