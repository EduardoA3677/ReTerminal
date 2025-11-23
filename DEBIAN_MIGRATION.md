# Debian Migration Guide

## Overview
This document describes the complete migration from Alpine Linux to Debian Linux in ReTerminal.

## Migration Summary

### What Changed
ReTerminal has been migrated from using Alpine Linux to Debian Linux as its containerized Linux environment. This provides:
- Better package compatibility (apt vs apk)
- More extensive package repositories
- Better compatibility with mainstream Linux applications
- bash as default shell instead of ash

### Technical Changes

#### 1. Package Manager
- **Before**: Alpine Package Manager (apk)
- **After**: Debian Package Manager (apt)

#### 2. Default Shell
- **Before**: /bin/ash (BusyBox)
- **After**: /bin/bash (GNU Bash)

#### 3. Rootfs Source
- **Before**: Alpine minirootfs from alpinelinux.org
- **After**: Debian rootfs from termux/proot-distro project

#### 4. Archive Format
- **Before**: .tar.gz
- **After**: .tar.xz

## Files Modified

### Shell Scripts
1. **init-host.sh**
   - Changed directory variable: `ALPINE_DIR` → `DEBIAN_DIR`
   - Updated tarball path: `alpine.tar.gz` → `debian.tar.xz`
   - Updated all directory references to use `debian` instead of `alpine`

2. **init.sh**
   - Package check: `apk info -e` → `dpkg -s`
   - Update/upgrade: `apk update && apk upgrade` → `apt update && apt upgrade -y`
   - Install: `apk add` → `apt install -y`
   - Shell: `/bin/ash` → `/bin/bash`
   - Removed Alpine-specific packages: gcompat, glib (not needed in Debian)

### Kotlin/Java Files
1. **Downloader.kt**
   - Updated download URLs to point to Debian rootfs
   - Changed data class field: `alpine` → `debian`
   - Updated filename: `alpine.tar.gz` → `debian.tar.xz`

2. **Rootfs.kt**
   - Updated file check for `debian.tar.xz`

3. **FileUtil.kt**
   - Renamed: `alpineDir()` → `debianDir()`
   - Renamed: `alpineHomeDir()` → `debianHomeDir()`

4. **DebianDocumentProvider.kt** (renamed from AlpineDocumentProvider.kt)
   - Updated class name
   - Updated all function references to use `debianHomeDir()`

5. **Settings.kt** (both in ui/screens/settings and root)
   - Updated constant: `WorkingMode.ALPINE` → `WorkingMode.DEBIAN`
   - Updated UI labels
   - Updated default working mode

6. **TerminalScreen.kt**
   - Updated dialog labels
   - Updated working mode display names

7. **MkSession.kt**
   - Updated imports to use debian functions
   - Updated working directory references

8. **TerminalCommandTraffic.kt**
   - Renamed data class field: `alpine` → `debian`

### Configuration Files
1. **AndroidManifest.xml**
   - Updated provider: `AlpineDocumentProvider` → `DebianDocumentProvider`

2. **README.md**
   - Updated feature list to mention Debian support

## Validation Test Suite

### Test 1: Download and Extraction
**Objective**: Verify Debian rootfs downloads and extracts correctly

**Steps**:
1. Clear app data
2. Launch ReTerminal
3. Wait for download to complete
4. Verify files exist:
   - `files/proot`
   - `files/libtalloc.so.2`
   - `files/debian.tar.xz`
5. Verify directory structure:
   - `local/debian/` exists
   - `local/debian/root/` exists
   - `local/debian/bin/` exists
   - `local/debian/etc/` exists

**Expected Result**: All files download successfully and extract without errors

### Test 2: Shell Launch
**Objective**: Verify Debian environment starts correctly with bash

**Steps**:
1. Create a new Debian session
2. Verify the prompt appears
3. Run: `echo $SHELL`
4. Run: `cat /etc/os-release`

**Expected Results**:
- Prompt displays: `root@reterm`
- `$SHELL` returns `/bin/bash`
- `/etc/os-release` shows Debian information

### Test 3: Package Manager (apt)
**Objective**: Verify apt package manager works correctly

**Steps**:
1. In Debian session, run: `apt update`
2. Run: `apt list --installed | head`
3. Run: `apt install --dry-run curl`
4. Run: `apt install -y curl`
5. Run: `which curl`
6. Run: `curl --version`

**Expected Results**:
- `apt update` downloads package lists successfully
- Installed packages are listed
- curl installs without errors
- curl is available and functional

### Test 4: Basic Commands
**Objective**: Verify basic Debian commands work

**Steps**:
Run the following commands and verify they execute without errors:
1. `ls -la /`
2. `pwd`
3. `whoami`
4. `uname -a`
5. `df -h`
6. `ps aux`
7. `cat /etc/debian_version`

**Expected Result**: All commands execute successfully

### Test 5: File System Access
**Objective**: Verify file system access and permissions

**Steps**:
1. Run: `cd /root`
2. Run: `touch test.txt`
3. Run: `echo "Hello Debian" > test.txt`
4. Run: `cat test.txt`
5. Run: `rm test.txt`
6. Run: `cd /sdcard`
7. Run: `ls`

**Expected Results**:
- Can create, write, read, and delete files in /root
- Can access /sdcard directory

### Test 6: Multiple Sessions
**Objective**: Verify multiple Debian sessions work simultaneously

**Steps**:
1. Create Session 1 (Debian mode)
2. Run: `sleep 100 &`
3. Create Session 2 (Debian mode)
4. Run: `ps aux | grep sleep`
5. Switch back to Session 1
6. Verify it's still running

**Expected Result**: Multiple sessions run independently without interference

### Test 7: Android Mode Still Works
**Objective**: Verify Android shell mode remains functional

**Steps**:
1. Create new session in Android mode
2. Run: `echo $PREFIX`
3. Run: `ls /data/data/com.rk.terminal*/`
4. Run basic Android commands

**Expected Result**: Android mode continues to work as before

### Test 8: Settings Persistence
**Objective**: Verify working mode preference is saved

**Steps**:
1. Go to Settings
2. Select Debian as default
3. Close app
4. Reopen app
5. Create new session (should default to Debian)
6. Go to Settings
7. Verify Debian is selected

**Expected Result**: Settings persist across app restarts

### Test 9: Document Provider
**Objective**: Verify DebianDocumentProvider works

**Steps**:
1. Open Android file manager
2. Navigate to ReTerminal storage provider
3. Browse Debian home directory
4. Create a file
5. Verify file appears in terminal session

**Expected Result**: Document provider allows file access to Debian home directory

### Test 10: Bash Features
**Objective**: Verify bash-specific features work

**Steps**:
1. Test command history: Use up/down arrows
2. Test tab completion: Type `ls /us` and press TAB
3. Test aliases: Run `alias ll='ls -la'` then `ll`
4. Test bash scripts:
   ```bash
   cat > test.sh << 'EOF'
   #!/bin/bash
   echo "Bash version: $BASH_VERSION"
   EOF
   bash test.sh
   ```

**Expected Results**:
- Command history works
- Tab completion works
- Aliases work
- Bash scripts execute

## Architecture Support

The migration supports all three Android architectures:

| Architecture | Android ABI | Debian Package |
|-------------|-------------|----------------|
| x86_64 | x86_64 | debian-amd64-pd-v4.19.1.tar.xz |
| ARM64 | arm64-v8a | debian-aarch64-pd-v4.19.1.tar.xz |
| ARMv7 | armeabi-v7a | debian-arm-pd-v4.19.1.tar.xz |

## Debian Version
- Distribution: Debian
- Version: Based on termux/proot-distro v4.19.1
- Base: Debian stable (bookworm)

## Rollback Procedure

If you need to rollback to Alpine:

1. Revert the commit containing the Debian migration
2. Clear app data
3. Reinstall the app with Alpine version
4. The app will download Alpine rootfs on first launch

## Known Issues & Limitations

1. **First Launch**: First launch will take longer due to Debian rootfs being larger than Alpine
2. **Storage**: Debian requires more storage space (~150MB vs ~40MB for Alpine)
3. **Package Size**: Some Debian packages are larger than Alpine equivalents

## Benefits of Debian

1. **Package Availability**: Access to 59,000+ packages
2. **Compatibility**: Better compatibility with mainstream Linux software
3. **Documentation**: Extensive documentation and community support
4. **Long-term Support**: Debian stable releases receive long-term support
5. **Standard Tools**: Uses standard GNU tools instead of BusyBox

## Migration Checklist

- [x] Update download URLs
- [x] Change package manager (apk → apt)
- [x] Change default shell (ash → bash)
- [x] Update directory references
- [x] Rename classes and functions
- [x] Update UI labels
- [x] Update documentation
- [x] Change file format (.tar.gz → .tar.xz)
- [ ] Test on physical device
- [ ] Verify all test cases pass
- [ ] Update Play Store listing

## Support

If you encounter issues after migration:
1. Check logs in Android logcat
2. Verify network connectivity for package downloads
3. Ensure sufficient storage space
4. Try clearing app data and reinstalling

## Credits

- Debian rootfs provided by [termux/proot-distro](https://github.com/termux/proot-distro)
- proot tool from [proot-me/proot](https://github.com/proot-me/proot)
