# Functions run as commands through bin/jhlp-run. Keep them compatible with bash 3.2 (macOS /bin/bash).

###########################
# General
###########################

jh_urlencode() { python -c "import urllib; print urllib.quote('''$1''', '')"; }

# To allow to visually differentiate STDOUT from STDERR
jh_color() { "$@" 2>&1>&3|sed 's,.*,\x1B[31m&\x1B[0m,'>&2; } 3>&1

# Pull this repository now; the post-merge hook then re-runs configure-profile.
jh_update_profile() {
  git -C ~/.jaime-hablutzel-linux-profile pull --ff-only && echo "Open a new terminal to load the changes."
}

# Kill my tmux server and all its sessions, e.g. to drop settings no longer in ~/.tmux.conf, then
# start the "ai" session again, detached, as an SSH login does. Run from inside tmux, it ends the
# current pane too; outside tmux, it then attaches the "human" session.
jh_tmux_reset() {
  # Survive the hangup kill-server sends to the panes when run from inside tmux.
  trap '' HUP
  tmux kill-server 2> /dev/null
  tmux new-session -d -s ai -n ai -c "$HOME" || return
  if [ -z "$TMUX" ]; then
    tmux new-session -A -s human
  fi
}

jh_mine () {
# TODO prompt for confirmation if I'm outside my home folder.
# TODO check if it works if we are the "root" user itself.
if [ -z "$SUDO_USER" ]; then
  # TODO check if sudo is always required here, e.g. could it be avoided if the current user owns the current directory?.
  sudo chown -R $USER .
else
  chown -R $SUDO_USER .
fi
}

###########################
# PVE hosts related
###########################
# TODO try to provide the container's console password too.
jh_console() { sudo pct console "$1" -escape '^l'; }

#########################
# Clipboard management
#########################

#c() {
#    if [[ $(uname) == "Darwin" ]]; then
#        pbcopy
#    else
#        xsel -b
#    fi
#}

# It is conflicting with Oh My Bash's 'p' alias. Keep it shutdown for now.
#p() {
#    if [[ $(uname) == "Darwin" ]]; then
#        pbpaste
#    else
#        xsel -b
#    fi
#}

jh_copyfullpath() {
    readlink -n -f "$1" | pbcopy
    echo "Full path copied to clipboard."
}

###########################
# iptables/firewall related
###########################
function jh_il {
# TODO if we are already USER=root, do not execute with "sudo" as it is not required. Maybe extract a function like: "sudo_if_not_root" and use it in this entire file.
sudo iptables -n -v --line-numbers -L $@
}

###########################
# sudo related
###########################

# Prints the user a NOPASSWD grant is for: the one I logged in as, also from a root shell opened
# with jh_super or sudo (then $USER is root and $SUDO_USER is me).
__jh_nopasswd_user() {
  local u
  if [ "$(id -u)" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    u=$SUDO_USER
    if [ -n "$SUDO_UID" ] && [ "$(id -u "$u" 2>/dev/null)" != "$SUDO_UID" ]; then
      echo "SUDO_USER ($u) does not match SUDO_UID ($SUDO_UID); refusing." >&2
      return 1
    fi
  else
    u=$(id -un)
  fi
  # Only plain names: sudo's includedir silently skips file names with a "." or ending in "~".
  case $u in
    '' | *[!a-z0-9_-]* | [0-9-]*)
      echo "Unexpected user name '$u'; refusing." >&2
      return 1 ;;
    root)
      echo "Refusing to grant root; run it as my own user, or from jh_super." >&2
      return 1 ;;
  esac
  id -u "$u" >/dev/null 2>&1 || { echo "No such user: $u" >&2; return 1; }
  printf '%s\n' "$u"
}

# Succeeds if $2 is a line jh_nopasswd_grant writes for user $1, with or without the NOTAFTER expiry
# that older versions did not add.
__jh_nopasswd_is_own_line() {
  local re="^$1 ALL=\\(ALL\\)( NOTAFTER=[0-9]{14}Z)? NOPASSWD: ALL\$"
  [[ $2 =~ $re ]]
}

# Formats the epoch time $1 in UTC with the date format $2, with GNU or BSD date.
__jh_utc_date() {
  date -u -d "@$1" "$2" 2>/dev/null || date -u -r "$1" "$2"
}

# Name of the systemd units that end the grant of user $1 where sudo has no NOTAFTER.
__jh_nopasswd_timer() {
  printf 'jhlp-nopasswd-expire-%s\n' "$1"
}

# Cancels the systemd timer that would end the grant of user $1, if there is one.
__jh_nopasswd_cancel_timer() {
  local unit
  command -v systemctl >/dev/null 2>&1 || return 0
  unit=$(__jh_nopasswd_timer "$1")
  sudo systemctl stop "$unit.timer" "$unit.service" >/dev/null 2>&1
  sudo systemctl reset-failed "$unit.timer" "$unit.service" >/dev/null 2>&1
  return 0
}

# Installs the sudoers line $2 as file $1, owned by root with mode 0440, and checks it with visudo.
__jh_nopasswd_stage() {
  local tmp ok=1
  tmp=$(mktemp) || return 1
  printf '%s\n' "$2" > "$tmp"
  sudo install -m 0440 -o 0 -g 0 "$tmp" "$1" && sudo visudo -cqf "$1" >/dev/null && ok=0
  rm -f "$tmp"
  return $ok
}

# Lets the current user (see __jh_nopasswd_user) run sudo without a password for a limited time,
# through /etc/sudoers.d/<user>.
jh_nopasswd_grant() {
  local u f staged line current hours=6 until verb=Granted timer= unit how='sudoers NOTAFTER'
  case ${1-} in
    -h | --help)
      cat <<'EOF'
Usage: jh_nopasswd_grant [HOURS]

Lets the current user run sudo without a password for HOURS hours (default 6), through
/etc/sudoers.d/<user>, whose sudoers NOTAFTER option ends the grant by itself. Where sudo has no
NOTAFTER (sudo before 1.8.20, sudo-rs), a systemd timer removes the file instead; without systemd,
the grant does not expire and a warning says so. Running it again renews the grant for HOURS hours
from now. jh_nopasswd_revoke ends it earlier.
EOF
      return 0 ;;
    '') ;;
    *[!0-9]* | 0* | ?????*)
      echo "HOURS must be a whole number from 1 to 9999: $1" >&2
      return 2 ;;
    *) hours=$1 ;;
  esac
  if [ $# -gt 1 ]; then
    echo "Usage: jh_nopasswd_grant [HOURS]" >&2
    return 2
  fi
  u=$(__jh_nopasswd_user) || return 1
  f=/etc/sudoers.d/$u
  if sudo test -e "$f" || sudo test -L "$f"; then
    current=$(sudo cat "$f")
    if ! __jh_nopasswd_is_own_line "$u" "$current"; then
      echo "Refusing to overwrite $f, which has other content:" >&2
      printf '%s\n' "$current" >&2
      return 1
    fi
    verb=Renewed
  fi
  if ! sudo grep -Eq '^[#@]includedir[[:space:]]+(/private)?/etc/sudoers\.d/?[[:space:]]*$' /etc/sudoers; then
    echo "/etc/sudoers does not include /etc/sudoers.d; nothing changed." >&2
    return 1
  fi
  until=$(($(date -u +%s) + hours * 3600))
  # Staged under a name with a "." (skipped by includedir), so it is never live until checked, then
  # renamed into place atomically. A broken sudoers file would lock sudo out entirely.
  staged="$f.jhlp-staged"
  line="$u ALL=(ALL) NOTAFTER=$(__jh_utc_date "$until" +%Y%m%d%H%M%SZ) NOPASSWD: ALL"
  if ! __jh_nopasswd_stage "$staged" "$line" 2>/dev/null; then
    line="$u ALL=(ALL) NOPASSWD: ALL"
    timer=1
    if ! __jh_nopasswd_stage "$staged" "$line"; then
      sudo rm -f "$staged"
      echo "Failed; nothing changed." >&2
      return 1
    fi
  fi
  __jh_nopasswd_cancel_timer "$u"
  if ! sudo mv -f "$staged" "$f"; then
    sudo rm -f "$staged"
    echo "Failed; nothing changed." >&2
    return 1
  fi
  if ! sudo visudo -cq >/dev/null; then
    echo "The full sudoers check failed after adding $f; removing it." >&2
    sudo rm -f "$f"
    return 1
  fi
  if [ -n "$timer" ]; then
    # The command holds no "$", which systemd would expand. It removes the file only if it still
    # holds just this line.
    unit=$(__jh_nopasswd_timer "$u")
    if [ -d /run/systemd/system ] && command -v systemd-run >/dev/null 2>&1 \
      && sudo systemd-run --quiet --unit="$unit" --on-active="${hours}h" /bin/sh -c \
        "grep -qxF '$line' '$f' && awk 'END { exit NR != 1 }' '$f' && rm -f '$f'"; then
      how="the systemd timer $unit.timer"
    else
      echo "Warning: this sudo has no NOTAFTER and no systemd timer could be set, so the grant does" \
        "not expire by itself; end it with jh_nopasswd_revoke." >&2
      echo "$verb NOPASSWD sudo for $u in $f, with no expiry."
      return 0
    fi
  fi
  echo "$verb NOPASSWD sudo for $u in $f until $(__jh_utc_date "$until" '+%Y-%m-%d %H:%M UTC')" \
    "($hours h, ended by $how)."
}

# Undoes jh_nopasswd_grant. Removes /etc/sudoers.d/<user> only if it holds a line that
# jh_nopasswd_grant writes, so a grant managed by someone else is never deleted.
jh_nopasswd_revoke() {
  local u f
  u=$(__jh_nopasswd_user) || return 1
  f=/etc/sudoers.d/$u
  __jh_nopasswd_cancel_timer "$u"
  if ! sudo test -e "$f" && ! sudo test -L "$f"; then
    echo "Nothing to revoke: $f does not exist."
    return 0
  fi
  if ! __jh_nopasswd_is_own_line "$u" "$(sudo cat "$f")"; then
    echo "Refusing to remove $f, which was not written by jh_nopasswd_grant:" >&2
    sudo cat "$f" >&2
    return 1
  fi
  # One sudo call: once the file is gone, sudo may need a password again.
  if ! sudo sh -c 'rm -f "$1" && visudo -cq >/dev/null' sh "$f"; then
    echo "Could not remove $f, or the sudoers check fails after removing it." >&2
    return 1
  fi
  echo "Revoked NOPASSWD sudo from $u: removed $f."
}

###########################
# Crypto related
###########################

# TODO gradually migrate all the following functions to crypto.bash. Maybe keep some of the current aliases as shortcuts to the new functions.

jh_osslpemcerts() {
    if [ "$#" -eq 0 ]; then
        openssl crl2pkcs7 -nocrl -certfile /dev/stdin | openssl pkcs7 -print_certs -text;
    else
        openssl crl2pkcs7 -nocrl -certfile "$1" | openssl pkcs7 -print_certs -text;
    fi
}

jh_crt_sh_pem_url_from_sha256() {
  html_fragment=$(curl -sf https://crt.sh/?q=$1 | grep "Download Certificate: <A href=\"") || return 1
  query=$(echo "$html_fragment" | sed -n 's/.*href="\([^"]*\)".*/\1/p')
  echo "https://crt.sh/$query"
}

# Since OpenSSL 3.0, the input encoding is detected automatically, so the -inform flag is not required anymore. See https://www.openssl.org/docs/man3.0/man1/openssl-format-options.html.
jh_osslcert() {
  local filenames=()
  local temp_files=()
  local default_options=(-noout -text)
  local extra_options=()
  local option_match_found=false

  # TODO ensure it plays nice with filenames that contain spaces or the '-' character, so the match for '-' below should always search for a preceding space. Should it look for the start of a word as well?
  for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
      option_match_found=true
    fi
    if ! $option_match_found; then
      if [[ "$arg" =~ ^[0-9A-Fa-f]{64}$ ]]; then
        sha256=$arg
        url=$(jh_crt_sh_pem_url_from_sha256 "$sha256")
        if [ $? -ne 0 ]; then
          echo "Warning: Could not find certificate for SHA-256 in crt.sh: $sha256" >&2
          echo
          continue
        fi
        temp_file=$(mktemp)
        temp_files+=("$temp_file")
        wget --quiet --content-disposition -O "$temp_file" "$url"
        arg="$temp_file"
      # TODO support 'https://'' in jh_osslcertordered and maybe other places.
      elif [[ "$arg" =~ ^https?:// ]]; then
        temp_file=$(mktemp)
        temp_files+=("$temp_file")
        wget --quiet --content-disposition -O "$temp_file" "$arg"
        arg="$temp_file"
      fi
      filenames+=("$arg")
    else
      extra_options+=("$arg")
    fi
  done

  if [ ${#filenames[@]} -eq 0 ]; then
    openssl x509 "${default_options[@]}" "${extra_options[@]}"
  elif [ ${#filenames[@]} -eq 1 ]; then
    openssl x509 -in "${filenames[0]}" "${default_options[@]}" "${extra_options[@]}"
  else
    for cert in "${filenames[@]}"; do
      echo "> $cert:"
      openssl x509 -in "$cert" "${default_options[@]}" "${extra_options[@]}"
      echo
    done
  fi

  for temp_file in "${temp_files[@]}"; do
    rm "$temp_file"
  done
}

# Encoding enforcing versions.
jh_osslpemcert() {
    jh_osslcert "$@" -inform PEM
}
jh_ossldercert() {
  jh_osslcert "$@" -inform DER
}

# TODO check if the variables inside, e.g. `cert` or `IFS` affect the outer scope.
# TODO check if I have written something similar in the past. Try to locate the script or program I made for ordering certificates and comparing them.
# TODO write some automated tests for this method because there is compliance risk involved if it malfuctions.
# TODO ensure it works with certificates without extensions at all (test OpenSSL 1.x and 3.x).
# TODO try to reuse `jh_osslcert` instead of invoking `openssl` directly.
jh_osslcertordered() {
  local filenames=()
  local default_options=(-noout -text)
  local extra_options=()
  local option_match_found=false

  # TODO ensure it plays nice with filenames that contain spaces or the '-' character, so the match for '-' below should always search for a preceding space. Should it look for the start of a word as well?
  for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
      option_match_found=true
    fi
    if ! $option_match_found; then
      filenames+=("$arg")
    else
      extra_options+=("$arg")
    fi
  done

  if [ ${#filenames[@]} -eq 0 ]; then
    cert=$(openssl x509 "${default_options[@]}" "${extra_options[@]}")
  else
    if [[ "${filenames[0]}" =~ ^https?:// ]]; then
      temp_file=$(mktemp)
      wget --no-check-certificate --quiet --content-disposition -O "$temp_file" "${filenames[0]}"
      cert=$(openssl x509 -in "$temp_file" "${default_options[@]}" "${extra_options[@]}")
      rm "$temp_file"
    else
      cert=$(openssl x509 -in "${filenames[0]}" "${default_options[@]}" "${extra_options[@]}")
    fi
  fi
  before_extensions=$(echo "$cert" | sed -n '/X509v3 extensions:/q;p')
  original_extensions=$(echo "$cert" | sed -n -e '/X509v3 extensions:/,/Signature Algorithm:/p')
  after_extensions=$(echo "$cert" | awk '/Signature Algorithm/{a=""} {a=a$0"\n"} END{print a}')

  local IFS=$'\n'
  ext_name_start_chars='[a-zA-Z0-9]'
  # Parallel arrays instead of an associative array, which bash 3.2 lacks. A repeated name replaces the earlier content.
  local ext_names=() ext_contents=() ext_key i found
  for ext in $(echo "$original_extensions" | grep -E "^ {12}$ext_name_start_chars"); do
    ext_content=$(echo "$original_extensions" | sed -n "/$ext/,/^            $ext_name_start_chars/p")
    IFS= read -rd '' ext_content < <(echo "$ext_content" | sed '$d')
    ext_key="$(echo "$ext" | sed -e 's/[[:space:]]//g')"
    found=false
    for i in "${!ext_names[@]}"; do
      if [ "${ext_names[$i]}" = "$ext_key" ]; then
        ext_contents[$i]="$ext_content"
        found=true
      fi
    done
    if ! $found; then
      ext_names+=("$ext_key")
      ext_contents+=("$ext_content")
    fi
  done
  sorted_extensions=""
  for ext in $(printf '%s\n' "${ext_names[@]}" | sort -V); do
    for i in "${!ext_names[@]}"; do
      if [ "${ext_names[$i]}" = "$ext" ]; then
        sorted_extensions="$sorted_extensions${ext_contents[$i]}"
      fi
    done
  done

  echo "$before_extensions"
  echo "        X509v3 extensions:"
  echo -n "$sorted_extensions"
  echo "$after_extensions"
}

function jh_osslcheckocsp() {
  if [ -f "$1" ]; then
    cert_file="$1"
  else
    cert_file=$(mktemp)
    local domain="$1"
    local port="${2:-443}"
    openssl s_client -showcerts -connect "${domain}:${port}" 2>/dev/null </dev/null | openssl x509 -outform PEM >"$cert_file"
  fi
  # TODO manage the case where the AIA CA Issuers is not present. Is it mandatory for the CABF?
  local issuer_file=$(mktemp)
  local issuer_url=$(openssl x509 -in "$cert_file" -noout -ext authorityInfoAccess | grep "CA Issuers" | awk -F 'URI:' '{print $2}')
  curl -s -o - "$issuer_url" | openssl x509 -inform DER >"$issuer_file"
  # TODO manage the case where the OCSP URl is not present. Ensure to display a clear error.
  local ocsp_url=$(openssl x509 -in "$cert_file" -noout -ocsp_uri)
  openssl ocsp -issuer "$issuer_file" -cert "$cert_file" -no_nonce -url "$ocsp_url" -resp_text
  rm "$issuer_file"
  # Remove the cert_file only if it was a temporary file.
  if [ "$1" != "$cert_file" ]; then
    rm "$cert_file"
  fi
}

function jh_osslreq(){
  # TODO try to remove the redundancy with the `jh_osslcert` function.
  local filenames=()
  local default_options=(-noout -text)
  local extra_options=()
  local match_found=false

  for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
      match_found=true
    fi
    if ! $match_found; then
      filenames+=("$arg")
    else
      extra_options+=("$arg")
    fi
  done

  if [ ${#filenames[@]} -eq 0 ]; then
    openssl req "${default_options[@]}" "${extra_options[@]}"
  elif [ ${#filenames[@]} -eq 1 ]; then
    openssl req -in "${filenames[0]}" "${default_options[@]}" "${extra_options[@]}"
  else
    for csr in "${filenames[@]}"; do
      echo "> $csr:"
      openssl req -in "$csr" "${default_options[@]}" "${extra_options[@]}"
      echo
    done
  fi
}

jh_osslretrievesslchain() {
  local url="$1"
  local domain port
  url="${url#*://}"
  if [[ $url =~ : ]]; then
    domain="${url%:*}"
    port="${url##*:}"
  else
    domain="$url"
    port=443
  fi
  domain="${domain%%/*}"
  openssl s_client -showcerts -connect "$domain:$port" < /dev/null | jh_osslpemcerts
}
