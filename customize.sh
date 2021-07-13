#!/usr/bin/env sh

PROJECT_ENTRY="customize.sh"

cron() {
  user_script="/data/app/etc/cronjob/custom.sh"
  if [[ -f ${user_script} ]];then
    . ${user_script}
  fi
}

_startswith() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep "^$_sub" >/dev/null 2>&1
}

_time() {
  date -u "+%s"
}

#a + b
_math() {
  _m_opts="$@"
  printf "%s" "$(($_m_opts))"
}

_usage() {
  echo "$@" >&2
  printf "\n" >&2
}

_exists() {
  cmd="$1"
  if [ -z "$cmd" ]; then
    _usage "Usage: _exists cmd"
    return 1
  fi

  if eval type type >/dev/null 2>&1; then
    eval type "$cmd" >/dev/null 2>&1
  elif command >/dev/null 2>&1; then
    command -v "$cmd" >/dev/null 2>&1
  else
    which "$cmd" >/dev/null 2>&1
  fi
  ret="$?"
  return $ret
}

installcronjob() {
  customsh="${HOME}/customize.sh"
  _CRONTAB="crontab"
  if ! _exists "$_CRONTAB" && _exists "fcrontab"; then
    _CRONTAB="fcrontab"
  fi
  _t=$(_time)
  random_minute=$(_math $_t % 60)
  if [[ ${random_minute} == "60" ]];then
    random_minute="0"
  fi
  if ! $_CRONTAB -l | grep "$PROJECT_ENTRY --cron"; then
      $_CRONTAB -l | {
        cat
        echo "$random_minute 0 * * * $customsh --cron > /dev/null"
      } | $_CRONTAB -
  fi
}

showhelp() {
  echo "Usage: $PROJECT_ENTRY <command> ... [parameters ...]
Commands:
  -h, --help               Show this help message.
  --install-cronjob        Install the cron job to renew certs, you don't need to call this. The 'install' command can automatically install the cron job.
  --cron                   Run cron job.
"
}

_process() {
  _CMD=""
    while [ ${#} -gt 0 ]; do
    case "${1}" in
    --help | -h)
      showhelp
      return
      ;;
    --install-cronjob | --installcronjob)
      installcronjob
      ;;
    --cron)
      cron
      ;;
    *)
      echo "Unknown parameter : $1"
      return 1
      ;;
    esac
    shift 1
  done
}

main() {
  [ -z "$1" ] && showhelp && return
  if _startswith "$1" '-'; then _process "$@"; else "$@"; fi
}
main "$@"
