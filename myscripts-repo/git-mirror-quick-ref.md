# Git Mirror Script - Quick Reference Card

## 🚀 Basic Operations
```bash
~/git-mirror-enhanced.sh              # Full sync (mirrors + working copies)
~/git-mirror-enhanced.sh --working-only   # Update working copies only
~/git-mirror-enhanced.sh --mirrors-only   # Update mirrors only  
~/git-mirror-enhanced.sh --dry-run        # Preview changes
```

## 📁 Key Paths
```bash
# Bare mirrors (for backup/cloning)
/mnt/nas/config.files/GitRepoMirror/github/user/repo.git

# Working copies (for browsing)
/mnt/nas/config.files/GitRepoMirror/working-copies/github/user/repo/

# Logs
/mnt/nas/config.files/GitRepoMirror/logs/
```

## 🔍 Browse & Search

### Browse Code
```bash
cd /mnt/nas/config.files/GitRepoMirror/working-copies/github/JaKooLit/Hyprland-Dots
ls -la
cat README.md
```

### Search Across All Repos
```bash
# Basic text search
grep -r "hyprland" /mnt/nas/config.files/GitRepoMirror/working-copies/

# Case-insensitive search  
grep -ri "HYPRLAND" /mnt/nas/config.files/GitRepoMirror/working-copies/

# Search with context
grep -r -C 3 "pattern" /mnt/nas/config.files/GitRepoMirror/working-copies/

# Search specific file types
find /mnt/nas/config.files/GitRepoMirror/working-copies/ -name "*.nix" -exec grep -l "hyprland" {} \;
```

## 📋 List & Discover

### List All Repositories
```bash
# All working copies
find /mnt/nas/config.files/GitRepoMirror/working-copies -maxdepth 3 -type d | grep -v .git

# By platform
ls /mnt/nas/config.files/GitRepoMirror/working-copies/github/
ls /mnt/nas/config.files/GitRepoMirror/working-copies/gitlab/

# By user
ls /mnt/nas/config.files/GitRepoMirror/working-copies/github/JaKooLit/

# Count total repos
find /mnt/nas/config.files/GitRepoMirror -name "*.git" -type d | wc -l
```

### Find Large/Recent Repos
```bash
# Show sizes
du -sh /mnt/nas/config.files/GitRepoMirror/working-copies/github/*/* | sort -hr

# Recent updates (last 7 days)
find /mnt/nas/config.files/GitRepoMirror/working-copies -type d -mtime -7 -maxdepth 3
```

## 📥 Clone from Mirrors

### Fast Local Clone
```bash
# Clone from mirror (super fast!)
git clone /mnt/nas/config.files/GitRepoMirror/github/JaKooLit/Hyprland-Dots.git ~/my-config

# Clone specific branch
git clone -b develop /mnt/nas/config.files/GitRepoMirror/github/user/repo.git

# Clone to current directory
git clone /mnt/nas/config.files/GitRepoMirror/github/user/repo.git
```

## 🔧 Maintenance

### Check Storage
```bash
# Total usage
du -sh /mnt/nas/config.files/GitRepoMirror/

# Platform breakdown
du -sh /mnt/nas/config.files/GitRepoMirror/*/

# Largest repos
du -sh /mnt/nas/config.files/GitRepoMirror/*/* | sort -hr | head -10
```

### Monitor & Logs
```bash
# View latest log
tail -f /mnt/nas/config.files/GitRepoMirror/logs/mirror-*.log

# Check for errors
grep "ERROR\|FAILED" /mnt/nas/config.files/GitRepoMirror/logs/mirror-*.log

# View summaries
grep "SUMMARY" /mnt/nas/config.files/GitRepoMirror/logs/mirror-*.log | tail -5
```

## ⚡ Quick Examples

### Research Hyprland Configs
```bash
cd /mnt/nas/config.files/GitRepoMirror/working-copies/github/
grep -r "monitor" */Hypr* | head -10
find . -name "hyprland.conf" -exec head -5 {} \;
```

### Find NixOS Examples
```bash
grep -r "programs.hyprland" /mnt/nas/config.files/GitRepoMirror/working-copies/github/*/
find /mnt/nas/config.files/GitRepoMirror/working-copies/ -name "*.nix" | head -10
```

### Copy Template Project
```bash
cp -r /mnt/nas/config.files/GitRepoMirror/working-copies/github/user/template ~/my-project
cd ~/my-project && git init
```

## 🔄 Automation
```bash
# Add to crontab for weekly sync
crontab -e
# Add: 0 3 * * 0 /home/dwilliams/git-mirror-enhanced.sh

# Quick working-only update
~/git-mirror-enhanced.sh --working-only
```

## 🆘 Troubleshooting
```bash
# Fix permissions
sudo chown -R $USER:$USER /mnt/nas/config.files/GitRepoMirror/working-copies/

# Reset working copy with local changes
cd /path/to/working-copy
git reset --hard origin/main && git clean -fd

# Check available space
df -h /mnt/nas/
```

---
**💡 Pro Tips:**
- Use `--working-only` for quick browsing updates
- Search before you code - someone might have solved it!
- Clone from mirrors for lightning-fast local development
- Monitor logs to catch sync issues early
- Your mirrors preserve repos even if they disappear online!
