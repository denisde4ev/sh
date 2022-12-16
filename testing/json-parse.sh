#!/bin/sh


















# sh lib

set -eu


#json_spaces=$(printf '\t\n ') # just use IFS instead
#_line_eof='
#' # not used for now
json_types=oasnbN
# values: obj, array, string, nubmer, boolean, null
# keys
json_keyPattern=[a-zA-Z_0-9]


line_askNext() { # read like IF needed (only when line='' => line is cunsumed)
	case ${line-} in ?*) return; esac
	read -r line || \
	case $line in '')
		# destroy self:
		line_askNext() { case ${line-} in '') false; esac; }
		# line_trimStart() { true; } # DONT, reason: still can trim in last line

		return 1
		# _line_eof='' # not used for now 
	esac
}
line_trimStart() {
	line=${line#"${line%%[!"$IFS"]*}"}
}


_json_err() {
	printf %s\\n >&2 "error while ($1) in line: '$line'"
	exit "${2-2}"
}


json_parse() {
	set -- "${1-obj}"
	_json_lvl=0
	while line_askNext; do
		_json_parse_value "$1"
	done
}


# json_valueAfterEnd='' # too many shell bugs - do not store it in value
_json_parse_value() {
	# _json_current_parrentObj=$1 # this should stay in args

	line_trimStart

	_json_current_parsedValue=''
	unset _json_current_vanueType
	case $line in # parse value Begin
		\{*)    _json_parse_value_o "$1";;
		\[*)    _json_parse_value_a "$1";;
		[0-9]*) _json_current_vanueType=n; _json_parse_value_n;;
		\"*)    _json_current_vanueType=s; _json_parse_value_s;;
		true*)  _json_current_vanueType=b; _json_current_parsedValue=true;;
		false*) _json_current_vanueType=b; _json_current_parsedValue=false;;
		null*)  _json_current_vanueType=N; _json_current_parsedValue=null;;
		*)      _json_err "parsing begin of unrecognized value"
	esac || {
		_json_err "in pirsing type: $_json_current_vanueType"
	}

	case $_json_current_vanueType in
		o|a) ;; # object parsing is self consuming
		s)     line=${line#"\"$_json_current_parsedValue\""};;
		[nbN]) line=${line#"$_json_current_parsedValue"};;
		*)     _json_err "unimplemented line triming for type: _json_current_vanueType";;
	esac
	line_trimStart
	line_askNext || :
	line_trimStart

	(
		: DEBUG
		line=$line
		# json_valueAfterEnd=$json_valueAfterEnd
		case $line in \}*|\]*|\,*) echo true;; *) echo false; esac >&2
		: DEBUG END
	)
	case $line in
		\}*|\]*|\,*) true;;
		'') case $_json_lvl in 0) ;; *) false; esac;;
		*) false;;
	esac || {
		_json_err "parsing after end of value"
	}

	eval "
		json_objsT_${1}=\$_json_current_vanueType
		json_objsV_${1}=\$_json_current_parsedValue
	"
}

_json_parse_value_o() {
	_json_lvl=$(( _json_lvl + 1 ))
	# json_objs_"$json_current_name"
	line=${line#\{}
	line_trimStart

	_json_parse_value_o_currentKeys=''
	while :; do
		case $line in
			\}*) ;; # empty obj
			\"*) #fix"
				: key :
				{ # key
					_json_current_parsedKey=${line#\"} #fix"
					_json_current_parsedKey=${_json_current_parsedKey%%\"*} #fix"
					_json_current_parsedKey_trimStart
					line=${line#\"$_json_current_parsedKey\"} #fix"
					_json_parse_value_o_currentKeys=${_json_parse_value_o_currentKeys:+"$_json_parse_value_o_currentKeys,"}${_json_current_parsedKey}
				}
				: : :
				{ # :
					case $line in :*) ;; *)
						_json_err "parsng ':' after obj key"
					esac
					line=${line#:}
					line_trimStart
				}

				: value :
				{ # value
					_json_current_parsedKey_replace '_' '__'
					_json_parse_value "${1}_${_json_current_parsedKey}"
				}

				# expected '_json_parse_value' to end with value that does not need trimming or get_next
				##{
				##	line_trimStart
				##	line_askNext || break
				##	line_trimStart
				##}

				: \} :
				case $line in \}) break; esac
				: , :
				{ # ,
					line_trimStart
					case $line in ,*) ;; *)
						_json_err "expected '}' or ',' after obj value"
					esac
					line=${line#,}
					line_trimStart
				}
				: end paring 1 obj entry :
			;;
			#\,*) # TODO
		esac
		line_askNext || break
	done

	line=${line%\}}
	: end paring 1 obj :
	_json_current_vanueType=o
	_json_current_parsedValue=$_json_parse_value_o_currentKeys
	_json_lvl=$(( _json_lvl - 1 ))
}
_json_current_parsedKey_trimStart() {
	_json_current_parsedKey=${_json_current_parsedKey#"${_json_current_parsedKey%%[!"$IFS"]*}"} # trimStart
}
_json_current_parsedKey_replace() {
	_json_current_parsedKey_replaced=''
	while case $_json_current_parsedKey in *"$1"*) ;; *) false; esac; do
		_json_current_parsedKey_replaced=$_json_current_parsedKey_replaced${_json_current_parsedKey%%"$1"*}$2
		_json_current_parsedKey=${_json_current_parsedKey#*"$1"}
	done

	_json_current_parsedKey=$_json_current_parsedKey_replaced$_json_current_parsedKey
}


_json_parse_value_a() {
	_json_lvl=$(( _json_lvl + 1 ))
		_json_err "unimplemented fn: _json_parse_value_a"
	_json_lvl=$(( _json_lvl - 1 ))
}
_json_parse_value_s() {
	_json_current_parsedValue=${line#\"}
	_json_current_parsedValue=${_json_current_parsedValue%%\"*}

	# todo: parse back slash:  "\""
	# todo: parse backslash escape: "\u0000" = "\x00" = "\00"
	# todo: show warn about null chan - impossible to set as shell value 
}
_json_parse_value_n() {
	_json_current_parsedValue=${line%%[!0-9]*}
	# todo: parse _ as num separator (nothing special just improves readability)
	# todo: parse exponential
}

# just inline those:
# _json_parse_value_b() {
# 	case $line in
# 		true*)  _json_current_parsedValue=true;;
# 		false*) _json_current_parsedValue=false;;
# 		*) false;;
# 	esac
# }
# _json_parse_value_N() {
# 	_json_current_parsedValue=true
# }



case ${0##*/} in parse[_-]json|parse[_-]json.sh)
	json_parse "$@"
	set | grep ^json_objs
esac
