#!/bin/bash
# ReTerminal Debian Migration Validation Script
# This script validates that all Debian-related changes are correctly implemented

set -e

echo "======================================"
echo "ReTerminal Debian Migration Validation"
echo "======================================"
echo ""

ERRORS=0
WARNINGS=0

# Function to report error
report_error() {
    echo "❌ ERROR: $1"
    ((ERRORS++))
}

# Function to report warning
report_warning() {
    echo "⚠️  WARNING: $1"
    ((WARNINGS++))
}

# Function to report success
report_success() {
    echo "✅ PASS: $1"
}

echo "Test 1: Check for remaining Alpine references..."
if grep -r "alpine" --include="*.kt" --include="*.java" --include="*.xml" --include="*.sh" . 2>/dev/null | grep -v ".git" | grep -v "DEBIAN_MIGRATION_PLAN" | grep -v "test_migration" | grep -v "Binary"; then
    report_error "Found remaining 'alpine' references (lowercase) in code"
else
    report_success "No lowercase 'alpine' references found"
fi

if grep -r "Alpine" --include="*.kt" --include="*.java" --include="*.xml" --include="*.sh" . 2>/dev/null | grep -v ".git" | grep -v "DEBIAN_MIGRATION_PLAN" | grep -v "test_migration" | grep -v "Binary"; then
    report_error "Found remaining 'Alpine' references (capitalized) in code"
else
    report_success "No capitalized 'Alpine' references found"
fi

echo ""
echo "Test 2: Check for Debian references..."
if grep -r "debian" --include="*.kt" --include="*.java" . 2>/dev/null | grep -v ".git" | grep -v "DEBIAN_MIGRATION_PLAN" | grep -v "test_migration" | wc -l | grep -q "^[1-9]"; then
    report_success "Found Debian references in code"
else
    report_error "No Debian references found in code"
fi

echo ""
echo "Test 3: Check Downloader.kt for correct URLs..."
if grep -q "debian.tar.gz" core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt; then
    report_success "Downloader.kt references debian.tar.gz"
else
    report_error "Downloader.kt doesn't reference debian.tar.gz"
fi

if grep -q "debian-bookworm" core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt; then
    report_success "Downloader.kt uses Debian Bookworm URLs"
else
    report_error "Downloader.kt doesn't use Debian Bookworm URLs"
fi

if grep -q "alpinelinux.org" core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt; then
    report_error "Downloader.kt still references Alpine Linux URLs"
else
    report_success "No Alpine Linux URLs in Downloader.kt"
fi

echo ""
echo "Test 4: Check FileUtil.kt for correct function names..."
if grep -q "fun debianDir()" core/main/src/main/java/com/rk/libcommons/FileUtil.kt; then
    report_success "FileUtil.kt has debianDir() function"
else
    report_error "FileUtil.kt missing debianDir() function"
fi

if grep -q "fun debianHomeDir()" core/main/src/main/java/com/rk/libcommons/FileUtil.kt; then
    report_success "FileUtil.kt has debianHomeDir() function"
else
    report_error "FileUtil.kt missing debianHomeDir() function"
fi

if grep -q "alpineDir\|alpineHomeDir" core/main/src/main/java/com/rk/libcommons/FileUtil.kt; then
    report_error "FileUtil.kt still has Alpine function names"
else
    report_success "No Alpine function names in FileUtil.kt"
fi

echo ""
echo "Test 5: Check DebianDocumentProvider.kt exists..."
if [ -f "core/main/src/main/java/com/rk/DebianDocumentProvider.kt" ]; then
    report_success "DebianDocumentProvider.kt exists"
else
    report_error "DebianDocumentProvider.kt not found"
fi

if [ -f "core/main/src/main/java/com/rk/AlpineDocumentProvider.kt" ]; then
    report_error "AlpineDocumentProvider.kt still exists"
else
    report_success "AlpineDocumentProvider.kt removed"
fi

echo ""
echo "Test 6: Check AndroidManifest.xml..."
if grep -q "DebianDocumentProvider" core/main/src/main/AndroidManifest.xml; then
    report_success "AndroidManifest.xml references DebianDocumentProvider"
else
    report_error "AndroidManifest.xml doesn't reference DebianDocumentProvider"
fi

if grep -q "AlpineDocumentProvider" core/main/src/main/AndroidManifest.xml; then
    report_error "AndroidManifest.xml still references AlpineDocumentProvider"
else
    report_success "No AlpineDocumentProvider in AndroidManifest.xml"
fi

echo ""
echo "Test 7: Check WorkingMode in Settings.kt..."
if grep -q "const val DEBIAN = 0" core/main/src/main/java/com/rk/terminal/ui/screens/settings/Settings.kt; then
    report_success "WorkingMode.DEBIAN defined correctly"
else
    report_error "WorkingMode.DEBIAN not defined"
fi

if grep -q "const val ALPINE" core/main/src/main/java/com/rk/terminal/ui/screens/settings/Settings.kt; then
    report_error "WorkingMode.ALPINE still exists"
else
    report_success "WorkingMode.ALPINE removed"
fi

echo ""
echo "Test 8: Check init-host.sh..."
if grep -q "DEBIAN_DIR" core/main/src/main/assets/init-host.sh; then
    report_success "init-host.sh uses DEBIAN_DIR variable"
else
    report_error "init-host.sh doesn't use DEBIAN_DIR variable"
fi

if grep -q "debian.tar.gz" core/main/src/main/assets/init-host.sh; then
    report_success "init-host.sh references debian.tar.gz"
else
    report_error "init-host.sh doesn't reference debian.tar.gz"
fi

if grep -q "/local/alpine" core/main/src/main/assets/init-host.sh; then
    report_error "init-host.sh still references /local/alpine path"
else
    report_success "No /local/alpine references in init-host.sh"
fi

echo ""
echo "Test 9: Check init.sh for apt package manager..."
if grep -q "apt update" core/main/src/main/assets/init.sh; then
    report_success "init.sh uses apt package manager"
else
    report_error "init.sh doesn't use apt package manager"
fi

if grep -q "dpkg -s" core/main/src/main/assets/init.sh; then
    report_success "init.sh uses dpkg for package check"
else
    report_error "init.sh doesn't use dpkg for package check"
fi

if grep -q "/bin/bash" core/main/src/main/assets/init.sh; then
    report_success "init.sh uses bash as default shell"
else
    report_error "init.sh doesn't use bash as default shell"
fi

if grep -q "apk\|/bin/ash" core/main/src/main/assets/init.sh; then
    report_error "init.sh still references apk or ash"
else
    report_success "No apk or ash references in init.sh"
fi

echo ""
echo "Test 10: Check Rootfs.kt..."
if grep -q "debian.tar.gz" core/main/src/main/java/com/rk/terminal/ui/screens/terminal/Rootfs.kt; then
    report_success "Rootfs.kt checks for debian.tar.gz"
else
    report_error "Rootfs.kt doesn't check for debian.tar.gz"
fi

if grep -q "alpine.tar.gz" core/main/src/main/java/com/rk/terminal/ui/screens/terminal/Rootfs.kt; then
    report_error "Rootfs.kt still checks for alpine.tar.gz"
else
    report_success "No alpine.tar.gz check in Rootfs.kt"
fi

echo ""
echo "Test 11: Check README.md..."
if grep -q "Debian Linux support" README.md; then
    report_success "README.md mentions Debian support"
else
    report_error "README.md doesn't mention Debian support"
fi

if grep -q "Alpine Linux support" README.md; then
    report_error "README.md still mentions Alpine support"
else
    report_success "No Alpine support mention in README.md"
fi

echo ""
echo "Test 12: Check MkSession.kt imports..."
if grep -q "import com.rk.libcommons.debianHomeDir" core/main/src/main/java/com/rk/terminal/ui/screens/terminal/MkSession.kt; then
    report_success "MkSession.kt imports debianHomeDir"
else
    report_error "MkSession.kt doesn't import debianHomeDir"
fi

if grep -q "WorkingMode.DEBIAN" core/main/src/main/java/com/rk/terminal/ui/screens/terminal/MkSession.kt; then
    report_success "MkSession.kt checks for WorkingMode.DEBIAN"
else
    report_error "MkSession.kt doesn't check for WorkingMode.DEBIAN"
fi

echo ""
echo "Test 13: Check UI labels in TerminalScreen.kt..."
if grep -q 'Text("Debian")' core/main/src/main/java/com/rk/terminal/ui/screens/terminal/TerminalScreen.kt; then
    report_success "TerminalScreen.kt has Debian UI label"
else
    report_error "TerminalScreen.kt doesn't have Debian UI label"
fi

if grep -q '"DEBIAN".lowercase()' core/main/src/main/java/com/rk/terminal/ui/screens/terminal/TerminalScreen.kt; then
    report_success "TerminalScreen.kt displays 'debian' in working mode"
else
    report_error "TerminalScreen.kt doesn't display 'debian' in working mode"
fi

echo ""
echo "======================================"
echo "Validation Summary"
echo "======================================"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ All validation tests passed!"
    echo ""
    echo "Migration is complete and ready for testing."
    echo "Please run the application on a device/emulator to verify runtime behavior."
    exit 0
else
    echo "❌ Validation failed with $ERRORS error(s)"
    echo ""
    echo "Please fix the errors above before proceeding."
    exit 1
fi
