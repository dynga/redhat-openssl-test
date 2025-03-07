#!/usr/bin/env bash

print_help() {
    echo "OpenSSL TLS test suite assigned as Linux Security interview homework for Red Hat."
    echo "Usage: test.sh [OPTION]"
    echo "       test.sh [TEST]"
    echo "OPTION argument:"
    echo "-h --help - print this help screen"
    echo "-l --list - print all available tests"
    echo "TEST argument:"
    echo "Run with test name as the TEST argument to run a specific test."
    echo "Run without parameters to run all available tests."
}

setup() {
    echo "Performing test setup"
    {
    dnf install -y openssl crypto-policies crypto-policies-scripts
    openssl req -x509 -newkey rsa -keyout key.pem -out server.pem -days 365 \
        -nodes -subj "/CN=localhost"
    openssl s_server -key key.pem -cert server.pem &
    export S_SERVER_PID=$!
    } &> /dev/null
    echo "Test setup done!"
}

cleanup() {
    echo "Performing test cleanup"
    {
    dnf history undo last -y
    kill -9 $S_SERVER_PID
    rm key.pem server.pem
    } &> /dev/null
    echo "Test cleanup done!"
}

list_tests() {
    declare -F | grep -oh "test_.*"
}

execute_single_test() {
    echo -n "Running ${1}"
    if $1; then
        echo " - PASS"
    else
        echo " - FAIL"
    fi
}

execute_all_tests() {
    mapfile -t tests < <( list_tests )

    for test in "${tests[@]}"; do
        execute_single_test ""$test
    done
}

# All test functions' names need to begin with "test_"
# in order to get picked up by the test suite

test_1() {
    sleep 5
}

test_2() {
    sleep 5
}

test_3() {
    sleep 5
}

test_fail() {
    return 1
}

main() {

    if [[ $EUID -ne 0 ]]; then
        echo "The script needs root priviledges to run."
        exit
    fi

    if [[ ! $(cat /etc/system-release) =~ "Fedora release 41" ]]; then
        echo "This test targets Fedora 41 exclusively."
        exit
    fi

    if [[ $# -gt 1 ]]; then
        echo "Too many arguments provided. Use -h to print help."
    fi

    case $1 in
        -h|--help)
            print_help
            ;;
        -l|--list)
            echo "List of available tests:"
            list_tests
            ;;
        *)
            mapfile -t args < <( list_tests )
            if [[ ${args[*]} =~ $1 ]]; then
                setup
                execute_single_test "$1"
                cleanup
            elif [[ $# -eq 0 ]]; then
                setup
                execute_all_tests
                cleanup
            else
                echo "Unknown argument found. Use -h to print help."
            fi
            ;;
    esac
}

main "$@"
