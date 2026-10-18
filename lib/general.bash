# Functions run as commands through bin/jhlp-run. Keep them compatible with bash 3.2 (macOS /bin/bash).

###########################
# General
###########################

jh_urlencode() { python -c "import urllib; print urllib.quote('''$1''', '')"; }

# To allow to visually differentiate STDOUT from STDERR
jh_color() { "$@" 2>&1>&3|sed 's,.*,\x1B[31m&\x1B[0m,'>&2; } 3>&1

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
