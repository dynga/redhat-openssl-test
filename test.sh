#!/usr/bin/env bash

print_help() {
    echo "OpenSSL TLS test suite assigned as Linux Security interview homework for Red Hat."
    echo "Usage: test.sh [TEST]"
    echo "       test.sh [OPTION]"
    echo "OPTION argument:"
    echo "-h --help - print this help screen"
    echo "-l --list - print all available tests"
    echo "TEST :"
    echo "Run with test name as the TEST argument to run a specific test."
    echo "Run without parameters to run all available tests."
}

setup() {
    echo "Performing test setup"
    {
    dnf install -y openssl crypto-policies crypto-policies-scripts
    openssl req -x509 -newkey rsa -keyout key.pem -out server.pem -days 365 -nodes -subj "/CN=localhost"
    openssl s_server -key key.pem -cert server.pem &
    export S_SERVER_PID=$!
    } &> /dev/null
}

cleanup() {
    echo "Performing test cleanup"
    {
    dnf history undo last -y
    kill -9 $S_SERVER_PID
    rm key.pem server.pem
    } &> /dev/null
}

list_tests() {
    declare -F | grep -oh "test_.*"
}

execute_single_test() {
    if $1; then
        echo "Test ${1} - PASS"
    else
        echo "Test ${1} - FAIL"
    fi
}

execute_all_tests() {
    for test in test_1 test_2 test_3; do
        execute_single_test $test
    done
}

test_1() {
    echo "This is test 1"
}

test_2() {
    echo "This is test 2"
}

test_3() {
    echo "This is test 3"
}


if [[ $EUID -ne 0 ]]; then
  echo "The script needs root priviledges to run."
  exit
fi

if [[ ! $(cat /etc/system-release) =~ "Fedora release 41" ]]; then
    echo "This test targets Fedora 41 exclusively."
    exit
fi

case $1 in
    -h|--help)
        print_help
        ;;
    -l|--list)
        echo "List of available tests:"
        list_tests
        ;;
    test_1 | test_2 | test_3)
        setup
        execute_single_test $1
        cleanup
        ;;
    *)
        if [[ $# -eq 0 ]]; then
            setup
            execute_all_tests
            cleanup
        else
            echo "Unknown argument found. Use -h to print help."
        fi
        ;;
esac
