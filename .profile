alias ls='ls --color=auto'
#
# /etc/bash.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ $DISPLAY ]] && shopt -s checkwinsize

#set up PS1
PS1='\[\e[0;33m\][\[\e[1;33m\]\u\[\e[0;97m\]@\[\e[0;94m\]\h\[\e[0;33m\]]-[\[\e[0;00m\]\T\[\e[0;33m\]]-[\[\e[0;00m\]\j\[\e[0;33m\]]\[\e[0;00m\]\$\[\e[0;33m\]\nL(\[\e[1;94m\]\W\[\e[0;33m\])>\[\e[0;00m\]'

#set up copy alias
alias copy="xclip -selection clipboard"


case ${TERM} in
  xterm*|rxvt*|Eterm|aterm|kterm|gnome*)
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'

    ;;
  screen*)
    PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
    ;;
esac

[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion


#display the screen fetch quickly
cat .printout.txt

timeouttype 'press any key to enter the terminal...' 1 || ~/.scripts/startup/start_gui_with_scripts.sh
