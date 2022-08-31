
case ${0##*/}:$1 in require.sh:--help|require:--help)
	printf %s\\n \
		"usage: require"' <"$var1 $var2 fn1 fn2"> [=] <source-file>' \
		"  * files once sourced will not be sourced again" \
		"  * will make sure vars does not exist exist before sourcing" \
		"    and they do after sourcing, otherwise will give return status 5" \
		"  * vars are separated by IFS var" \
		"" \
		"  this script is only ment to be sourced by other shell scripts:" \
		'  `set -eu; . '"$0"'; require '\''$var1'\'' ./define-var1.sh; echo "$var1";`' \
	;
	exit
esac

require() {
	case $#:$2 in
		3:=) set -- "$1" "$3";;
		2:*) ;;
		*) return 2;;
	esac

	case :$_require_sourced: in *:"$2":*) ;; *)
		# set -f # dont: can not recover previous state in POSIX sh  (TODO not shure if its true)
		for i in $1; do
			case $i in # must not exitst in this shell
				'$'*) eval "case \${${i#\$}+x} in x) printf %s\\\\n >&2 'require: var ${i#\$} is defined before require' ; return 5; esac";;
				*) case $(command -v "$i") in */*|'') ;; *)  printf %s\\\\n >&2 'require: fn $i is defined before require'; return 5; esac;;
			esac
		done
		_require_sourced=$_require_sourced:$2
		. "$2"
	esac

	for i in $1; do
		case $i in # must exitst in this shell
			'$'*) eval "case \${${i#\$}+x} in '') printf %s\\\\n >&2 'require: var ${i#\$} is not defined after require' ; return 5; esac";;
			*) case $(command -v "$i") in ''|*/*) printf %s\\\\n >&2 'require: fn $i is not defined after require'; return 5; esac;;
		esac
	done
}
