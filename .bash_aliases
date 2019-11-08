###########################
# iptables/firewall related
###########################
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
