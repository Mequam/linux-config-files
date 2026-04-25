# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

#for awesome transparency
#exec transset-df 0.8 -a > /dev/null &

export GPG_TTY=$(tty)

setopt PROMPT_SUBST

alias ip="ip --color=auto"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

function noteto {
   cd ~/Documents/notes/primary_zk
   zk edit -i
}
function notenew {
   cd ~/Documents/notes/primary_zk
   zk new --title $@
}

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="copper-mn" # set by `omz`

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(ssh-agent git taskwarrior)
source $ZSH/oh-my-zsh.sh
source ~/.oh-my-zsh/plugins/git/git.plugin.zsh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias c="clear"
alias k="exit"
alias vimdiff='nvim -d'
alias samgob='noglob samgob'

gvim () {
   nvim --listen 127.0.0.1:55432
}

# custom docker commands
docker () {
   if [ "$1" = "fzf" ]
   then
      docker ps "${@:2}" | grep -v "CONTAINER" | fzf | awk $'{print $1}'
   elif [ "$1" = "start" ] || [ "$1" = "rm" ]
   then

      # docker start fzf command
      if [ "$2" = "fzf" ]
      then
         docker "$1" "${@:3}" $(docker ps --all | grep -v "CONTAINER" | fzf | awk $'{print $1}')
      else
         command docker "$@"
      fi


   elif [ "$1" = "stop" ]
   then

      # docker stop fzf command
      if [ "$2" = "fzf" ]
      then
         docker stop $(docker ps | grep -v "CONTAINER" | fzf | awk $'{print $1}') "${@:3}"
      else
         command docker "$@"
      fi

   elif [ "$1" = "image" ]
   then

      #check for image fzf
      if [ "$2" = "fzf" ]
      then
         docker image ls "${@:3}" | grep -v "REPOSITORY" | fzf | awk $'{print $3}'
      elif [ "$2" = "purge" ]
      then
         #remove all docker images that are not currently used in
         #containers
         
         for i in $(docker image ls | grep -v REP | awk $'{print $3}');
         do
            docker rmi $i;
         done

      else
         #run docker image per usual
         command docker "$@"
      fi

   elif [ "$1" = "run" ] || [ "$1" = "create" ] || [ "$1" = "rmi" ]
   then
      
      #docker run / create fzf / delete

      if [ "$2" = "fzf" ]
      then
         docker "$1" "${@:3}" $(docker image ls | grep -v "REPOSITORY" | fzf | awk $'{print $3}')
      else
         #run docker image per usual
         command docker "$@"
      fi

   else
      
      #default case we pass control back to docker
      command docker "$@"

   fi
}

git () {
	if [ "$1" = "tree" ]
	then
		command git log --oneline --graph "${@:2}";
	elif [ "$1" = "login" ]
	then
      find ~/.keys/git_login_keys/ -type l -exec ssh-add {} +
	elif [ "$1" = "it" ]
	then
		command git add -A; git commit
	elif [ "$1" = "push" ]
   then

      #if we push all loop over remotes and push everything
      if [ "$2" = "all" ]
      then
         for i in $(git remote)
         do
            echo "git push $i"
            git push $i
            echo "done \n"
         done
      else
         #run the push command normally
         command git "$@"
      fi
   elif [ "$1" = "fzd" ] #fuzzy diff!
   then
      # we default to only modified files
      FILE=$(command git diff --name-only "${@:2}" | (fzf || echo 0))
      WD=$(pwd)
      if [ $FILE -eq 0 ]
      then
         echo "no selection made"
      else
         echo $FILE
         
         cd $(command git rev-parse --show-toplevel) #git diff names are from the top directory

         command git difftool -y "${@:2}" -- "$FILE"

         cd $WD #go back to the directory we were originally at
      fi
   elif [ "$1" = "fzb" ]
   then
      #convinence command to grab a branch
      command git branch "${@:2}" | tr -d '* ' | fzf
	else
		command git "$@"
	fi
}
status () {
	git status ${@}
}
checkout () {
	git checkout ${@}
}
push () {
	git push ${@}
}
branch () {
	git --no-pager branch ${@}
}
reset () {
	git reset ${@}
}
difftool () {
	git difftool ${@}
}
gtree() {
	git tree ${@}
}
add() {
	git add ${@}
}
commit () {
	git commit ${@}
}
fetch (){
	git fetch ${@}
}
merge () {
	git merge ${@}
}
vimto () {
	nvim $(fzf)
}
# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
# shellcheck disable=SC2154
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

function z() {
    __zoxide_z "$@"
}

function zi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _files -/
        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Send '\e[0n' to console input.
            \builtin printf '\e[5n'
        fi

        # Report that the completion was successful, so that we don't fall back
        # to another completion function.
        return 0
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="z ${(q-)__zoxide_result}"
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete z
fi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually ~/.zshrc):
#
# eval "$(zoxide init zsh)"
#set up copy alias
alias copy="xclip -selection clipboard"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
