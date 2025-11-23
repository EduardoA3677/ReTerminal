# Quick Reference - Alpine to Debian Migration

## What Changed?

### Before (Alpine)
```bash
# Package Manager
apk update
apk add package-name

# Shell
/bin/ash

# Rootfs
alpine.tar.gz from alpinelinux.org
```

### After (Debian)
```bash
# Package Manager
apt update
apt install -y package-name

# Shell
/bin/bash

# Rootfs
debian.tar.xz from termux/proot-distro
```

## Quick Test Commands

### After Installation
```bash
# Verify shell
echo $SHELL
# Should output: /bin/bash

# Verify OS
cat /etc/os-release
# Should show: Debian

# Verify package manager
apt --version
# Should show: apt version

# Install a package
apt update
apt install -y curl
curl --version
```

## Files Changed Map

| Old Reference | New Reference |
|--------------|---------------|
| `ALPINE_DIR` | `DEBIAN_DIR` |
| `alpine.tar.gz` | `debian.tar.xz` |
| `alpineDir()` | `debianDir()` |
| `alpineHomeDir()` | `debianHomeDir()` |
| `AlpineDocumentProvider` | `DebianDocumentProvider` |
| `WorkingMode.ALPINE` | `WorkingMode.DEBIAN` |
| `apk` commands | `apt` commands |
| `/bin/ash` | `/bin/bash` |

## Validation
```bash
# Run automated tests
./validate-debian-migration.sh

# Should output: ✓ All tests passed!
```

## Build & Test
```bash
# 1. Validate code
./validate-debian-migration.sh

# 2. Build APK (requires Android SDK setup)
./gradlew assembleDebug

# 3. Install on device
adb install app/build/outputs/apk/debug/app-debug.apk

# 4. Test on device
# Follow tests in DEBIAN_MIGRATION.md
```

## Architecture URLs

### x86_64 (AMD64)
```
https://github.com/termux/proot-distro/releases/download/v4.19.1/debian-amd64-pd-v4.19.1.tar.xz
```

### ARM64 (aarch64)
```
https://github.com/termux/proot-distro/releases/download/v4.19.1/debian-aarch64-pd-v4.19.1.tar.xz
```

### ARMv7 (arm)
```
https://github.com/termux/proot-distro/releases/download/v4.19.1/debian-arm-pd-v4.19.1.tar.xz
```

## Common Issues & Solutions

### Issue: Build fails with plugin not found
**Cause**: Gradle plugin repositories unreachable  
**Solution**: Check network, try with VPN, or use local Gradle cache

### Issue: App downloads but doesn't extract
**Cause**: Insufficient storage space  
**Solution**: Ensure device has at least 200MB free space

### Issue: apt update fails
**Cause**: DNS or network issue inside container  
**Solution**: Check /etc/resolv.conf has valid nameserver

### Issue: Package not found
**Cause**: Package repositories not updated  
**Solution**: Run `apt update` first

## Rollback Instructions

If you need to revert to Alpine:

```bash
# 1. Find the migration commit
git log --oneline

# 2. Revert the changes
git revert <commit-hash>

# 3. Push the revert
git push

# 4. On device: Clear app data and reinstall
```

## Documentation Files

1. **DEBIAN_MIGRATION.md** - Complete guide (English)
2. **RESUMEN_MIGRACION.md** - Summary (Spanish)  
3. **validate-debian-migration.sh** - Automated tests
4. **QUICK_REFERENCE.md** - This file

## Support Resources

- Debian Documentation: https://www.debian.org/doc/
- termux/proot-distro: https://github.com/termux/proot-distro
- APT Documentation: https://wiki.debian.org/Apt

## Status Indicators

✅ = Completed and verified  
⚠️ = Completed but needs device testing  
❌ = Not completed

Current Status:
- ✅ Code migration
- ✅ Automated tests (36/36 passed)
- ✅ Documentation
- ⚠️ Device testing (pending)
- ⚠️ Play Store update (pending)

## Quick Stats

- **Files Changed**: 16
- **Lines Added**: 714
- **Lines Removed**: 49
- **Test Coverage**: 36 automated tests
- **Manual Tests**: 10 device tests
- **Documentation**: 3 comprehensive guides

## Contact & Support

For issues or questions:
1. Check DEBIAN_MIGRATION.md for detailed troubleshooting
2. Review test results from validate-debian-migration.sh
3. Create an issue on GitHub with details

---
Last Updated: 2025-01-23  
Migration Version: 1.0  
Debian Version: Stable (Bookworm)
