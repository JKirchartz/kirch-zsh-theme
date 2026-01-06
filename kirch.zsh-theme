# kirch zsh theme

ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[cyan]%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[cyan]%}%{✚%G%}"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan'


### Prompt colour helpers
p_colour() {
  local colour=$1 || 'cyan'

  echo -n "%{%F{$colour}%}"
}

p_reset() {
  echo -n %{%f%}
}

### Prompt components

prompt_rule() {
  # if lolcat is available, make the rule prettier
  if (( $+commands[lolcat] )); then
    printf '\e[0;31m%*s\n\e[m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '#' | lolcat
  else
    printf '\e[0;31m%*s\n\e[m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '#'
  fi
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
    local user=`whoami`
    if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        echo -n "%n@%m"
    else
        echo -n "λ"
    fi
}

prompt_location() {
  where=$PWD
  home=$HOME
  work="$home/work"
  projects="$home/projects"

  where="${where/$work/Δ}"
  where="${where/$projects/π}"
  where="${where/$home/~}"

  echo -n "$where"
}
# Status:
# - was there an error
# - are there background jobs?
# - am I root
prompt_status() {
    local symbols
    symbols=()
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘%{%f%}"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{magenta}%}⚙%{%f%}"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡%{%f%}" || symbols+="%{%F{cyan}%} \$${%f%}"
    [[ -n "${VIMRUNTIME}" ]] && symbols+="(%F{white}V%F{red})"

    [[ -n "$symbols" ]] && echo -n "$symbols"
}

## Main prompt
build_prompt() {
    prompt_rule
    echo -n "`prompt_location` "
    p_colour red
    echo -n "──"
    p_reset
    echo -n " `git_super_status` "
    p_colour red
    echo -n "\n┌─ "
    p_reset
    p_colour cyan
    echo -n "`prompt_context`"
    p_colour red
    echo -n " ── "
    p_colour cyan
    echo -n "%W %*"
    p_colour red
    echo -n " ─ "
    p_reset
    p_colour cyan
    echo -n "%j"
    p_colour red
    echo
    RETVAL=$?
    echo -n "└── "
    p_colour cyan
    echo -n "%h"
    p_colour red
    echo -n " ─"
    p_colour cyan
    echo -n "`prompt_status`"
    echo -n ">"
    p_reset
}

PROMPT='%{%f%b%k%}$(build_prompt) '

precmd(){
    echo
}

preexec(){
    # printf '\e]0;%s [%s@%s: %s]\a' "$2" "${prompt_user}" "${prompt_host}" "${prompt_char}"		
}

# original prompt from zshrc:

# PS1=$'\n\n'"%F{white}%d $(git_super_status)"$'\n'"%F{red}┌─[%F{cyan}%n@%m%F{red}]-[%F{cyan}%D{%x %X}%F{red}]-[%F{cyan}%j%F{red}]"$'\n'"%F{red}└─[%F{cyan}%!%F{red}]-$__vim%F{cyan}%(#.#.$)>%F{white}%{$reset_color%}"
# PS2="%F{red}└─%F{cyan}>%{$reset_color%}"


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
pre_cmd() {
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
  PS1="$__cr╚╡$__cc"
  [ -e "$(jobs -p)" ] && PS1+="$__cr(${__cc}\j$__cr)$__cc"
  [ -z "$STY$TMUX" ] && PS1+="\u@\h"
  [ -e "${VIMRUNTIME}" ] && PS1+="${__cr}(${__cc}vim${__cr})${__nc}"
  PS1+="$__cc\$▸ $__nc"
  export PS1
}

# set prompt
# export PS0="$__cr╠╡$__nc" # returns before the output of a command
# PROMPT="$(__prompt)$__cr╚╡$__cc\u@\h$__cr$__cc\$$__cc▸ $__nc"
# export PS2="$__cc▸ $__nc"

