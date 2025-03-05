#!/usr/bin/env bash

# TODO:
# - ask whether the script can run with sudo
# - redirect all outputs to /dev/null

# Arguments:
# $1 -

setup() {
    dnf install -y openssl crypto-policies crypto-policies-scripts
    openssl req -x509 -newkey rsa -keyout key.pem -out server.pem -days 365 -nodes -subj "/CN=localhost"
    openssl s_server -key key.pem -cert server.pem
} # > /dev/null

cleanup() {
    dnf history undo last -y
    rm key.pem server.pem
} # > /dev/null

