#!/bin/sh

_cat() {
	while read -r line; do # note: $line var can not have null char $'\0'
		printf %s\\n "$line"
	done
	printf %s "$line"
}

cat() {
	case $1 in --) shift; esac
	while case $# in 0) false; esac; do
		case $1 in 
			-) _cat;;
			*) _cat < "$1";;
		esac

		shift
	done
}

case ${0##*/}:$1 in
cat.sh:--help|cat:--help)
	echo 'Usage: cat [--] [FILE]...'
	;;
cat.sh:*|cat.sh:*)
	cat "$@"
esac
