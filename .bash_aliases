###########################
# General
###########################
urlencode() { python -c "import urllib; print urllib.quote('''$1''', '')"; }

# To allow to visually differentiate STDOUT from STDERR
color() { "$@" 2>&1>&3|sed 's,.*,\x1B[31m&\x1B[0m,'>&2; } 3>&1

###########################
# iptables/firewall related
###########################
# TODO check is it really good practice to put 'sudo' in aliases definitions?.
function il {
sudo iptables -n -v --line-numbers -L $@
}
alias iln='sudo iptables -L -t nat -n -v --line-numbers '
alias il6='sudo ip6tables -L -n -v --line-numbers'

###########################
# PVE hosts related
###########################
# TODO try to provide the default password too, i.e. 'secret'.
alias console="sudo pct console $1 -escape '^l'"
