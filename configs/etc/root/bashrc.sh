if [ -z "$PS1" ]
then
  return
fi

export EDITOR="vi"
export PAGER="less"
export CLICOLOR="1"
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export GREP_COLOR="1;32"
export IGNOREEOF="0"
export HISTSIZE="100000"
export HISTFILESIZE="100000"
export HISTCONTROL="ignoreboth"

shopt -s cmdhist
shopt -s checkwinsize
shopt -s histappend
shopt -s cdspell

complete -c command type which
complete -d cd
complete -cf sudo

alias ls="ls --color=auto"
alias lsa="ls -lahi"
alias l="ls -la"
alias ll="ls -alFh"
alias ..="cd .."
alias ...="cd ../.."
alias grep="grep --color=auto"
alias rgrep="grep -rn"
alias history="fc -l 1"

export ls_colors="--color=auto"
export time_style="--time-style=long-iso"
alias tf='command tail -f'
alias path='echo export PATH=$PATH'
alias fpath='echo export FPATH=$FPATH'
alias lpath='echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH'
alias ppath='echo $PATH | tr ":" "\n" | sort'
alias pfpath='echo $FPATH | tr ":" "\n" | sort'
alias plpath='echo $LD_LIBRARY_PATH | tr ":" "\n" | sort'

alias ll='ls -Alq -F ${ls_colors} ${time_style}'
alias lld='ls -Aldq -F ${ls_colors} ${time_style}'
alias lrt='ls -lArtq -F ${ls_colors} ${time_style}'
alias lrtd='ls -lArtdq -F ${ls_colors} ${time_style}'
alias lrth='ls -lArtq -F ${ls_colors} ${time_style}|head -20'
alias lrtt='ls -lArtq -F ${ls_colors} ${time_style}|tail -20'
alias lla='ls -lAq -F ${ls_colors} ${time_style}'
alias lrta='ls -lrtAq -F ${ls_colors} ${time_style}'

alias htrestart='. /etc/entrypoint.d/99-apache.sh;apachectl restart'
alias phprestart='/etc/owncloud.d/46-php-fpm.sh'
alias htlogs='tf /var/log/apache2/*'
alias nglogs='tf /var/log/nginx/*'
alias ngreload='nginx -t && service nginx reload'

alias ving='vi /etc/nginx/nginx.conf'
alias videf='vi /etc/nginx/sites-available/default'

if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
  function command_not_found_handle {
    if [ -x /usr/lib/command-not-found ]
    then
      /usr/lib/command-not-found -- "$1"
      return $?
    elif [ -x /usr/share/command-not-found/command-not-found ]
    then
      /usr/share/command-not-found/command-not-found -- "$1"
      return $?
    else
      printf "%s: command not found\n" "$1" >&2
      return 127
    fi
  }
fi

bash_prompt() {
  local NONE="\[\033[0m\]"

  local U="\[\033[01;32m\]"
  local R="\[\033[01;31m\]"
  local S="\[\033[01;37m\]"
  local H="\[\033[01;35m\]"
  local D="\[\033[01;34m\]"

  if [[ "${EUID}" == "0" ]] ; then
    export PS1="\n$R\u$S@$H\h: $D\w # $NONE"
  else
    export PS1="\n$U\u$S@$H\h: $D\w # $NONE"
  fi
}

bash_prompt && unset bash_prompt
