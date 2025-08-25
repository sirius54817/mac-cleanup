# macOS System Cache Cleaner

A comprehensive, interactive bash/zsh script for macOS that clears various cache data and empties the trash to free up storage space. The script prompts you for confirmation before each cleanup operation, giving you full control over what gets cleaned.

## Features

### Interactive Cleanup Process
- **User confirmation prompts** - Ask y/n for each cleanup operation
- **Selective cleaning** - Choose which caches to clean, skip others
- **Safe operation** - Shows directory sizes before deletion
- **Error handling** - Continues execution even if some operations fail
- **Colored output** - Clear status messages with color coding

### System Caches Cleaned
- **Homebrew cache and logs** - Clears brew cache, logs, and runs cleanup/autoremove
- **User Library caches** - Clears ~/Library/Caches
- **Application-specific caches** - Safari, Chrome, Firefox caches
- **System and user logs** - Clears log files
- **Quick Look cache** - Thumbnail cache
- **Spotlight cache** - Rebuilds Spotlight index

### Development Tool Caches
- **Xcode** - DerivedData, Archives, Simulator cache
- **npm cache** - Node.js package cache
- **yarn cache** - Yarn package cache
- **pip cache** - Python package cache
- **Docker cache** - Docker system cleanup

### File Cleanup
- **Trash** - Empties user trash
- **Downloads cleanup** - Removes old .dmg, .zip, .pkg files (30+ days)
- **Temporary files** - System and user temp files
- **Mail cache** - Mail envelope index cache
- **Photos cache** - Photos library cache

## Usage

### Basic Usage
```bash
./clear_system_cache.sh
```

### With sudo privileges (recommended for full cleanup)
```bash
sudo ./clear_system_cache.sh
```

## Interactive Prompts

The script will ask you for confirmation before each cleanup operation:

```bash
==============================================
    macOS System Cache Cleaner
==============================================

Do you want to clean Homebrew cache and logs? (y/n): y
[INFO] Cleaning Homebrew cache...
[SUCCESS] Homebrew cache cleared

Do you want to clean user Library caches? (y/n): n
[INFO] Skipping user Library caches cleanup

Do you want to clean application-specific caches (Safari, Chrome, Firefox)? (y/n): y
[INFO] Cleaning selective Application Support caches...
[INFO] Cleaning Safari cache... (Current size: 45M)
[SUCCESS] Cleaned Safari cache
...
```

### Response Options
- **y/yes** - Proceed with the cleanup operation
- **n/no** or any other input - Skip the operation and continue to the next

## Requirements

- macOS
- zsh or bash shell
- Some operations require sudo privileges for maximum effectiveness

## Safety Features

- **Safe removal function** - Shows size before deletion and handles errors gracefully
- **Conditional checks** - Only attempts cleanup if directories/tools exist
- **Error handling** - Continues execution even if some operations fail
- **User confirmation** - Interactive prompts prevent accidental deletions
- **Preserves directory structures** - Only removes contents, not directories

## What Gets Cleaned

### System Caches
- `~/Library/Caches/` - User application caches
- `~/Library/Logs/` - User application logs
- `/private/var/log/` - System logs (requires sudo)
- `~/Library/Caches/com.apple.QuickLook.thumbnailcache/` - Quick Look thumbnails

### Application Caches
- Safari cache files
- Chrome application cache
- Firefox profile caches
- Mail envelope index
- Photos library cache

### Development Tools
- Xcode DerivedData, Archives, and Simulator caches
- npm cache directory
- yarn cache directory
- pip cache directory
- Docker unused containers, images, and volumes

### File Cleanup
- Trash contents (`~/.Trash/`)
- Old installer files in Downloads (30+ days old)
- System temporary files (`/private/tmp/`)
- User temporary files (`$TMPDIR`)

## Sample Output

```
==============================================
    macOS System Cache Cleaner
==============================================

[INFO] Getting initial disk usage...
/dev/disk3s1s1   228Gi  180Gi   47Gi    80%    1,787,275 9,223,372,036,853,027,540   0%   /

[INFO] Starting cache cleanup process...

Do you want to clean Homebrew cache and logs? (y/n): y
[INFO] Cleaning Homebrew cache...
[SUCCESS] Homebrew cache cleared

Do you want to clean user Library caches? (y/n): y
[INFO] Cleaning User Library caches... (Current size: 2.1G)
[SUCCESS] Cleaned User Library caches

Do you want to clean application-specific caches (Safari, Chrome, Firefox)? (y/n): n
[INFO] Skipping application-specific caches cleanup

...

[SUCCESS] System cache cleanup completed successfully!
[INFO] Final disk usage:
/dev/disk3s1s1   228Gi  175Gi   52Gi    77%    1,650,123 9,223,372,036,853,027,540   0%   /
```

## Notes

- **Some operations require admin privileges** - Run with `sudo` for full cleanup
- **Applications may need restart** - Some apps may need to be restarted after cache cleanup
- **Consider restarting your Mac** - For complete cache clearing
- **Safe operation** - The script preserves directory structures and handles errors gracefully

## Troubleshooting

### Permission Errors
If you encounter permission errors:
1. Run the script with `sudo`
2. Check that you have the necessary permissions
3. Some operations (like system log cleanup) require admin privileges

### Tools Not Found
The script will skip cleanup operations for tools that aren't installed:
- Homebrew operations are skipped if brew is not found
- npm/yarn/pip operations are skipped if not installed
- Docker operations are skipped if Docker is not available

### Large Cache Directories
The script shows the size of each cache directory before cleaning, so you can decide whether to proceed with large cleanups.

## Customization

You can modify the script to:
- Add more cache directories
- Exclude certain cleanup operations
- Adjust file age thresholds for Downloads cleanup
- Add additional development tool cache cleanup
- Change the confirmation prompts

## Contributing

Feel free to submit issues or pull requests to improve the script.

## License

This project is open source. Use at your own risk.
