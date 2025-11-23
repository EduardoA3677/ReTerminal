#!/bin/bash
# Test script to validate Debian migration
# This script validates that all Alpine references have been replaced with Debian

set -e

echo "=== Debian Migration Validation Test ==="
echo ""

# Auto-detect project root or use provided path
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
FAILED=0

echo "Using project root: $PROJECT_ROOT"
echo ""

# Test 1: Check that no Alpine references remain (except in git history)
echo "[Test 1] Checking for remaining Alpine references..."
if grep -r "alpine\|Alpine" "$PROJECT_ROOT/core/main/src/main" \
    --include="*.kt" --include="*.xml" --include="*.sh" -i \
    | grep -v "debianDir\|debianHome\|import\|package\|Binary file" > /tmp/alpine_refs.txt 2>&1; then
    echo "❌ FAILED: Found remaining Alpine references:"
    cat /tmp/alpine_refs.txt
    FAILED=1
else
    echo "✅ PASSED: No Alpine references found"
fi
echo ""

# Test 2: Verify Debian references exist
echo "[Test 2] Checking for Debian references..."
DEBIAN_COUNT=$(grep -r "debian\|Debian" "$PROJECT_ROOT/core/main/src/main" \
    --include="*.kt" --include="*.xml" --include="*.sh" | wc -l)
if [ "$DEBIAN_COUNT" -lt 20 ]; then
    echo "❌ FAILED: Expected at least 20 Debian references, found $DEBIAN_COUNT"
    FAILED=1
else
    echo "✅ PASSED: Found $DEBIAN_COUNT Debian references"
fi
echo ""

# Test 3: Check DebianDocumentProvider exists
echo "[Test 3] Checking DebianDocumentProvider exists..."
if [ ! -f "$PROJECT_ROOT/core/main/src/main/java/com/rk/DebianDocumentProvider.kt" ]; then
    echo "❌ FAILED: DebianDocumentProvider.kt not found"
    FAILED=1
else
    echo "✅ PASSED: DebianDocumentProvider.kt exists"
fi
echo ""

# Test 4: Check AlpineDocumentProvider is removed
echo "[Test 4] Checking AlpineDocumentProvider is removed..."
if [ -f "$PROJECT_ROOT/core/main/src/main/java/com/rk/AlpineDocumentProvider.kt" ]; then
    echo "❌ FAILED: AlpineDocumentProvider.kt still exists"
    FAILED=1
else
    echo "✅ PASSED: AlpineDocumentProvider.kt removed"
fi
echo ""

# Test 5: Check init.sh uses apt instead of apk
echo "[Test 5] Checking init.sh uses apt instead of apk..."
if grep -q "apt-get" "$PROJECT_ROOT/core/main/src/main/assets/init.sh" && \
   ! grep -q "apk add" "$PROJECT_ROOT/core/main/src/main/assets/init.sh"; then
    echo "✅ PASSED: init.sh uses apt-get"
else
    echo "❌ FAILED: init.sh should use apt-get instead of apk"
    FAILED=1
fi
echo ""

# Test 6: Check init.sh uses bash instead of ash
echo "[Test 6] Checking init.sh uses bash instead of ash..."
if grep -q "/bin/bash" "$PROJECT_ROOT/core/main/src/main/assets/init.sh" && \
   ! grep -q "/bin/ash" "$PROJECT_ROOT/core/main/src/main/assets/init.sh"; then
    echo "✅ PASSED: init.sh uses bash"
else
    echo "❌ FAILED: init.sh should use bash instead of ash"
    FAILED=1
fi
echo ""

# Test 7: Check debian.tar.xz in Downloader.kt
echo "[Test 7] Checking Downloader.kt references debian.tar.xz..."
if grep -q "debian.tar.xz" "$PROJECT_ROOT/core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt"; then
    echo "✅ PASSED: Downloader.kt references debian.tar.xz"
else
    echo "❌ FAILED: Downloader.kt should reference debian.tar.xz"
    FAILED=1
fi
echo ""

# Test 8: Check Debian download URLs
echo "[Test 8] Checking Debian download URLs..."
if grep -q "debian-trixie.*-pd-v4.29.0.tar.xz" "$PROJECT_ROOT/core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt"; then
    echo "✅ PASSED: Debian Trixie URLs configured correctly"
else
    echo "❌ FAILED: Debian download URLs incorrect"
    FAILED=1
fi
echo ""

# Test 9: Check WorkingMode.DEBIAN exists
echo "[Test 9] Checking WorkingMode.DEBIAN constant..."
if grep -q "const val DEBIAN = 0" "$PROJECT_ROOT/core/main/src/main/java/com/rk/terminal/ui/screens/settings/Settings.kt"; then
    echo "✅ PASSED: WorkingMode.DEBIAN constant exists"
else
    echo "❌ FAILED: WorkingMode.DEBIAN constant not found"
    FAILED=1
fi
echo ""

# Test 10: Check README updated
echo "[Test 10] Checking README mentions Debian..."
if grep -q "Debian Linux support" "$PROJECT_ROOT/README.md"; then
    echo "✅ PASSED: README mentions Debian support"
else
    echo "❌ FAILED: README should mention Debian support"
    FAILED=1
fi
echo ""

# Test 11: Check debianDir and debianHomeDir functions exist
echo "[Test 11] Checking debianDir and debianHomeDir functions..."
if grep -q "fun debianDir" "$PROJECT_ROOT/core/main/src/main/java/com/rk/libcommons/FileUtil.kt" && \
   grep -q "fun debianHomeDir" "$PROJECT_ROOT/core/main/src/main/java/com/rk/libcommons/FileUtil.kt"; then
    echo "✅ PASSED: debianDir and debianHomeDir functions exist"
else
    echo "❌ FAILED: debianDir and debianHomeDir functions not found"
    FAILED=1
fi
echo ""

# Test 12: Check AndroidManifest uses DebianDocumentProvider
echo "[Test 12] Checking AndroidManifest references DebianDocumentProvider..."
if grep -q "com.rk.DebianDocumentProvider" "$PROJECT_ROOT/core/main/src/main/AndroidManifest.xml"; then
    echo "✅ PASSED: AndroidManifest references DebianDocumentProvider"
else
    echo "❌ FAILED: AndroidManifest should reference DebianDocumentProvider"
    FAILED=1
fi
echo ""

# Summary
echo "================================"
if [ $FAILED -eq 0 ]; then
    echo "✅ ALL TESTS PASSED!"
    echo "Debian migration is complete and validated."
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    echo "Please review the failures above."
    exit 1
fi
