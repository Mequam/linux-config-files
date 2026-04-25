# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

#for awesome transparency
#exec transset-df 0.8 -a > /dev/null &

export GPG_TTY=$(tty)

export PNPM_HOME="/Users/dkennamer/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

setopt PROMPT_SUBST

alias ip="ip --color=auto"
alias fzf="fzf --tmux=center"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

alias python="python3"
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach-session -t default || tmux new-session -s default
fi


function getCurrentGitBranch() {
   git branch | grep \* | cut -d' ' -f2-
}

#fuzzy selects a branch from the given git dir
function fzSelectBranch() {
   git branch ${@} --all | fzf --tmux=center | tr -d ' *+' | sed 's,^remotes/[a-zA-Z]*/,,'
}

#selects a worktree branch
function fzSelectWorktreeBranch() {
   git worktree list | awk '{print $3}' | tr -d '\]\[' | fzf
}

function fzSelectWorktreePath() {
   if pathEnd=$(git worktree list | awk '{print $1}' | rev | cut -d/ -f1 | rev | fzf); then
      git worktree list | grep ".*/$pathEnd" | awk '{print $1}'
   else
      return 1
   fi
}

function fr() {
   fd $3 --type file -x sed -I.savedoldfiles s,$1,$2,g

   #if we are in a git repo remove the .old files, git tracks for us
   git rev-parse --show-toplevel 2>/dev/null >/dev/null && fd .savedoldfiles --type file -x rm
}

#takes a branch and returns the worktree path if it exists or errors
function getWorktreePath() {
   if WORKTREE_INFO=$(git worktree list | grep \\\[$1\\\]$); then
      echo $WORKTREE_INFO | cut -d' ' -f1
   else
      return 1
   fi
}


function getCurrentGitWorktree() {
   getWorktreePath $(getCurrentGitBranch)
}
function gtr {
   if TOP_GIT_REPO=$(git rev-parse --show-toplevel); then
      cd $TOP_GIT_REPO
   fi
}

function wcd() {
   if WORKTREE_PATH=$(fzSelectWorktreePath); then
      cd $WORKTREE_PATH
   else
      echo "no selection made"
   fi
}

#selects a node package that is a descendent of the current tree
function fuzzySelectPackage {
   find . -name node_modules -type d -prune -o -name package.json -print | \
      rev | cut -d/ -f2- | rev | \
      fzf
}

#navigate to a package in the current git tree
function pcd {
   if TOP_GIT_REPO=$(git rev-parse --show-toplevel); then
      prev_directory=$(pwd)
      cd $TOP_GIT_REPO
      if SELECTION=$(fuzzySelectPackage); then
         cd $SELECTION
      else
         echo "no selection made, canceled"
         cd $prev_directory
      fi
   fi
}


function noteto {
   cd ~/Documents/notes/primary_zk
   zk edit -i
}
function notenew {
   cd ~/Documents/notes/primary_zk
   zk new --title $@
}

ZSH_THEME="copper-mn" # set by `omz`
CASE_SENSITIVE="true"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':omz:update' frequency 13
plugins=(ssh-agent git taskwarrior)
source $ZSH/oh-my-zsh.sh
source ~/.oh-my-zsh/plugins/git/git.plugin.zsh

alias c="clear"
alias k="exit"
alias vimdiff='nvim -d'
alias samgob='noglob samgob'
alias fzcd="cd \$(ls | fzf)"

function Pcd {
   if SELECTION=$(ls ~/ProgramingWorkshop | fzf --tmux=center | tr -d ' '); then
      if echo $SELECTION | grep '^.*-tree$' >/dev/null 2>/dev/null; then
         devPath=$(echo ~/ProgramingWorkshop/$SELECTION/develop)
         echo "$devPath END"
         if [ -d $devPath ]; then
            cd $devPath
         else
            cd ~/ProgramingWorkshop/$SELECTION
         fi
      else
         cd ~/ProgramingWorkshop/$SELECTION
      fi
   else
      echo "canceled"
   fi
}

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

pnpm () {
   if [ "$1" = "clean" ]
   then
      echo 'find . -name node_modules -type d -prune -exec rm -rf {} +'
      find . -name node_modules -type d -prune -exec rm -rf {} +
   elif [ "$1" = "clean:dist" ]
   then
      echo 'find . -name node_modules -type d -prune -o -name dist -type d -exec rm -rf {} +'
      find . -name node_modules -type d -prune -o -name dist -type d -exec rm -rf {} +
   elif [ "$1" = "restart" ]; then
      pnpm clean
      pnpm clean:dist
      pnpm i
   elif [ "$1" = "i" ] #install frozen dependencies
   then
      echo "defaulting to frozen lockfile, use 'pnpm u' to update deps"
      command pnpm i --frozen-lockfile "${@:2}"
   elif [ "$1" = "u" ]
   then
      command pnpm i "${@:2}" #update the dependencies of the repo
   else
      command pnpm $@
   fi
}


git () {
	if [ "$1" = "tree" ]
	then
		command git log --oneline --graph --decorate-refs-exclude=refs/tags "${@:2}";
	elif [ "$1" = "lt" ]; #convinence function to get the latest version of a package
   then
      git tag --sort=taggerdate | grep $2 | tail -n 1
   elif [ "$1" = "slog" ] || [ "$1" = "sl" ] || [ "$1" = "l" ];
   then
      git log --format="%h: %C(auto)%d"
   elif [ "$1" = "lts" ];
   then
      git show $(git lt $2)
	elif [ "$1" = "ltc" ];
   then
      if SELECTION=$(git lt $2); then
         echo "[lts] found $SELECTION, checking out now!\n"
         git checkout $SELECTION
      else
         echo "[lts] package $2 not found\2"
      fi
	elif [ "$1" = "fzv" ];
   then
      if SELECTION=$(git tag --sort=-taggerdate | fzf); then
         git checkout $SELECTION
      else
         echo "no version selection made"
      fi
	elif [ "$1" = "tag" ];
   then
      if [ "$2" = "ls" ]; then
         command git tag --points-at $(git show $3 | grep ^commit | cut -d ' ' -f2)
      elif [ "$2" = "lt" ]; then
         git tag --sort=taggerdate | grep $3 | tail -n 1
      elif [ "$2" = "ltc" ]; then
         if SELECTION=$(git lt $3); then
            echo "[lts] found $SELECTION, checking out now!\n"
            git checkout $SELECTION
         else
            echo "[lts] package $3 not found\2"
         fi
      else
	      command git tag --sort=taggerdate "${@:2}"
      fi
	elif [ "$1" = "bcp" ];
   then
      if BRANCH=$(git branch | grep '\*' | cut -d' ' -f2-);
      then
         echo $BRANCH >&2
         echo $BRANCH | tr -d '\n' | pbcopy
      else
         echo "unable to copy branch, are you in a git repo?"
      fi
	elif [ "$1" = "fzc" ];
   then
      if BRANCH=$(fzSelectBranch ${@:2}); then
         if WORKTREE_PATH=$(getWorktreePath $BRANCH); then
            echo "[fzc] worktree to $WORKTREE_PATH"
            cd $WORKTREE_PATH
         else
            git checkout $BRANCH
         fi
      else
         echo "no selection made"
      fi
   elif [ "$1" = "fzw" ];
   then
      if BRANCH=$(fzSelectBranch ${@:2}); then
         if WORKTREE_PATH=$(getWorktreePath $BRANCH); then
            echo "[fzw] worktree to $WORKTREE_PATH"
            cd $WORKTREE_PATH
         else
            WORKTREE_PATH="$(git rev-parse --show-toplevel)/../$BRANCH"
            git worktree add $WORKTREE_PATH $BRANCH && cd $WORKTREE_PATH
         fi
      else
         echo "no selection made"
      fi
   elif [ "$1" = "wd" ]; then
      if WORKTREE_PATH=$(fzSelectWorktreePath); then
         echo "removing worktree..."
         git worktree remove $WORKTREE_PATH ${@:2}
         echo "removed $WORKTREE_PATH"
      else
         echo "no selection made"
      fi
   elif [ "$1" = "wj" ]; then #jump to a new worktree and delete the current one
      if NEXT_WORKTREE=$(fzSelectWorktreePath); then
         WORKTREE_TO_REMOVE=$(getCurrentGitWorktree)
         cd $NEXT_WORKTREE
         echo "removing worktree $WORKTREE_TO_REMOVE"
         git worktree remove --force $WORKTREE_TO_REMOVE
      else
         echo "no jump selection made"
      fi
	elif [ "$1" = "publish" ];
   then
      BRANCH=$(git branch | grep \* | tr -d ' *')
      git push --set-upstream origin $BRANCH
	elif [ "$1" = "fzr" ];
   then
      if SELECTION=$(git status --short | grep -v -e '^ [AMD]' -e '\\?\\?' -e '^U[DU]' -e '^D[DU]' | awk '{print $2}' | fzf --tmux=center);
      then
         git restore --staged $SELECTION
         git status #I do this after enough its worth automating away
      else
         echo "no selection made"
      fi

	elif [ "$1" = "fza" ];
   then
      if SELECTION=$(git status --short | grep -e '^ [AMD]' -e '\?\?' -e '^U[DU]' -e '^D[DU]' | awk '{print $2}' | fzf --tmux=center);
      then
         git add $SELECTION
         git status #I do this after enough its worth automating away
      else
         echo "no selection made"
      fi
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
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/dkennamer/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
