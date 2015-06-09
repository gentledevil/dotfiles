# if not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
[ -f /etc/bashrc ] && source /etc/bashrc

# Source auto-completion
for DIR in /etc /usr/share/bash-completion /usr/local/share/bash-completion; do
	[ -f ${DIR}/bash_completion ] && source ${DIR}/bash_completion
done

# set shell options
shopt -s autocd
shopt -s cdable_vars
shopt -u cdspell
shopt -s checkhash
shopt -s checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -u compat31
shopt -u compat32
shopt -u compat40
shopt -u compat41
shopt -u direxpand
shopt -u dirspell
shopt -s dotglob
shopt -s execfail
shopt -s expand_aliases
shopt -u extdebug
shopt -s extglob
shopt -s extquote
shopt -u failglob
shopt -s force_fignore
shopt -u globstar
shopt -s gnu_errfmt
shopt -s histappend
shopt -s histreedit
shopt -s histverify
shopt -s hostcomplete
shopt -s huponexit
shopt -s interactive_comments
shopt -u lastpipe
shopt -s lithist
shopt -u login_shell
shopt -u mailwarn
shopt -s no_empty_cmd_completion
shopt -u nocaseglob
shopt -u nocasematch
shopt -u nullglob
shopt -s progcomp
shopt -s promptvars
shopt -u restricted_shell
shopt -u shift_verbose
shopt -s sourcepath
shopt -u xpg_echo

# history
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=$HISTSIZE
CYAN=$(echo -e '\e[0;36m')
NORMAL=$(echo -e '\e[0m')
HISTTIMEFORMAT="${CYAN}[ %d/%m/%Y %H:%M:%S ]${NORMAL}  "

# umask, different if root
[ $UID != 0 ] && umask 027 || umask 022

### Environment ###

# locale
if [[ `locale -a | grep fr_FR.utf8` ]]
then
	export LANG=fr_FR.utf8
fi

### Aliases ###

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

### Functions ###

# set title
# adapted from http://v3.sk/~lkundrak/blog/entries/bashrc.html
set_title() {
	[ "$TERM" != "xterm-256color" ] && return
	TITLE="$@"

	if [ "$1" = fg ]
	then
		MATCH='^\[.*\]\+'
		[ -n "$2" ] && MATCH="$(echo $2 | sed 's/^%\([0-9]*\)/^\\[\1\\]/')"
		TITLE="$(jobs | grep "$MATCH" | sed 's/^[^ ]* *[^ ]* *//')"
	fi
	[ ! -z "$SSH_CONNECTION" ] && TITLE="[$USER@`hostname`] $TITLE"
	echo -ne "\e]0;$TITLE\007"
}

# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
cd_func () {
	local x2 the_new_dir adir index
	local -i cnt

	if [[ $1 ==  "--" ]]; then
		dirs -v
		return 0
	fi

	the_new_dir=$1
	[[ -z $1 ]] && the_new_dir=$HOME

	if [[ ${the_new_dir:0:1} == '-' ]]; then
		#
		# Extract dir N from dirs
		index=${the_new_dir:1}
		[[ -z $index ]] && index=1
		adir=$(dirs +$index)
		[[ -z $adir ]] && return 1
		the_new_dir=$adir
	fi

	#
	# '~' has to be substituted by ${HOME}
	[[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

	#
	# Now change to the new dir and add to the top of the stack
	pushd "${the_new_dir}" > /dev/null
	[[ $? -ne 0 ]] && return 1
	the_new_dir=$(pwd)

	#
	# Trim down everything beyond 11th entry
	popd -n +11 2>/dev/null 1>/dev/null

	#
	# Remove any other occurence of this dir, skipping the top of the stack
	for ((cnt=1; cnt <= 10; cnt++)); do
		x2=$(dirs +${cnt} 2>/dev/null)
		[[ $? -ne 0 ]] && return 0
		[[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
		if [[ "${x2}" == "${the_new_dir}" ]]; then
			popd -n +$cnt 2>/dev/null 1>/dev/null
			cnt=cnt-1
		fi
	done

	return 0
}

alias cd=cd_func

-() {
        cd -1
}
--() {
        cd -2
}
---() {
        cd -3
}

trap 'set +o functrace; set_title $BASH_COMMAND' DEBUG
PROMPT_COMMAND="history -a; set_title $SHELL"

source ~/.sh_common
