# Debian Migration Guide

## Overview
ReTerminal has been successfully migrated from Alpine Linux to Debian Trixie. This document explains the migration, how to use the new Debian environment, and how to validate the functionality.

## What Changed

### Distribution
- **Before**: Alpine Linux v3.21 (musl libc based)
- **After**: Debian Trixie (GNU libc based)

### Package Manager
- **Before**: `apk` (Alpine Package Keeper)
- **After**: `apt` (Advanced Package Tool)

### Default Shell
- **Before**: `/bin/ash` (Almquist shell)
- **After**: `/bin/bash` (Bourne Again Shell)

### Root Filesystem Images
The app now downloads Debian Trixie rootfs from the official proot-distro releases:
- **x86_64**: debian-trixie-x86_64-pd-v4.26.0.tar.xz
- **arm64-v8a** (aarch64): debian-trixie-aarch64-pd-v4.26.0.tar.xz
- **armeabi-v7a** (armhf): debian-trixie-armhf-pd-v4.26.0.tar.xz

## Benefits of Debian

### Advantages
1. **Larger Package Repository**: Access to thousands more packages via apt
2. **Better Compatibility**: More software is tested and built for Debian
3. **GNU Compatibility**: Full GNU userland with glibc
4. **Mature Ecosystem**: Debian is one of the oldest and most stable Linux distributions
5. **Better Documentation**: Extensive documentation and community support

### Package Management
```bash
# Update package lists
apt update

# Upgrade installed packages
apt upgrade -y

# Install a package
apt install package-name

# Search for a package
apt search keyword

# Remove a package
apt remove package-name

# Clean package cache
apt clean
```

## Using Debian in ReTerminal

### First Launch
When you first open ReTerminal after the migration:
1. The app will download the Debian Trixie rootfs (varies by architecture)
2. Essential packages (bash, nano) will be automatically installed
3. You'll be greeted with a bash prompt

### Default Environment
- **User**: root
- **Home Directory**: /root
- **Shell**: bash
- **Pre-installed packages**: bash, nano

### Installing Software
Common package installation examples:
```bash
# Development tools
apt install git build-essential

# Programming languages
apt install python3 python3-pip nodejs npm golang

# Text editors
apt install vim emacs nano

# Network tools
apt install curl wget net-tools

# System utilities
apt install htop tmux screen
```

## Validation Tests

### Test 1: Basic Shell Functionality
```bash
# Test bash is running
echo $SHELL
# Expected output: /bin/bash

# Test bash features
echo "Bash version: $BASH_VERSION"
# Should show bash version

# Test command substitution
echo "Current directory: $(pwd)"
# Should show current directory
```

### Test 2: Package Manager
```bash
# Update package lists
apt update
# Should successfully download package lists

# Install a test package
apt install -y htop
# Should install successfully

# Verify installation
which htop
# Should output: /usr/bin/htop

# Run the package
htop --version
# Should show htop version
```

### Test 3: File System Operations
```bash
# Create a test file
echo "Hello from Debian!" > /root/test.txt

# Read the file
cat /root/test.txt
# Should output: Hello from Debian!

# Check permissions
ls -la /root/test.txt
# Should show file permissions

# Clean up
rm /root/test.txt
```

### Test 4: Network Functionality
```bash
# Test DNS resolution
cat /etc/resolv.conf
# Should show nameserver 8.8.8.8

# Test network connectivity (if available)
ping -c 3 8.8.8.8
# Should ping successfully

# Test HTTP requests
apt install -y curl
curl -I https://debian.org
# Should return HTTP headers
```

### Test 5: Development Environment
```bash
# Install Python
apt install -y python3

# Test Python
python3 --version
# Should show Python version

# Run a simple Python script
python3 -c "print('Hello from Python on Debian!')"
# Should output: Hello from Python on Debian!

# Install Node.js
apt install -y nodejs npm

# Test Node.js
node --version
npm --version
# Should show versions
```

### Test 6: Multiple Sessions
1. Create a new session in ReTerminal
2. Verify both sessions are independent
3. Run different commands in each session
4. Verify session persistence

### Test 7: File Access via Document Provider
1. Open a file manager app on Android
2. Look for "ReTerminal" in the storage providers
3. Navigate to the Debian root home directory
4. Create/edit files through the document provider
5. Verify changes are reflected in the terminal

## Troubleshooting

### Issue: Package installation fails
**Solution**: Run `apt update` first to refresh package lists
```bash
apt update
apt install package-name
```

### Issue: "Permission denied" errors
**Solution**: You're already running as root. If the issue persists, check file permissions:
```bash
chmod +x filename
```

### Issue: Network connectivity problems
**Solution**: Check DNS configuration:
```bash
cat /etc/resolv.conf
# Should contain: nameserver 8.8.8.8
```

### Issue: Storage space
**Solution**: Clean package cache:
```bash
apt clean
apt autoremove
```

### Issue: Missing libraries
**Solution**: Debian uses glibc, not musl. Most binaries should work, but if you have issues:
```bash
apt install libc6
```

## Migration Impact on Users

### For Existing Users
- **App data will be reset**: The Debian rootfs is stored separately from Alpine
- **Installed packages will need reinstallation**: Alpine packages are not compatible
- **Scripts may need updates**: Change `apk` commands to `apt`
- **Settings are preserved**: ReTerminal app settings remain unchanged

### For New Users
- No action needed
- The app will automatically download and setup Debian

## Performance Considerations

### Storage
- **Debian rootfs size**: ~100-150 MB compressed, ~400-500 MB extracted
- **Alpine rootfs size**: ~2-3 MB compressed, ~10-15 MB extracted
- **Trade-off**: Debian is larger but provides more functionality

### Startup Time
- First launch: Longer (downloading Debian rootfs)
- Subsequent launches: Similar to Alpine
- Package installation: Generally faster with apt

### Resource Usage
- Memory: Slightly higher due to glibc
- CPU: Similar performance
- Battery: No significant impact

## Rollback Instructions

If you need to rollback to Alpine:
1. Uninstall the current version of ReTerminal
2. Install a previous version that uses Alpine
3. Note: This will erase all data in the current Debian environment

## Advanced Configuration

### Custom Package Sources
Edit `/etc/apt/sources.list` to add additional repositories:
```bash
nano /etc/apt/sources.list
```

### Environment Variables
Add custom environment variables in `/root/.bashrc`:
```bash
echo 'export MY_VAR=value' >> /root/.bashrc
source /root/.bashrc
```

### Startup Scripts
Create initialization scripts in `/root/.bashrc` for automated setup

## Security Considerations

1. **Running as Root**: The terminal runs as root by default. Be careful with commands.
2. **Package Verification**: Debian packages are cryptographically signed
3. **Updates**: Regularly run `apt update && apt upgrade` for security patches
4. **Network Access**: The environment has network access like Alpine

## Contributing

If you find issues with the Debian migration:
1. Check the [GitHub Issues](https://github.com/EduardoA3677/ReTerminal/issues)
2. Report bugs with details about your device and Android version
3. Include steps to reproduce the issue

## Additional Resources

- [Debian Documentation](https://www.debian.org/doc/)
- [Debian Package Search](https://packages.debian.org/)
- [APT User Guide](https://www.debian.org/doc/manuals/apt-guide/)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)

## FAQ

**Q: Can I use Alpine and Debian simultaneously?**
A: No, the app supports one distribution at a time.

**Q: Will my Alpine packages work on Debian?**
A: No, Alpine uses musl libc and Debian uses glibc. Packages are incompatible.

**Q: Can I switch back to Alpine?**
A: Not in the current version. You would need to install an older version of the app.

**Q: Why Debian over Ubuntu?**
A: Debian is lighter, more stable, and proot-distro provides official support.

**Q: Does this affect Android shell mode?**
A: No, Android shell mode remains unchanged and works independently.

## Version History

- **v4.26.0**: Initial Debian Trixie migration
- Uses official proot-distro Debian images
- Replaced Alpine Linux completely
