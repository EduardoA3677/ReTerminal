# Pre-Release Testing Checklist

This checklist should be completed by the maintainer before releasing the Debian migration to users.

## Device Testing

### Android Version Testing
- [ ] Android 9 (API 28)
- [ ] Android 10 (API 29)
- [ ] Android 11 (API 30)
- [ ] Android 12 (API 31)
- [ ] Android 13 (API 33)
- [ ] Android 14 (API 34)
- [ ] Android 15 (API 35) if available

### Device Manufacturer Testing
- [ ] Samsung device
- [ ] Google Pixel device
- [ ] OnePlus/Oppo device
- [ ] Xiaomi device
- [ ] Other manufacturer

### Architecture Testing
- [ ] x86_64 device (emulator acceptable)
- [ ] arm64-v8a device (most modern phones)
- [ ] armeabi-v7a device (older phones)

## Functional Testing

### First Launch
- [ ] App installs successfully
- [ ] Initial download starts
- [ ] Progress indicator shows correctly
- [ ] Download completes successfully
- [ ] Debian environment initializes
- [ ] Terminal prompt appears
- [ ] bash shell is running

### Package Manager
- [ ] `apt update` works
- [ ] `apt upgrade` works
- [ ] `apt install htop` works
- [ ] `apt search python3` works
- [ ] `apt remove htop` works
- [ ] `dpkg -l` shows packages

### Basic Commands
- [ ] `ls` command works
- [ ] `cd` command works
- [ ] `pwd` command works
- [ ] `cat /etc/os-release` shows Debian
- [ ] `echo $SHELL` shows /bin/bash
- [ ] `bash --version` shows version

### File Operations
- [ ] Create file: `touch test.txt`
- [ ] Write file: `echo "test" > test.txt`
- [ ] Read file: `cat test.txt`
- [ ] Delete file: `rm test.txt`
- [ ] Create directory: `mkdir testdir`
- [ ] Delete directory: `rmdir testdir`

### Multiple Sessions
- [ ] Can create new session
- [ ] Can switch between sessions
- [ ] Each session is independent
- [ ] Can close individual sessions
- [ ] Sessions persist between switches

### Document Provider
- [ ] File manager shows "ReTerminal"
- [ ] Can browse /root directory
- [ ] Can create files via file manager
- [ ] Can edit files via file manager
- [ ] Changes reflect in terminal

### Network Functionality
- [ ] DNS resolution works: `cat /etc/resolv.conf`
- [ ] Can ping: `apt install iputils-ping && ping -c 3 8.8.8.8`
- [ ] Can download: `apt install curl && curl -I https://debian.org`
- [ ] Package downloads work

### Development Tools
- [ ] Python installation: `apt install python3`
- [ ] Python works: `python3 --version`
- [ ] Node.js installation: `apt install nodejs npm`
- [ ] Node.js works: `node --version`
- [ ] Git installation: `apt install git`
- [ ] Git works: `git --version`

### Storage Testing
- [ ] Check on device with <2GB free space
- [ ] App warns about storage if applicable
- [ ] Download doesn't fill up storage completely
- [ ] `apt clean` reduces storage usage

### Performance Testing
- [ ] App launches within reasonable time (<5 sec)
- [ ] Terminal is responsive
- [ ] No significant lag when typing
- [ ] Heavy packages install without issues
- [ ] Multiple sessions don't cause slowdown

### UI Testing
- [ ] Settings menu works
- [ ] Working mode selection works (Debian/Android)
- [ ] Terminal font size adjustment works
- [ ] Virtual keys work correctly
- [ ] Copy/paste works
- [ ] Tab switching works

### Error Handling
- [ ] Network loss during download is handled
- [ ] Invalid package names show error
- [ ] Permission errors are clear
- [ ] App doesn't crash on errors

## Validation Script Testing

### Run Validation Script
- [ ] Transfer validate_debian.sh to device
- [ ] Run: `sh validate_debian.sh`
- [ ] All core tests pass
- [ ] Network tests pass (if connected)
- [ ] No unexpected failures

## Regression Testing

### Previous Features
- [ ] Android shell mode still works
- [ ] Virtual keys still work
- [ ] Multiple sessions still work
- [ ] Settings are preserved
- [ ] Theme settings work
- [ ] Font settings work

## Documentation Testing

### User Documentation
- [ ] README.md is clear and accurate
- [ ] DEBIAN_MIGRATION.md is helpful
- [ ] FAQ answers common questions
- [ ] Troubleshooting section is useful
- [ ] Examples work as written

### Technical Documentation
- [ ] RISK_ASSESSMENT.md is complete
- [ ] SUMMARY.md is accurate
- [ ] Code comments are clear

## Security Testing

### Security Considerations
- [ ] No credentials in code
- [ ] Download URLs are HTTPS
- [ ] File permissions are appropriate
- [ ] No unnecessary permissions requested
- [ ] CodeQL scan passed

## Build Testing

### APK Building
- [ ] App builds successfully
- [ ] APK size is reasonable
- [ ] Debug build works
- [ ] Release build works
- [ ] Signed APK works

## User Experience Testing

### New Users
- [ ] First-time setup is smooth
- [ ] Instructions are clear
- [ ] No confusing errors
- [ ] Progress indicators are helpful

### Existing Users
- [ ] Update process is smooth
- [ ] Migration guide is available
- [ ] Data loss is clearly communicated
- [ ] Instructions for migration are clear

## Edge Cases

### Low-End Devices
- [ ] Works on devices with 2GB RAM
- [ ] Works with limited storage
- [ ] Acceptable performance on older CPU

### Special Scenarios
- [ ] Works in airplane mode (after initial setup)
- [ ] Works with VPN
- [ ] Works with restricted networks
- [ ] Survives app restart
- [ ] Survives device restart

## Community Testing

### Beta Testing
- [ ] Provide APK to beta testers
- [ ] Gather feedback
- [ ] Address critical issues
- [ ] Document known issues

## Pre-Release Checklist

### Code
- [ ] All code reviewed
- [ ] All comments addressed
- [ ] No TODO items remaining
- [ ] Version number updated
- [ ] Changelog updated

### Documentation
- [ ] All documentation complete
- [ ] Screenshots updated if needed
- [ ] FAQ updated
- [ ] Known issues documented

### Release Preparation
- [ ] Release notes written
- [ ] App store description updated
- [ ] Telegram announcement prepared
- [ ] GitHub release prepared

## Post-Release Monitoring

### First 24 Hours
- [ ] Monitor crash reports
- [ ] Check user feedback
- [ ] Respond to issues quickly
- [ ] Track download metrics

### First Week
- [ ] Weekly feedback summary
- [ ] Address critical bugs
- [ ] Update FAQ if needed
- [ ] Communicate with community

## Rollback Preparation

### Rollback Plan
- [ ] Previous Alpine version tagged
- [ ] Rollback procedure documented
- [ ] Team knows rollback steps
- [ ] Can rollback within 1 hour if needed

## Sign-off

Once all items are checked:

- [ ] Testing completed by: ___________________
- [ ] Date: ___________________
- [ ] Ready for release: YES / NO
- [ ] Rollback plan confirmed: YES / NO

## Notes

Use this section to document any issues found during testing:

```
Issue 1:
Description:
Severity:
Status:

Issue 2:
Description:
Severity:
Status:
```

## Recommendations

Based on testing, recommend:
- [ ] Release immediately
- [ ] Address issues first
- [ ] More testing needed
- [ ] Beta release first

---

**Remember**: Better to delay release and fix issues than to release with problems!
