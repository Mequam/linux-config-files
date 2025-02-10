# user, host, full path, and time/date
# on two lines for easier vgrepping
# entry in a nice long thread on the Arch Linux forums: https://bbs.archlinux.org/viewtopic.php?pid=521888#p521888
generate_prompt() {
    BRANCH=$(git branch | grep \* | awk '{print $2}')
    if [[ `git status --porcelain` ]];
    then
      echo "($BRANCH*)"
    else
      echo "($BRANCH)"
    fi
}
get_git_branch() {
  git status >/dev/null 2>/dev/null && generate_prompt
}

PROMPT=$'%{\e[0;33m%}%B┌─[%b%{\e[0m%}%{\e[1;33m%}%n%{\e[1;30m%}@%{\e[0m%}%{\e[0;34m%}%m%{\e[0;33m%}%B]-[%b%{\e[1;34m%}%1~%{\e[0;33m%}%B]-[%b%f'%D{"%a %H:%M:%S"}%b$'%{\e[0;33m%}%B]%b%{\e[0m%}
%{\e[0;33m%}%B└─%B%{\e[1;36m%}$(get_git_branch)%{\e[0;33m%}>%B%{\e[0m%}%b '
#PS2=$' \e[0;33m%}%B>%{\e[0m%}%b '
