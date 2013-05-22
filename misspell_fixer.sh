#!/bin/bash

#ignore list, force run, cwd, wait

export opt_verbose=0
export opt_show_diff=0
export opt_fast_mode=0
export opt_real_run=0
export opt_backup=1

rules_safe=$(echo $0|sed 's/\.sh$/_safe.sed/')
rules_not_so_safe=$(echo $0|sed 's/\.sh$/_not_so_safe.sed/')
export cmd_part_rules="-f $rules_safe"

while getopts ":vrfdnuh" opt; do
	case $opt in
		v)
			echo "enabling verbose mode"
			opt_verbose=1
		;;
		r)
			echo "enabling real run. overwrite original files!"
			opt_real_run=1
		;;
		f)
			echo "enabling fast mode"
			opt_fast_mode=1
		;;
		d)
			echo "enabling showing of diffs"
			opt_show_diff=1
		;;
		n)
			echo "disabling backups"
			opt_backup=0
		;;
		u)
			echo "enabling unsafe rules"
			cmd_part_rules="$cmd_part_rules -f $rules_not_so_safe"
		;;
		h)
			cat $(dirname $0)/README.md�>&2
			exit
		;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit
		;;
	esac
done

if [[ $opt_fast_mode = 1 ]]
then
	if [[ $opt_real_run = 0 ]]
	then
		echo "fast mode works only with real run. Real run is not switched on. => Exiting"
		exit
	fi
	if [[ $opt_backup = 1 ]]
	then
		echo "fast mode cannot make backups. Backups are enabled. => Exiting"
		exit
	fi
	if [[ $opt_show_diff = 1 ]]
	then
		echo "fast mode cannot show diffs. Showing diffs is turned on. => Exiting"
		exit
	fi

	echo "starting script"
	if [[ $opt_verbose = 1 ]]
	then
		set -x
	fi
	find .\
		-type f\
		! -wholename '*.git*'\
		! -wholename '*.svn*'\
		-exec sed -i $cmd_part_rules {} +
	set +x
	echo "done"
	exit;
fi

function loop_core {
	if [[ $opt_verbose = 1 ]]
	then
		set -x
	fi
	tmpfile="$1.$$"
	sed $cmd_part_rules "$1" >"$tmpfile"
	samefile=0
	IFS=''
	diff=$(diff -uwb "$1" "$tmpfile" && samefile=1)
	if [[ $opt_show_diff = 1 ]]
	then
		echo $diff
	fi
	if [[ $samefile = 1 ]]
	then
		rm "$tmpfile"
	else
		if [[ $opt_real_run = 1 ]]
		then
			if [[ $opt_backup = 1 ]]
			then
				mv "$1" "$tmpfile.BAK"
			fi
			mv "$tmpfile" "$1"
		else
			rm "$tmpfile"
		fi
	fi
}
export -f loop_core

if [[ $opt_verbose = 1 ]]
then
	set -x
fi
find .\
	-type f\
	! -wholename '*.git*'\
	! -wholename '*.svn*'\
	-exec bash -c 'loop_core "$0"' {} \;