#!/bin/bash
# Debian Migration Validation Script
# This script helps validate that the Debian migration was successful

echo "======================================"
echo "ReTerminal Debian Migration Validator"
echo "======================================"
echo ""

ERRORS=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_file_content() {
    local file=$1
    local search=$2
    local description=$3
    
    if grep -q "$search" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

test_file_not_content() {
    local file=$1
    local search=$2
    local description=$3
    
    if ! grep -q "$search" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description (still contains old reference)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

test_file_exists() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

test_file_not_exists() {
    local file=$1
    local description=$2
    
    if [ ! -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $description (old file still exists)"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

echo "Testing Shell Scripts..."
echo "------------------------"
test_file_content "core/main/src/main/assets/init.sh" "dpkg -s" "init.sh uses dpkg for package checking"
test_file_content "core/main/src/main/assets/init.sh" "apt update" "init.sh uses apt for updates"
test_file_content "core/main/src/main/assets/init.sh" "apt install" "init.sh uses apt for installation"
test_file_content "core/main/src/main/assets/init.sh" "/bin/bash" "init.sh uses bash shell"
test_file_not_content "core/main/src/main/assets/init.sh" "apk " "init.sh no longer references apk"
test_file_not_content "core/main/src/main/assets/init.sh" "/bin/ash" "init.sh no longer references ash"
test_file_content "core/main/src/main/assets/init-host.sh" "DEBIAN_DIR" "init-host.sh uses DEBIAN_DIR"
test_file_content "core/main/src/main/assets/init-host.sh" "debian.tar.xz" "init-host.sh references debian.tar.xz"
test_file_not_content "core/main/src/main/assets/init-host.sh" "ALPINE_DIR" "init-host.sh no longer uses ALPINE_DIR"
test_file_not_content "core/main/src/main/assets/init-host.sh" "alpine.tar" "init-host.sh no longer references alpine tarball"
echo ""

echo "Testing Kotlin/Java Files..."
echo "----------------------------"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt" "debian.tar.xz" "Downloader.kt downloads debian.tar.xz"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt" "termux/proot-distro" "Downloader.kt uses Debian from proot-distro"
test_file_not_content "core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt" "alpinelinux.org" "Downloader.kt no longer uses Alpine URLs"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/terminal/Rootfs.kt" "debian.tar.xz" "Rootfs.kt checks for debian.tar.xz"
test_file_content "core/main/src/main/java/com/rk/libcommons/FileUtil.kt" "debianDir()" "FileUtil.kt has debianDir function"
test_file_content "core/main/src/main/java/com/rk/libcommons/FileUtil.kt" "debianHomeDir()" "FileUtil.kt has debianHomeDir function"
test_file_not_content "core/main/src/main/java/com/rk/libcommons/FileUtil.kt" "alpineDir()" "FileUtil.kt no longer has alpineDir"
test_file_not_content "core/main/src/main/java/com/rk/libcommons/FileUtil.kt" "alpineHomeDir()" "FileUtil.kt no longer has alpineHomeDir"
test_file_exists "core/main/src/main/java/com/rk/DebianDocumentProvider.kt" "DebianDocumentProvider.kt exists"
test_file_not_exists "core/main/src/main/java/com/rk/AlpineDocumentProvider.kt" "AlpineDocumentProvider.kt removed"
test_file_content "core/main/src/main/java/com/rk/DebianDocumentProvider.kt" "class DebianDocumentProvider" "DebianDocumentProvider class properly named"
test_file_content "core/main/src/main/java/com/rk/DebianDocumentProvider.kt" "debianHomeDir()" "DebianDocumentProvider uses debianHomeDir"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/settings/Settings.kt" "WorkingMode.DEBIAN" "Settings.kt uses DEBIAN constant"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/settings/Settings.kt" "Debian Linux" "Settings.kt shows Debian in UI"
test_file_not_content "core/main/src/main/java/com/rk/terminal/ui/screens/settings/Settings.kt" "WorkingMode.ALPINE" "Settings.kt no longer uses ALPINE constant"
test_file_content "core/main/src/main/java/com/rk/settings/Settings.kt" "WorkingMode.DEBIAN" "Settings.kt default is DEBIAN"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/terminal/TerminalScreen.kt" "DEBIAN" "TerminalScreen.kt references DEBIAN"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/terminal/MkSession.kt" "debianHomeDir" "MkSession.kt uses debianHomeDir"
test_file_not_content "core/main/src/main/java/com/rk/terminal/ui/screens/terminal/MkSession.kt" "alpineHomeDir" "MkSession.kt no longer uses alpineHomeDir"
test_file_content "core/main/src/main/java/com/rk/libcommons/TerminalCommandTraffic.kt" "val debian:" "TerminalCommandTraffic.kt uses debian field"
echo ""

echo "Testing Configuration Files..."
echo "------------------------------"
test_file_content "core/main/src/main/AndroidManifest.xml" "DebianDocumentProvider" "AndroidManifest uses DebianDocumentProvider"
test_file_not_content "core/main/src/main/AndroidManifest.xml" "AlpineDocumentProvider" "AndroidManifest no longer uses AlpineDocumentProvider"
test_file_content "README.md" "Debian Linux support" "README mentions Debian"
echo ""

echo "Testing Debian URLs..."
echo "----------------------"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt" "debian-amd64-pd" "x86_64 Debian URL present"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt" "debian-aarch64-pd" "ARM64 Debian URL present"
test_file_content "core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt" "debian-arm-pd" "ARMv7 Debian URL present"
echo ""

echo "======================================"
echo "Validation Summary"
echo "======================================"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo "The Alpine to Debian migration appears to be complete."
    echo ""
    echo "Next steps:"
    echo "1. Build the APK: ./gradlew assembleDebug"
    echo "2. Install on device and test functionality"
    echo "3. Follow tests in DEBIAN_MIGRATION.md"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    echo "Please review the errors above and fix them."
    exit 1
fi
