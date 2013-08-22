# if not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
[ -f /etc/bashrc ] && source /etc/bashrc

# Source auto-completion
[ -f /etc/bash_completion ] && source /etc/bash_completion
[ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion

# make less more friendly for non-text input files, see lesspipe(1)
which lesspipe &>/dev/null && eval "$(SHELL=/bin/sh lesspipe)"
which lesspipe.sh &>/dev/null && eval "$(SHELL=/bin/sh lesspipe.sh)"

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
HISTTIMEFORMAT="[ %d/%m/%Y %H:%M:%S ]  "

# umask, different if root
[ $UID != 0 ] && umask 027 || umask 022

### Environment ###

# more colors to xterm
[[ $TERM==xterm ]] && export TERM=xterm-256color

# mail
export EMAIL="jonathan.lestrelin@gmail.com"
export MAILPATH=/var/spool/mail/$USER:$HOME/Mail
#export DEBFULLNAME="Jonathan Lestrelin"
#export DEBEMAIL="$EMAIL"

# locale
if [[ `locale -a | grep fr_FR.utf8` ]]
then
	export LANG=fr_FR.utf8
fi

export EDITOR=vim
export PAGER=less
export SYSTEMD_PAGER=cat
export GIT_PAGER=cat
export BROWSER=firefox
export PLAYER=mplayer

# less
export LESS=-wR

### Aliases ###

alias ls="ls -hp --group-directories-first"
alias ll="ls -l"
alias la="ls -a"
alias lx="ls -xb"           # sort by extension
alias lk="ls -lSr"          # sort by size, biggest last
alias lt="ls -ltr"          # sort by date, most recent last
alias lsb="ls -ail"
alias du="du -h"
alias df="df -h"
alias rm="rm -i"
alias cp="cp -i"
alias em="emacs -nw"
alias dmesg="dmesg -TL"
alias pysh="ipython -p sh"
alias http_server="python3 -m http.server"
alias smtp_server="python3 -m smtpd -n -c DebuggingServer"
alias say="espeak --stdin"
alias speak="xsel -o | espeak --stdin"
alias dire="espeak --stdin -v fr"
alias lire="xsel -o | espeak --stdin -v fr"
alias chromium_tor="chromium --proxy-server=socks://localhost:9050 --incognito"
alias vnc_server="x11vnc -noxdamage  -display :0 -24to32 -scr always -xkb -shared -forever -loop -ncache 12 >/dev/null"
alias mtn2="mtn . -f /usr/share/fonts/TTF/DejaVuSans-Bold.ttf -g 10 -j 100  -r 8 -h 200 -k 000000 -o.jpg -O thumbs -w 1280"
alias radio_Dogmazic="$PLAYER http://radio.musique-libre.org:8000/radio_dogmazic.ogg"
alias radio_404="$PLAYER http://www.erreur404.org/radio404.pls"
alias radio_FockNiouzes="$PLAYER http://www.fockniouzes.org/m3u/fockniouzes-ogg-128.m3u"
alias radio_OxyRadio="$PLAYER http://www.oxyradio.net/listen/hd-ogg.pls"

### Functions ###

mkcd() {
	mkdir -p "$1" && cd "$1"
}

smv() {
	scp $1 $2 && rm $1
}

sscp() {
	filename=$(echo $1 | cut -d ':' -f2)
	scp $1 . && scp $filename $2 && rm $filename 
}

img2txt() {
	cd ${TMPDIR-/tmp}

	import -depth 8 ocr.tif
	tesseract ocr.tif ocr -l fra
	cat ocr.txt | xsel -i -b
}

random_mac() {
	if [ "$1" == "" ] || [ "$1" == "--help" ]
	then
		echo "Usage: random_mac interface"
		return
	fi
	MAC=`echo $RANDOM | md5sum | sed -r 's/^(.{12}).*$/\1/; s/([0-9a-f]{2})/\1:/g; s/:$//;'`
	sudo ifconfig $1 down
	sudo ifconfig $1 hw ether $MAC
	if [ $? == 0 ]
	then
		echo "New mac address is $MAC"
	fi
	sudo ifconfig $1 up
}

function nbrename() {
	if [ "$1" == "--help" ]
	then
		echo "Usage: nb_rename [min_number_lenght] [prefix] [suffix]"
		return
	fi
	i=0
	IFS=$'\n'
	for filename in `ls -1v`
	do
		lenght=${1-3}
		prefix=$2
		suffix=${3-$(extname $filename)}
		i=$(($i +1))
		newname=$i
		while [[ $(echo -n $newname | wc -m) <$lenght ]]
		do
			newname=0$newname
		done
		newname=$prefix$newname$suffix
		mv $filename $newname && echo "$filename > $newname" || return 1
	done
}

function extname() {
	echo .$(echo "$1" | awk -F. '{print $NF}' -)
}

function chroot_init() {
	[ $1 ] && cd "$1"
	[[ $PWD == "/" || ! -d dev || ! -d proc || ! -d sys || ! -x bin/bash ]] && echo "Not in a chrootable place" && return
	sudo mount -o bind /dev dev
	sudo mount -o bind /proc proc
	sudo mount -o bind /sys sys
	sudo sh -c 'cat /etc/resolv.conf > etc/resolv.conf'
	sudo chroot .
}

function get_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

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

# show file descriptors pointing to flash plugin open videos
flash_videos()
{
        cd /proc/`pgrep -f flash`/fd && ls -l | grep /tmp/Flash
}

### Display ###

# prompt
[[ $UID != 0 ]] && USER_COLOR=32 || USER_COLOR=31
export PS1='┌─ \[\033[$(echo $USER_COLOR)m\]\u\[\033[33m\]@\h \[\033[36m\]\w\[\033[35m\] \[\033[31m\]\$\[\033[0m\]
└╼ '

# color
export CLICOLOR=true
if [[ "$TERM" == "xterm" || "$TERM" == "xterm-256color" ]]
then
	eval `dircolors ~/.dircolors`
	alias ls="`alias ls | cut -d \' -f 2` --color=auto"
	alias grep="grep --color=auto"
	alias egrep="egrep --color=auto"
	alias fgrep="fgrep --color=auto"
	alias tree="tree -C"
	which colordiff &>/dev/null && alias diff=colordiff
	export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
	export LESS_TERMCAP_md=$'\E[01;38;5;33m'  # begin bold
	export LESS_TERMCAP_me=$'\E[0m'           # end mode
	export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
	export LESS_TERMCAP_so=$'\E[01;31;5;31m'  # begin standout-mode - info box
	export LESS_TERMCAP_ue=$'\E[0m'           # end underline
	export LESS_TERMCAP_us=$'\E[38;5;31m'     # begin underline
fi

trap 'set +o functrace; set_title $BASH_COMMAND' DEBUG
PROMPT_COMMAND="set_title $SHELL"

### Source local definitions ###
source ~/.bashrc_local
