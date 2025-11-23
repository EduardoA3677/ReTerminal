# Debian Migration Plan and Validation

## Migration Summary

This document outlines the complete migration from Alpine Linux to Debian Linux in the ReTerminal project.

## What Was Changed

### 1. Download URLs (Downloader.kt)
- **Changed**: Updated rootfs download URLs from Alpine minirootfs to Debian Bookworm
- **Details**: 
  - x86_64: Using Debian Bookworm AMD64 from debuerreotype/docker-debian-artifacts
  - arm64-v8a: Using Debian Bookworm ARM64 from debuerreotype/docker-debian-artifacts
  - armeabi-v7a: Using Debian Bookworm ARMHF from debuerreotype/docker-debian-artifacts
- **File format**: Changed from `.tar.gz` (Alpine) to `.tar.xz` (Debian)

### 2. File System Structure (FileUtil.kt)
- **Changed**: Function names and directory structure
  - `alpineDir()` → `debianDir()`
  - `alpineHomeDir()` → `debianHomeDir()`
- **Impact**: All references to Alpine directories now point to Debian directories

### 3. Document Provider (AlpineDocumentProvider.kt → DebianDocumentProvider.kt)
- **Changed**: Renamed class and updated all internal references
- **Manifest**: Updated AndroidManifest.xml to reference `DebianDocumentProvider`
- **Purpose**: Provides file system access to the Debian home directory

### 4. Working Mode (Settings.kt)
- **Changed**: Enum value `WorkingMode.ALPINE` → `WorkingMode.DEBIAN`
- **Default**: Changed default working mode to `WorkingMode.DEBIAN`
- **Impact**: All new sessions default to Debian instead of Alpine

### 5. UI Labels (TerminalScreen.kt, Settings.kt)
- **Changed**: User-facing labels and descriptions
  - "Alpine" → "Debian"
  - "Alpine Linux" → "Debian Linux"
  - "ALPINE" → "DEBIAN" in session display name

### 6. Initialization Scripts

#### init-host.sh
- **Changed**: Directory names and paths
  - `ALPINE_DIR` → `DEBIAN_DIR`
  - `/local/alpine` → `/local/debian`
  - `alpine.tar.gz` → `debian.tar.xz`

#### init.sh
- **Changed**: Package manager and shell
  - `apk` → `apt` (package manager commands)
  - `apk info -e` → `dpkg -s` (package check)
  - `apk update && apk upgrade` → `apt update && apt upgrade -y`
  - `apk add` → `apt install -y`
  - `/bin/ash` → `/bin/bash` (default shell)
  - Removed Alpine-specific packages: `gcompat` and `glib`

### 7. File Validation (Rootfs.kt)
- **Changed**: File existence check
  - `alpine.tar.gz` → `debian.tar.xz`

### 8. Session Management (MkSession.kt)
- **Changed**: Import statements and working mode checks
  - Import `debianDir` and `debianHomeDir`
  - Check for `WorkingMode.DEBIAN` instead of `WorkingMode.ALPINE`

### 9. Documentation (README.md)
- **Changed**: Feature list
  - "Alpine Linux support" → "Debian Linux support"

### 10. Data Model (TerminalCommandTraffic.kt)
- **Changed**: Field name for consistency
  - `alpine: Boolean` → `debian: Boolean`

## Validation Tests

### Test 1: Compilation
```bash
# Build the project
./gradlew clean assembleDebug

# Expected: Successful build with no errors
```

### Test 2: Debian Rootfs Download
**Steps:**
1. Install the app on an Android device/emulator
2. Launch the app for the first time
3. Observe the download progress

**Expected Results:**
- App downloads `debian.tar.xz` (instead of `alpine.tar.gz`)
- Download completes successfully
- Files extracted to `/data/data/com.rk.terminal/local/debian/`

### Test 3: Terminal Session Creation
**Steps:**
1. Create a new terminal session
2. Select "Debian" option (default)
3. Wait for session to initialize

**Expected Results:**
- Session starts with Debian environment
- Prompt shows: `root@reterm ~ $`
- Shell is bash (not ash)

### Test 4: Package Manager (apt)
**Steps:**
1. Open a Debian terminal session
2. Run: `apt update`
3. Run: `apt list --installed`
4. Run: `apt install curl`

**Expected Results:**
- `apt update` successfully updates package lists
- `apt list` shows installed Debian packages
- `apt install` successfully installs packages
- No references to `apk` command

### Test 5: File System Structure
**Steps:**
1. In terminal, run: `pwd`
2. Run: `ls -la /`
3. Check the file system structure

**Expected Results:**
- Current directory is `/root`
- Debian directory structure visible (e.g., `/usr`, `/etc`, `/bin`)
- No Alpine-specific files

### Test 6: Document Provider
**Steps:**
1. Open Android file manager
2. Look for "ReTerminal" in document providers
3. Access files through the provider

**Expected Results:**
- Provider accessible and working
- Shows Debian home directory contents
- File operations work correctly

### Test 7: Environment Variables
**Steps:**
1. In terminal, run: `env | grep -i debian`
2. Run: `echo $HOME`
3. Run: `which bash`

**Expected Results:**
- HOME is `/root`
- bash is located at `/bin/bash`
- Environment variables correctly set

### Test 8: Initial Package Installation
**Steps:**
1. Create a fresh Debian session
2. Observe automatic package installation

**Expected Results:**
- bash and nano automatically installed via apt
- Installation messages show apt commands (not apk)
- Success message displayed

### Test 9: Settings UI
**Steps:**
1. Navigate to Settings
2. Check "Default Working mode" section

**Expected Results:**
- "Debian" option visible (not "Alpine")
- "Debian Linux" description shown
- Debian selected by default

### Test 10: Multiple Sessions
**Steps:**
1. Create multiple terminal sessions
2. Switch between Debian and Android modes
3. Check session names

**Expected Results:**
- Session names show "debian" or "android"
- Each session maintains its environment
- No crashes or errors

## Troubleshooting

### Issue: Download fails
**Cause**: Network issues or invalid URLs
**Solution**: Check network connectivity, verify URLs are accessible

### Issue: Extraction fails
**Cause**: Insufficient storage or corrupted download
**Solution**: Clear app data and retry, ensure sufficient storage

### Issue: bash not found
**Cause**: Debian rootfs not properly extracted
**Solution**: Clear app data, reinstall

### Issue: apt commands fail
**Cause**: Missing /etc/resolv.conf or network configuration
**Solution**: Verify DNS configuration in init.sh

## Performance Considerations

### Debian vs Alpine Comparison

| Aspect | Alpine | Debian |
|--------|--------|--------|
| Rootfs Size | ~3-5 MB | ~50-70 MB |
| Package Manager | apk | apt |
| Default Shell | ash | bash |
| Package Availability | Limited | Extensive |
| Compatibility | Higher (musl) | Standard (glibc) |

### Storage Requirements
- Debian requires more storage space than Alpine
- Ensure device has at least 500 MB free space
- Consider adding storage check before download

## Rollback Plan

If issues arise, to rollback to Alpine:

1. Revert all commits from this migration
2. Clear app data on test devices
3. Rebuild and redeploy

## Migration Completion Checklist

- [x] Update all Alpine references to Debian
- [x] Change download URLs to Debian repositories
- [x] Update package manager commands (apk → apt)
- [x] Change default shell (ash → bash)
- [x] Update documentation
- [x] Rename classes and functions
- [x] Update UI labels and strings
- [x] Modify initialization scripts
- [ ] Build and test the application
- [ ] Verify on multiple architectures (x86_64, arm64, armhf)
- [ ] Test package installation
- [ ] Verify file system access
- [ ] Confirm environment variables
- [ ] Test document provider

## Additional Notes

### Why Debian over Alpine?

1. **Package Availability**: Debian has more packages available
2. **Compatibility**: Better compatibility with standard Linux software
3. **Community Support**: Larger community and better documentation
4. **Termux Integration**: Using termux/proot-distro ensures better compatibility

### Architecture Support

The migration maintains support for all three architectures:
- x86_64 (Intel/AMD 64-bit)
- arm64-v8a (ARM 64-bit)
- armeabi-v7a (ARM 32-bit)

### Future Improvements

1. Consider adding progress bar for extraction process
2. Add option to select different Debian versions
3. Implement better error handling for download failures
4. Add storage space check before download
5. Consider supporting multiple distributions (Ubuntu, Fedora, etc.)
