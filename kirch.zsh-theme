# kirch zsh theme

autoload -Uz vcs_info

#}}}-----------------------------
# setup prompt
#------------------------------{{{

# OS_RELEASE=$(grep -oP '^NAME="\K[^ "]+' /etc/os-release)
# setup our color scheme...
_cr='\e[0;31m' # color red
_cc='\e[0;36m' # color cyan
_cw='\e[1;37m' # color white
_nc='\e[0m'    # no color
# reuse the colors, but in the format the prompt expects
__cr="%{%F{red}%}" # color red
__cc="%{%F{cyan}%}" # color cyan
__cw="%{%F{white}%}" # color white
__nc="%{%F{none}%}"   # no color

# draw horizontal rule with the directory name & git status in it
precmd() {
  echo
  # printf '\e[0;31m%*s\n\e[m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '=' # ASCII-only
  # printf '\e[0;31m%*s\n\e[m' "${COLUMNS:-$(tput cols)}" '' | sed 's/ /═/g' # Unicode
  vcs_info
  ## use ddate if available
  if command -v ddate > /dev/null 2>&1
  then
    dd=$(ddate  +"%d/%B/%Y %N(%H)")
    dt=$(date +"%a %T %p")
    __dtstamp="$dd $dt"
  else
  ## otherwise show "Gregorian" date
    __dtstamp=$(date +"%a %d/%B/%Y %T %p")
  fi
  # Get directory (and git-prompt)
  DIR=$(pwd | sed -e "s!$HOME!~!")
  PRE="${DIR} ${vcs_info_msg_0_}"
  PRE=$(echo "$PRE" | xargs) # trim whitespace
  WID="${COLUMNS:-$(tput cols)}" # get column count from the term, or tputs
  # 7 = magic number of characters NOT to include in the HR width
  # (by counting how many characters the unicode adds, or trial & error)
  # PREWID=$(((${#PRE} + ${#OS_RELEASE} + ${#__dtstamp} + 12) % WID))
  PREWID=$(((${#PRE} + ${#__dtstamp} + 7) % WID))
  printf '\e[0;31m╔═╡\e[m\e[0;36m%s\e[0;31m╞' "$PRE"
  # instead of filling a column with spaces then replacing the spaces,
  # let's draw directly counting from PREWID+1 to the full width
  printf '\e[0;31m%.0s═\e[m' $(seq $((PREWID + 1)) "${WID}")
  printf '\e[0;31m═╡\e[m \e[0;36m%s' "$__dtstamp"
  # printf '\e[0;31m ╞═╡\e[m \e[0;36m%s\n' "$OS_RELEASE"
  echo -e '\n\e[0;31m║\e[m'
  # construct the same prompt as below, but more intelligently
  PS1="$__cr╚╡$__cc%(1j.${__cr}[${__cc}%j${__cr}]${__cc} .)"
  [ -z "$STY$TMUX" ] && PS1+="%n@%m"
  [ -e "${VIMRUNTIME}" ] && PS1+="${__cr}(${__cc}vim${__cr})${__nc}"
  PS1+="$__cc\$▸ $__nc"
  export PS1
}

# set prompt
PROMPT="$(pre_cmd)$PS1"

