#!/bin/bash

install_deps() {
    curl https://get.mocaccino.org/luet/get_luet_root.sh | sudo sh
    sudo luet install -y repository/mocaccino-extra-stable
    sudo luet install -y utils/edgevpn container/k3s container/kubectl
}

start_vpn() {
    install_deps
    echo "$EDGEVPN" | base64 -d > config.yaml
    sudo -E EDGEVPNCONFIG=config.yaml IFACE=edgevpn0 edgevpn > /dev/null 2>&1 &
}

wait_master() {
    while ! nc -z $MASTER 6443; do  
        echo "K3s server not ready yet.." 
        sleep 1
    done
}

start_jumpbox() {
    sudo luet install -y utils/k9s container/kubectl
}

prepare_jumpbox() {
    wait_master
    curl http://$MASTER:9091/k3s.yaml | sed 's/127\.0\.0\.1/10.1.0.20/g' > k3s.yaml
}
