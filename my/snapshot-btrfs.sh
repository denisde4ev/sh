#!/bin/sh
case $1 in -x) set -x; shift; esac

{ # config (when no args -> as defalt args)
case $# in 0)
	case $PWD in /mnt/@) ;; *)
		printf %s\\n >&2 "$0: for default config: bad pwd"
		exit 3
	esac
	set -- @home @rootfs
	# TODO: backup /boot (thats fat32).
	# todo: needs to detect if arg is btr system and then backup it
	# or /boot shold have some middleware btrfs subvol? 
esac
}

#printf %s\\n "NOTHING DONE HERE" >&2
#exit 123;

# for now run command in pwd. cd "${0%/*}" || exit

unset opt_f
case $1 in -f) opt_f=''; shift; esac



case $1 in
--help)
	#	`: "  -r remove all old snapshots"` \
	printf %s\\n \
		"usage: $0 [-f] [btr subvol]..." \
		"  make a snapshot of dir args and append \`date -I\` to end" \
	;
	;;
--)
	shift
	;;
-*)
	printf %s\\n >&2 "$0: unexpected '$1', no options supported, see --help"
	exit 2
esac


if [ -d snapshots ]; then
	ind=''
else
	unset ind
fi


snapshot_dir=snapshots/$(date -I)
[ -d "$snapshot_dir" ] || mkdir -v -- "$snapshot_dir"

errs=0
fail() {
	case ${1+1} in 1)
		printf %s\\n >&2 "$0: fail: $1"
	esac
	errs=$(( errs + 1 ))
}
for i; do
	case ${ind+d} in
		d) o=$snapshot_dir/$i;;
		*) o=$i-$(date -I);;
	esac
	[ ! -e "$o" ] || {
		case ${opt_f+f} in
		f)
			btrfs subvolume delete "$o" || \
			fail "failed to delete subvolume '$o'"
			continue
			;;
		*)
			fail "'$o' already exists"
			continue
			;;
		esac
	}
	btrfs subvolume snapshot "$i" "$o" || \
	fail "snapping subvol for '$o' failed ($?)"
done

case $errs in
	0) exit 0;;
	*) printf %s\\n "$0: $errs errs"; exit 1;;
esac
