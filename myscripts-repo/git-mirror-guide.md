# Enhanced Git Repository Mirror Script - User Guide

## Overview

The Enhanced Git Repository Mirror Script creates and maintains both **bare mirrors** (for backup) and **working copies** (for browsing/using code) of Git repositories from multiple platforms. This is perfect for preserving archived repositories and maintaining offline access to your favorite projects.

## Quick Start

```bash
# Full sync (mirrors + working copies)
~/git-mirror-enhanced.sh

# Only update working copies from existing mirrors
~/git-mirror-enhanced.sh --working-only

# Only update mirrors (no working copies)
~/git-mirror-enhanced.sh --mirrors-only

# See what would happen without making changes
~/git-mirror-enhanced.sh --dry-run
```

## Directory Structure

Your repositories are organized in a clear, hierarchical structure:

```
/mnt/nas/config.files/GitRepoMirror/
├── 📁 github/                     # GitHub repositories
│   ├── user1/repo1.git           # Bare mirrors (backup)
│   └── user2/repo2.git
├── 📁 gitlab/                     # GitLab repositories
│   └── user/repo.git
├── 📁 working-copies/             # Browsable code
│   ├── 📁 github/
│   │   ├── user1/repo1/          # Working directories
│   │   └── user2/repo2/
│   └── 📁 gitlab/
│       └── user/repo/
└── 📁 logs/                       # Operation logs
    └── mirror-YYYYMMDD-HHMMSS.log
```

## Script Operations

### 1. Full Synchronization (Default)
```bash
~/git-mirror-enhanced.sh
```
- Updates all bare mirrors from remote repositories
- Creates/updates working copies from mirrors
- Downloads only changes (incremental sync)
- Creates new mirrors for newly discovered repositories

### 2. Working Copies Only
```bash
~/git-mirror-enhanced.sh --working-only
```
- Updates working copies from existing mirrors
- Does NOT sync with remote repositories
- Fast operation for browsing latest local changes
- Useful when remote access is limited

### 3. Mirrors Only
```bash
~/git-mirror-enhanced.sh --mirrors-only
```
- Updates only bare mirrors from remotes
- Does NOT create/update working copies
- Minimizes storage usage
- Good for pure backup scenarios

### 4. Dry Run
```bash
~/git-mirror-enhanced.sh --dry-run
```
- Shows what would be done without making changes
- Useful for testing configuration changes
- Safe way to preview operations

## Configuration

Edit the script to customize your mirror setup:

```bash
nano ~/git-mirror-enhanced.sh
```

Key configuration sections:

### Destination Paths
```bash
DESTINATION_ROOT="/mnt/nas/config.files/GitRepoMirror"
WORKING_COPIES_ROOT="${DESTINATION_ROOT}/working-copies"
CREATE_WORKING_COPIES=true  # Set to false for mirrors only
```

### GitHub Users
```bash
GITHUB_USERS=(
    "JaKooLit"
    "dwilliam62"
    "your-username"
)
```

### GitLab Users
```bash
GITLAB_USERS=(
    "dwilliam62"
    "zaney"
    "your-gitlab-username"
)
```

### Excluded Repositories
```bash
EXCLUDED_REPOS=(
    "github/user/very-large-repo"  # Skip specific repositories
    "gitlab/user/unwanted-repo"
)
```

## Working with Your Mirrored Repositories

### Browsing Code

Navigate to any repository to browse files:

```bash
# Browse a specific repository
cd /mnt/nas/config.files/GitRepoMirror/working-copies/github/JaKooLit/Hyprland-Dots
ls -la

# View file contents
cat README.md
less config/hypr/hyprland.conf

# Browse with your favorite editor
code /mnt/nas/config.files/GitRepoMirror/working-copies/github/JaKooLit/Hyprland-Dots
```

### Cloning Repositories

Clone from your local mirrors for development (super fast!):

```bash
# Clone from mirror for development
git clone /mnt/nas/config.files/GitRepoMirror/github/JaKooLit/Hyprland-Dots.git ~/my-hyprland-config

# Clone to current directory
git clone /mnt/nas/config.files/GitRepoMirror/github/fufexan/nix-gaming.git

# Clone specific branch
git clone -b develop /mnt/nas/config.files/GitRepoMirror/github/user/repo.git
```

### Searching Across Repositories

Find specific code patterns across all your mirrored repositories:

```bash
# Search for specific text across all working copies
grep -r "hyprland" /mnt/nas/config.files/GitRepoMirror/working-copies/

# Search in specific platform
grep -r "nixos" /mnt/nas/config.files/GitRepoMirror/working-copies/github/

# Search for file types
find /mnt/nas/config.files/GitRepoMirror/working-copies/ -name "*.nix" -exec grep -l "hyprland" {} \;

# Search with context lines
grep -r -C 3 "hyprpaper" /mnt/nas/config.files/GitRepoMirror/working-copies/github/

# Case-insensitive search
grep -ri "HYPRLAND" /mnt/nas/config.files/GitRepoMirror/working-copies/

# Search excluding certain directories
grep -r --exclude-dir=".git" --exclude-dir="node_modules" "pattern" /path/to/working-copies/
```

### Listing and Discovering Repositories

```bash
# List all mirrored repositories
find /mnt/nas/config.files/GitRepoMirror/working-copies -maxdepth 3 -type d -name '*' | grep -v .git

# List repositories by platform
ls /mnt/nas/config.files/GitRepoMirror/working-copies/github/
ls /mnt/nas/config.files/GitRepoMirror/working-copies/gitlab/

# List repositories by user
ls /mnt/nas/config.files/GitRepoMirror/working-copies/github/JaKooLit/

# Count total repositories
find /mnt/nas/config.files/GitRepoMirror -name "*.git" -type d | wc -l

# Show repository sizes
du -sh /mnt/nas/config.files/GitRepoMirror/working-copies/github/*/* | sort -hr

# Find recently updated repositories
find /mnt/nas/config.files/GitRepoMirror/working-copies -type d -mtime -7 -maxdepth 3
```

### Advanced Repository Operations

```bash
# Check git status of a working copy
cd /mnt/nas/config.files/GitRepoMirror/working-copies/github/user/repo
git status
git log --oneline -10

# View all branches in a repository
cd /mnt/nas/config.files/GitRepoMirror/working-copies/github/user/repo
git branch -a

# Switch branches in working copy
git checkout develop
git checkout -b feature-branch origin/feature-branch

# View repository information
cd /mnt/nas/config.files/GitRepoMirror/working-copies/github/user/repo
git remote -v
git branch -a
git tag
```

## Automation and Maintenance

### Setting Up Automated Sync

Add to your crontab for automatic updates:

```bash
# Edit crontab
crontab -e

# Add line for daily sync at 2 AM
0 2 * * * /home/dwilliams/git-mirror-enhanced.sh >> /var/log/git-mirror.log 2>&1

# Or weekly sync on Sunday at 3 AM
0 3 * * 0 /home/dwilliams/git-mirror-enhanced.sh
```

### Monitoring and Logs

```bash
# View latest log file
ls -la /mnt/nas/config.files/GitRepoMirror/logs/
tail -f /mnt/nas/config.files/GitRepoMirror/logs/mirror-*.log

# Check for failed operations
grep "ERROR\|FAILED" /mnt/nas/config.files/GitRepoMirror/logs/mirror-*.log

# View summary statistics
grep "SUMMARY" /mnt/nas/config.files/GitRepoMirror/logs/mirror-*.log | tail -5
```

### Storage Management

```bash
# Check total storage usage
du -sh /mnt/nas/config.files/GitRepoMirror/

# Check platform usage
du -sh /mnt/nas/config.files/GitRepoMirror/*/

# Find largest repositories
du -sh /mnt/nas/config.files/GitRepoMirror/*/* | sort -hr | head -20

# Clean up old logs (keep last 30 days)
find /mnt/nas/config.files/GitRepoMirror/logs/ -name "mirror-*.log" -mtime +30 -delete
```

## Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Fix ownership
   sudo chown -R $USER:$USER /mnt/nas/config.files/GitRepoMirror/working-copies/
   
   # Fix permissions
   chmod -R u+w /mnt/nas/config.files/GitRepoMirror/working-copies/
   ```

2. **Storage Full**
   ```bash
   # Check available space
   df -h /mnt/nas/
   
   # Clean up large repositories or exclude them in configuration
   # Edit EXCLUDED_REPOS in the script
   ```

3. **Network Issues**
   ```bash
   # Use --working-only mode when remote access is limited
   ~/git-mirror-enhanced.sh --working-only
   ```

4. **Working Copy Conflicts**
   ```bash
   # If working copy has local changes, reset it
   cd /path/to/working-copy
   git reset --hard origin/main
   git clean -fd
   ```

### Verification Commands

```bash
# Verify mirror integrity
cd /mnt/nas/config.files/GitRepoMirror/github/user/repo.git
git fsck

# Verify working copy is up to date
cd /mnt/nas/config.files/GitRepoMirror/working-copies/github/user/repo
git status
git fetch && git status
```

## Best Practices

1. **Regular Sync**: Run the script weekly or monthly to keep repositories current
2. **Monitor Logs**: Check logs regularly for failed operations
3. **Storage Planning**: Monitor storage usage and exclude very large repositories if needed
4. **Backup Strategy**: The mirrors serve as backups, but consider additional backup of the entire mirror directory
5. **Network Efficiency**: Use `--working-only` mode when you only need to browse existing mirrors
6. **Clean Working Copies**: Avoid making changes in working copies; clone separately for development

## Use Cases

### 1. Code Research and Learning
```bash
# Browse architecture patterns
find /mnt/nas/config.files/GitRepoMirror/working-copies -name "*.py" -exec grep -l "class.*Manager" {} \;

# Study configuration examples  
grep -r "monitor" /mnt/nas/config.files/GitRepoMirror/working-copies/github/*/Hypr*
```

### 2. Project Templates
```bash
# Use as project templates
cp -r /mnt/nas/config.files/GitRepoMirror/working-copies/github/user/template-repo ~/my-new-project
cd ~/my-new-project && git init
```

### 3. Offline Development
```bash
# Clone for offline development
git clone /mnt/nas/config.files/GitRepoMirror/github/user/repo.git ~/dev/my-fork
cd ~/dev/my-fork
# Work offline, push when back online
```

### 4. Archive Preservation
Your mirrors preserve repositories even if they're deleted from the original hosting platform. This is invaluable for:
- Discontinued projects you depend on
- Educational resources
- Historical reference
- Backup of your own work

## Script Maintenance

### Updating Repository Lists
When you discover new users/repositories to mirror:

1. Edit the script:
   ```bash
   nano ~/git-mirror-enhanced.sh
   ```

2. Add to the appropriate array:
   ```bash
   GITHUB_USERS=(
       "existing-user"
       "new-user"  # Add here
   )
   ```

3. Run full sync to fetch new repositories:
   ```bash
   ~/git-mirror-enhanced.sh
   ```

### Excluding Repositories
To exclude large or unwanted repositories:

```bash
EXCLUDED_REPOS=(
    "github/user/huge-dataset"
    "github/user/binary-releases"
)
```

Remember: This guide covers your enhanced Git mirror script. Keep this file handy as your reference for all mirror operations!
