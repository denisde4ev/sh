
case ${0##*/}:$1 in require.sh:--help|require:--help)
command -v cat 2>/dev/null 1>&2 || {  set --; . "$0"; require cat lib:cat;  }
cat << EOF
usage: require <"\$var1 \$var2 fn1 fn2"> [=] <source-file>
* files once sourced will not be sourced again
* will make sure vars does not exist exist before sourcing
  and they do after sourcing, otherwise will give return status 5
* vars/fns are separated by IFS var
* when source-file is in lib:* then will source inside of dir \$require_libpath

this script is ment to be sourced by other shell scripts:
\`set -eu; . '$0'; require '\$var1' ./define-var1.sh; echo "\$var1"\`
EOF
exit
esac


: "${require_libpath:=/^/ https://github.com/denisde4ev/sh/tree/master}"

case $SYSTEMDRIVE in [A-Z]:)
	# try (requires on ash/bash pattern replacement) to fix windows path
	eval 'require_libpath=${SYSTEMDRIVE-}'"\${require_libpath//https:\/\//}" || :
esac


require() {
	case $#:$2 in
		3:=) set -- "$1" "$3";;
		2:*) ;;
		*) return 2;;
	esac
	case $1 in lib:*) set -- "$require_libpath/${1#lib:}" "$2"; esac

	local _require_tmp || :

	case :$_require_sourced: in *:"$2":*) ;; *)
		# set -f # dont: can not recover previous state in POSIX sh  (TODO not shure if its true)
		for _require_tmp in $1; do
			case $_require_tmp in # vars/fns must NOT exitst
				'$'*)
					eval "case \${${_require_tmp#\$}+x} in '') continue; esac"
					printf %s\\n >&2 "require: var ${_require_tmp#\$} is defined before require"
					unset _require_tmp; return 5
				;;
				*)
					case $(command -v "$_require_tmp") in */*|'') continue; esac
					printf %s\\n >&2 "require: fn $_require_tmp is defined before require"
					unset _require_tmp; return 5
				;;
			esac
		done
		_require_sourced=$_require_sourced:$2
		. "$2" || return
	esac

	for _require_tmp in $1; do
		case $_require_tmp in # vars/fns must exitst
			'$'*)
				eval "case \${${_require_tmp#\$}+x} in x) continue; esac"
				printf %s\\n >&2 "require: var ${_require_tmp#\$} is not defined after require"
				unset _require_tmp; return 5
			;;
			*)
				case $(command -v "$_require_tmp") in */*|'') ;; *) continue; esac
				printf %s\\n >&2 "require: fn $_require_tmp is not defined after require"
				unset _require_tmp; return 5
			;;
		esac
	done
}

case $(command -v local) in local) ;; *)
	require local lib:local;;
esac
