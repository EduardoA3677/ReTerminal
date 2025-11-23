#!/bin/bash
# Debian Validation Test Script for ReTerminal
# This script validates the Debian environment functionality

set -e  # Exit on error

echo "======================================"
echo "ReTerminal Debian Validation Tests"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0
TOTAL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    TOTAL=$((TOTAL + 1))
    
    echo -n "Test $TOTAL: $test_name ... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Function to run a test with output check
run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    local expected_output="$3"
    TOTAL=$((TOTAL + 1))
    
    echo -n "Test $TOTAL: $test_name ... "
    
    output=$(eval "$test_command" 2>&1)
    if echo "$output" | grep -q "$expected_output"; then
        echo -e "${GREEN}PASSED${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Expected: $expected_output"
        echo "  Got: $output"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

echo "Starting validation tests..."
echo ""

# Test 1: Shell Environment
echo -e "${YELLOW}=== Shell Environment Tests ===${NC}"
run_test_with_output "Bash shell is running" "echo \$SHELL" "/bin/bash"
run_test "Bash version available" "[ -n \"\$BASH_VERSION\" ]"
run_test "Current directory accessible" "pwd"
run_test "Home directory is /root" "[ \"\$HOME\" = \"/root\" ]"
echo ""

# Test 2: Basic Commands
echo -e "${YELLOW}=== Basic Command Tests ===${NC}"
run_test "ls command works" "ls /"
run_test "cat command works" "cat /etc/os-release"
run_test "echo command works" "echo 'test'"
run_test "pwd command works" "pwd"
run_test "cd command works" "cd /tmp && cd -"
echo ""

# Test 3: File System
echo -e "${YELLOW}=== File System Tests ===${NC}"
run_test "Can create file" "echo 'test' > /tmp/test.txt"
run_test "Can read file" "cat /tmp/test.txt"
run_test "Can delete file" "rm /tmp/test.txt"
run_test "Can create directory" "mkdir -p /tmp/testdir"
run_test "Can remove directory" "rmdir /tmp/testdir"
echo ""

# Test 4: Package Manager
echo -e "${YELLOW}=== Package Manager Tests ===${NC}"
run_test "apt command exists" "which apt"
run_test "dpkg command exists" "which dpkg"
run_test "apt-cache command works" "apt-cache --version"
run_test_with_output "Debian system detected" "cat /etc/os-release" "Debian"
echo ""

# Test 5: Network Configuration
echo -e "${YELLOW}=== Network Configuration Tests ===${NC}"
run_test "DNS resolver configured" "[ -f /etc/resolv.conf ]"
run_test_with_output "DNS server is set" "cat /etc/resolv.conf" "nameserver"
run_test "Hostname is set" "hostname"
echo ""

# Test 6: Required Packages
echo -e "${YELLOW}=== Required Package Tests ===${NC}"
run_test "bash is installed" "which bash"
run_test "nano is installed" "which nano"
run_test "sh is available" "which sh"
echo ""

# Test 7: System Directories
echo -e "${YELLOW}=== System Directory Tests ===${NC}"
run_test "/bin directory exists" "[ -d /bin ]"
run_test "/usr/bin directory exists" "[ -d /usr/bin ]"
run_test "/etc directory exists" "[ -d /etc ]"
run_test "/tmp directory exists" "[ -d /tmp ]"
run_test "/var directory exists" "[ -d /var ]"
run_test "/root directory exists" "[ -d /root ]"
echo ""

# Test 8: Permissions
echo -e "${YELLOW}=== Permission Tests ===${NC}"
run_test "Running as root" "[ \"\$(id -u)\" = \"0\" ]"
run_test "Can write to /root" "touch /root/.test && rm /root/.test"
run_test "Can write to /tmp" "touch /tmp/.test && rm /tmp/.test"
echo ""

# Test 9: Environment Variables
echo -e "${YELLOW}=== Environment Variable Tests ===${NC}"
run_test "PATH is set" "[ -n \"\$PATH\" ]"
run_test "HOME is set" "[ -n \"\$HOME\" ]"
run_test "USER is set or can be determined" "[ -n \"\$USER\" ] || [ \"\$(whoami)\" = \"root\" ]"
echo ""

# Test 10: Advanced Shell Features
echo -e "${YELLOW}=== Advanced Shell Feature Tests ===${NC}"
run_test "Command substitution works" "[ \"\$(echo test)\" = \"test\" ]"
run_test "Pipes work" "echo test | cat"
run_test "Redirection works" "echo test > /tmp/.test && rm /tmp/.test"
run_test "Exit codes work" "true; [ \$? -eq 0 ]"
echo ""

# Test 11: Package Installation (Optional - requires network)
echo -e "${YELLOW}=== Package Installation Tests (Optional) ===${NC}"
echo "Note: These tests are optional and require network connectivity"
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "Network detected, running installation tests..."
    run_test "apt update works" "apt update"
    run_test "Can search for packages" "apt-cache search htop"
else
    echo "Network not available, skipping installation tests"
fi
echo ""

# Summary
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! Debian environment is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi
