alias ls='ls --color=auto'
#
# /etc/bash.bashrc
#

export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

#gpg signs on the terminal
export GPG_TTY=$(tty)

[[ $DISPLAY ]] && shopt -s checkwinsize

#close on k for nice quick terminal exit
alias k="exit"
alias l="clear"

#set up PS1
PS1='\[\e[0;33m\][\[\e[1;33m\]\u\[\e[0;97m\]@\[\e[0;94m\]\h\[\e[0;33m\]]-[\[\e[0;00m\]\T\[\e[0;33m\]]-[\[\e[0;00m\]\j\[\e[0;33m\]]\[\e[0;00m\]\$\[\e[0;33m\]\n\[\e(0\]m\[\e(B\](\[\e[1;94m\]\W\[\e[0;33m\])>\[\e[0;00m\]\[\e[3 q\]'

#set up copy alias
alias copy="xclip -selection clipboard"
alias vsc="exec code -r"


case ${TERM} in
  xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'

    ;;
  screen*)
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
    ;;
esac

[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion

[ -f "/home/j0hn/.ghcup/env" ] && source "/home/j0hn/.ghcup/env" # ghcup-env

set -o vi

git () {
	if [ "$1" = "tree" ]
	then
		command git log --oneline --graph "${@:2}";
	elif [ "$1" = "login" ]
	then
		command eval $(ssh-agent); ssh-add ~/.keys/git_ssh_key
	else 
		command git "$@"
	fi
}

complete -C /usr/bin/terraform terraform
