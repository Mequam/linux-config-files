# user, host, full path, and time/date
# on two lines for easier vgrepping
# entry in a nice long thread on the Arch Linux forums: https://bbs.archlinux.org/viewtopic.php?pid=521888#p521888


#these are branches we use the describe format for
MAIN_BRANCHES=("master" "develop" "main")
is_main_branch() {
  for i in $MAIN_BRANCHES; do
  if [ "$i" = "$1" ]; then
    return 0
  fi
done
return 1
}

is_detached_head() {
  git branch | grep "* (HEAD detached at .*)" 2>/dev/null 1>&2
}


git_description() {
    if is_detached_head; then
      git describe
    else
      BRANCH=$(git branch 2>/dev/null | grep \* | awk '{print $2}')
      if is_main_branch $BRANCH && git describe 2>/dev/null 1>&2; then
          echo "$BRANCH-$(git describe)"
      else
        echo $BRANCH
      fi

    fi
}

in_git_repo() {
  git rev-parse --is-inside-work-tree 2>/dev/null 1>&2
}

generate_prompt() {
    if in_git_repo;
    then
      if [[ `git status --porcelain 2>/dev/null` ]];
      then
        echo "-[%B%{\e[1;20m%}$(git_description)*%{\e[0;33m%}]"
      else
        echo "-[%B%{\e[1;36m%}$(git_description)%{\e[0;33m%}]"
      fi
    fi
}
get_git_branch() {
  git status >/dev/null 2>/dev/null && generate_prompt
}

PROMPT=$'%{\e[0;33m%}%B┌─[%b%{\e[0m%}%{\e[1;33m%}%n%{\e[1;30m%}@%{\e[0m%}%{\e[0;34m%}%m%{\e[0;33m%}%B]-[%b%{\e[1;34m%}%1~%{\e[0;33m%}%B]-[%b%f'%D{"%a %H:%M:%S"}%b$'%{\e[0;33m%}%B]%b%{\e[0m%}%{\e[0;33m%}%B$(generate_prompt)
%{\e[0;33m%}%B└─>%B%{\e[0m%}%b '
