# Debian Migration Plan and Documentation

## Overview
This document details the complete migration of ReTerminal from Alpine Linux to Debian as the root filesystem.

## Migration Summary

### What Changed
- **Linux Distribution**: Alpine Linux → Debian Trixie (testing/stable)
- **Package Manager**: apk → apt/dpkg
- **Default Shell**: /bin/ash → /bin/bash
- **Archive Format**: .tar.gz → .tar.xz
- **Base Directory**: /local/alpine → /local/debian
- **Document Provider**: AlpineDocumentProvider → DebianDocumentProvider

## Detailed Changes

### 1. Download URLs and Package Sources
**File**: `core/main/src/main/java/com/rk/terminal/ui/screens/downloader/Downloader.kt`

Changed from Alpine minirootfs to Debian Trixie from Termux proot-distro:
- **x86_64**: `debian-trixie-x86_64-pd-v4.29.0.tar.xz`
- **arm64-v8a**: `debian-trixie-aarch64-pd-v4.29.0.tar.xz`
- **armeabi-v7a**: `debian-trixie-arm-pd-v4.29.0.tar.xz`

Source: https://github.com/termux/proot-distro/releases/tag/v4.29.0

### 2. Shell Initialization Scripts

#### init.sh Changes
**File**: `core/main/src/main/assets/init.sh`

**Before (Alpine)**:
```bash
required_packages="bash gcompat glib nano"
for pkg in $required_packages; do
    if ! apk info -e $pkg >/dev/null 2>&1; then
        missing_packages="$missing_packages $pkg"
    fi
done
apk update && apk upgrade
apk add $missing_packages
/bin/ash
```

**After (Debian)**:
```bash
export DEBIAN_FRONTEND=noninteractive
required_packages="bash nano"
for pkg in $required_packages; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        missing_packages="$missing_packages $pkg"
    fi
done
apt-get update && apt-get upgrade -y
apt-get install -y $missing_packages
/bin/bash
```

**Key Changes**:
- Removed Alpine-specific packages: `gcompat`, `glib`
- Changed package check from `apk info -e` to `dpkg -l`
- Changed package manager from `apk` to `apt-get`
- Added `DEBIAN_FRONTEND=noninteractive` for automated installs
- Changed default shell from `/bin/ash` to `/bin/bash`

#### init-host.sh Changes
**File**: `core/main/src/main/assets/init-host.sh`

- Changed `ALPINE_DIR` to `DEBIAN_DIR`
- Changed archive reference from `alpine.tar.gz` to `debian.tar.xz`
- Updated directory paths throughout

### 3. File System Functions
**File**: `core/main/src/main/java/com/rk/libcommons/FileUtil.kt`

Renamed functions:
- `alpineDir()` → `debianDir()`
- `alpineHomeDir()` → `debianHomeDir()`

These functions now return paths like:
- `/data/data/com.rk.terminal/local/debian/`
- `/data/data/com.rk.terminal/local/debian/root/`

### 4. Document Provider
**File**: Renamed from `AlpineDocumentProvider.kt` to `DebianDocumentProvider.kt`

- Renamed class: `AlpineDocumentProvider` → `DebianDocumentProvider`
- Updated all internal references to use `debianHomeDir()`
- Updated AndroidManifest.xml provider declaration

### 5. Working Mode Settings
**Files**: 
- `core/main/src/main/java/com/rk/terminal/ui/screens/settings/Settings.kt`
- `core/main/src/main/java/com/rk/settings/Settings.kt`

- Changed constant: `WorkingMode.ALPINE = 0` → `WorkingMode.DEBIAN = 0`
- Updated default preference to `WorkingMode.DEBIAN`
- Updated UI labels from "Alpine" to "Debian"

### 6. Terminal Session Management
**File**: `core/main/src/main/java/com/rk/terminal/ui/screens/terminal/MkSession.kt`

- Changed imports to use `debianDir()` and `debianHomeDir()`
- Updated working directory to use Debian home
- Changed mode check from `WorkingMode.ALPINE` to `WorkingMode.DEBIAN`

### 7. Root Filesystem Validation
**File**: `core/main/src/main/java/com/rk/terminal/ui/screens/terminal/Rootfs.kt`

Changed file check from `alpine.tar.gz` to `debian.tar.xz`

### 8. UI Updates
**File**: `core/main/src/main/java/com/rk/terminal/ui/screens/terminal/TerminalScreen.kt`

- Updated session creation dialog labels
- Changed mode display name from "alpine" to "debian"
- Updated descriptions from "Alpine Linux" to "Debian Linux"

### 9. Documentation
**File**: `README.md`

Updated feature list to show "Debian Linux support" instead of "Alpine Linux support"

## Validation

A comprehensive test suite has been created: `test-debian-migration.sh`

### Test Coverage:
1. ✅ No Alpine references remain in source code
2. ✅ Debian references exist throughout the codebase
3. ✅ DebianDocumentProvider exists
4. ✅ AlpineDocumentProvider removed
5. ✅ init.sh uses apt-get instead of apk
6. ✅ init.sh uses bash instead of ash
7. ✅ Downloader references debian.tar.xz
8. ✅ Debian Trixie URLs configured correctly
9. ✅ WorkingMode.DEBIAN constant exists
10. ✅ README mentions Debian support
11. ✅ debianDir and debianHomeDir functions exist
12. ✅ AndroidManifest references DebianDocumentProvider

### Running Tests
```bash
./test-debian-migration.sh
```

## User Impact

### Benefits of Debian over Alpine:
1. **Better Package Compatibility**: Debian has a much larger package repository
2. **Standard glibc**: No need for Alpine's musl compatibility layer (gcompat)
3. **More Software Support**: Many applications are built and tested primarily on Debian
4. **Familiar Environment**: Debian is more commonly used and has more documentation
5. **Better Python/Node.js Support**: Native support without compatibility shims

### Breaking Changes:
1. Users will need to re-download the root filesystem (~50-80 MB depending on architecture)
2. Any existing Alpine installations in the app will need to be migrated manually
3. Package names might differ slightly between Alpine and Debian (e.g., `python3-pip` vs `py3-pip`)

### Migration Path for Users:
1. Update to the new version
2. The app will automatically download Debian rootfs on first launch
3. Old Alpine data remains in `/local/alpine/` but won't be used
4. Users can manually backup `/local/alpine/root/` if they have important data
5. New sessions will use Debian by default

## Technical Notes

### Archive Format
Debian archives use `.tar.xz` compression (LZMA2) which provides better compression than `.tar.gz` (gzip):
- Smaller download size
- Slightly longer decompression time (negligible on modern devices)
- Standard for Debian packages

### Package Manager Differences

| Feature | Alpine (apk) | Debian (apt) |
|---------|-------------|--------------|
| Package check | `apk info -e <pkg>` | `dpkg -l \| grep <pkg>` |
| Update | `apk update` | `apt-get update` |
| Upgrade | `apk upgrade` | `apt-get upgrade -y` |
| Install | `apk add <pkg>` | `apt-get install -y <pkg>` |
| Search | `apk search <pkg>` | `apt-cache search <pkg>` |
| Remove | `apk del <pkg>` | `apt-get remove <pkg>` |

### Environment Variables
Added `DEBIAN_FRONTEND=noninteractive` to prevent apt from prompting for user input during package installation.

## Future Improvements

1. **Locale Configuration**: Add proper locale setup for better internationalization
2. **Package Cache**: Consider implementing package cache cleanup to save space
3. **Version Migration**: Add automatic migration tool for existing Alpine users
4. **Testing**: Add instrumented tests to verify Debian functionality on real devices
5. **Documentation**: Create user guide for common Debian package management tasks

## References

- Debian Project: https://www.debian.org/
- Termux proot-distro: https://github.com/termux/proot-distro
- Debian Trixie: https://wiki.debian.org/DebianTrixie
- APT User Guide: https://www.debian.org/doc/manuals/apt-guide/
