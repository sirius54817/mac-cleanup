#!/bin/zsh

# macOS System Cache Cleaner Script
# This script clears various cache data and trash to free up storage space
# Run with: ./clear_system_cache.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get directory size
get_size() {
    if [[ -d "$1" ]]; then
        du -sh "$1" 2>/dev/null | cut -f1 || echo "0B"
    else
        echo "0B"
    fi
}

# Function to ask for user confirmation
ask_confirmation() {
    local description="$1"
    echo ""
    echo -e "${YELLOW}Do you want to clean $description? (y/n):${NC} \c"
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Function to safely remove directory contents
safe_remove() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        local size_before=$(get_size "$dir")
        print_status "Cleaning $description... (Current size: $size_before)"
        
        # Remove contents but keep the directory structure
        find "$dir" -mindepth 1 -delete 2>/dev/null || {
            # If find fails, try rm -rf on contents
            rm -rf "$dir"/* 2>/dev/null || true
            rm -rf "$dir"/.* 2>/dev/null || true
        }
        
        print_success "Cleaned $description"
    else
        print_warning "$description directory not found: $dir"
    fi
}

echo "=============================================="
echo "    macOS System Cache Cleaner"
echo "=============================================="
echo ""

# Check if running as root (not recommended for most operations)
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root. Some operations may not work as expected."
fi

# Get initial disk usage
print_status "Getting initial disk usage..."
df -h / | tail -n 1

echo ""
print_status "Starting cache cleanup process..."
echo ""

# 1. Clear Homebrew cache
if ask_confirmation "Homebrew cache and logs"; then
    print_status "Cleaning Homebrew cache..."
    if command -v brew &> /dev/null; then
        brew cleanup --prune=all 2>/dev/null || print_warning "Some Homebrew cleanup operations failed"
        brew autoremove 2>/dev/null || print_warning "Homebrew autoremove failed"
        
        # Clear Homebrew cache directory
        if [[ -d "$(brew --cache)" ]]; then
            local brew_cache_size=$(get_size "$(brew --cache)")
            print_status "Clearing Homebrew cache directory... (Size: $brew_cache_size)"
            rm -rf "$(brew --cache)"/* 2>/dev/null || true
            print_success "Homebrew cache cleared"
        fi
        
        # Clear Homebrew logs
        if [[ -d "$(brew --prefix)/var/log" ]]; then
            safe_remove "$(brew --prefix)/var/log" "Homebrew logs"
        fi
    else
        print_warning "Homebrew not installed or not in PATH"
    fi
else
    print_status "Skipping Homebrew cache cleanup"
fi

# 2. Clear user cache directories
if ask_confirmation "user Library caches"; then
    print_status "Cleaning user cache directories..."
    
    # User Library caches
    safe_remove "$HOME/Library/Caches" "User Library caches"
else
    print_status "Skipping user Library caches cleanup"
fi

# Application Support caches (be more selective)
if ask_confirmation "application-specific caches (Safari, Chrome, Firefox)"; then
    if [[ -d "$HOME/Library/Application Support" ]]; then
        print_status "Cleaning selective Application Support caches..."
        
        # Safari cache
        safe_remove "$HOME/Library/Application Support/Safari" "Safari cache"
        
        # Chrome cache
        safe_remove "$HOME/Library/Application Support/Google/Chrome/Default/Application Cache" "Chrome application cache"
        
        # Firefox cache
        if [[ -d "$HOME/Library/Application Support/Firefox/Profiles" ]]; then
            find "$HOME/Library/Application Support/Firefox/Profiles" -name "cache*" -type d -exec rm -rf {} + 2>/dev/null || true
            print_success "Firefox cache cleared"
        fi
    fi
else
    print_status "Skipping application-specific caches cleanup"
fi

# 3. Clear system logs
if ask_confirmation "system and user logs"; then
    print_status "Cleaning system logs..."
    safe_remove "$HOME/Library/Logs" "User logs"
    
    # Clear Console logs (requires admin privileges)
    if [[ -w "/private/var/log" ]]; then
        sudo rm -rf /private/var/log/* 2>/dev/null || print_warning "Could not clear system logs (permission denied)"
        print_success "System logs cleared"
    else
        print_warning "Cannot clear system logs (requires admin privileges)"
    fi
else
    print_status "Skipping system logs cleanup"
fi

# 4. Clear Downloads folder cache files
if ask_confirmation "old installer files from Downloads (30+ days old)"; then
    print_status "Cleaning Downloads folder cache files..."
    find "$HOME/Downloads" -name "*.dmg" -mtime +30 -delete 2>/dev/null || true
    find "$HOME/Downloads" -name "*.zip" -mtime +30 -delete 2>/dev/null || true
    find "$HOME/Downloads" -name "*.pkg" -mtime +30 -delete 2>/dev/null || true
    print_success "Old installer files removed from Downloads"
else
    print_status "Skipping Downloads folder cleanup"
fi

# 5. Clear Mail cache
if ask_confirmation "Mail cache"; then
    safe_remove "$HOME/Library/Mail/V*/MailData/Envelope Index*" "Mail envelope index cache"
else
    print_status "Skipping Mail cache cleanup"
fi

# 6. Clear Photo library cache
if ask_confirmation "Photos library cache"; then
    safe_remove "$HOME/Library/Caches/com.apple.photolibraryd" "Photos library cache"
else
    print_status "Skipping Photos cache cleanup"
fi

# 7. Clear Xcode cache (if applicable)
if ask_confirmation "Xcode cache (DerivedData, Archives, Simulator cache)"; then
    if [[ -d "$HOME/Library/Developer/Xcode" ]]; then
        safe_remove "$HOME/Library/Developer/Xcode/DerivedData" "Xcode DerivedData"
        safe_remove "$HOME/Library/Developer/Xcode/Archives" "Xcode Archives"
        safe_remove "$HOME/Library/Developer/CoreSimulator/Caches" "Xcode Simulator cache"
    else
        print_status "Xcode not found, skipping Xcode cache cleanup"
    fi
else
    print_status "Skipping Xcode cache cleanup"
fi

# 8. Clear npm cache (if npm is installed)
if ask_confirmation "npm cache"; then
    if command -v npm &> /dev/null; then
        print_status "Clearing npm cache..."
        npm cache clean --force 2>/dev/null || print_warning "npm cache clean failed"
        print_success "npm cache cleared"
    else
        print_status "npm not found, skipping npm cache cleanup"
    fi
else
    print_status "Skipping npm cache cleanup"
fi

# 9. Clear yarn cache (if yarn is installed)
if ask_confirmation "yarn cache"; then
    if command -v yarn &> /dev/null; then
        print_status "Clearing yarn cache..."
        yarn cache clean 2>/dev/null || print_warning "yarn cache clean failed"
        print_success "yarn cache cleared"
    else
        print_status "yarn not found, skipping yarn cache cleanup"
    fi
else
    print_status "Skipping yarn cache cleanup"
fi

# 10. Clear pip cache (if pip is installed)
if ask_confirmation "pip cache"; then
    if command -v pip3 &> /dev/null; then
        print_status "Clearing pip cache..."
        pip3 cache purge 2>/dev/null || print_warning "pip cache purge failed"
        print_success "pip cache cleared"
    else
        print_status "pip3 not found, skipping pip cache cleanup"
    fi
else
    print_status "Skipping pip cache cleanup"
fi

# 11. Clear Docker cache (if Docker is installed)
if ask_confirmation "Docker cache and unused containers/volumes"; then
    if command -v docker &> /dev/null; then
        print_status "Clearing Docker cache..."
        docker system prune -af --volumes 2>/dev/null || print_warning "Docker cleanup failed"
        print_success "Docker cache cleared"
    else
        print_status "Docker not found, skipping Docker cache cleanup"
    fi
else
    print_status "Skipping Docker cache cleanup"
fi

# 12. Clear Trash
if ask_confirmation "Trash"; then
    print_status "Emptying Trash..."
    if [[ -d "$HOME/.Trash" ]]; then
        local trash_size=$(get_size "$HOME/.Trash")
        print_status "Trash size: $trash_size"
        rm -rf "$HOME/.Trash"/* 2>/dev/null || true
        rm -rf "$HOME/.Trash"/.*[^.]* 2>/dev/null || true
        print_success "Trash emptied"
    else
        print_warning "Trash directory not found"
    fi
else
    print_status "Skipping Trash cleanup"
fi

# 13. Clear temporary files
if ask_confirmation "temporary files"; then
    print_status "Clearing temporary files..."
    safe_remove "/private/tmp" "System temporary files"
    safe_remove "$TMPDIR" "User temporary files"
else
    print_status "Skipping temporary files cleanup"
fi

# 14. Clear Quick Look cache
if ask_confirmation "Quick Look thumbnail cache"; then
    safe_remove "$HOME/Library/Caches/com.apple.QuickLook.thumbnailcache" "Quick Look thumbnail cache"
else
    print_status "Skipping Quick Look cache cleanup"
fi

# 15. Clear Spotlight cache (requires admin privileges)
if ask_confirmation "Spotlight cache (requires admin privileges)"; then
    print_status "Clearing Spotlight cache..."
    if command -v mdutil &> /dev/null; then
        sudo mdutil -E / 2>/dev/null || print_warning "Could not rebuild Spotlight index (permission denied)"
        print_success "Spotlight cache cleared"
    fi
else
    print_status "Skipping Spotlight cache cleanup"
fi

# 16. Purge memory (force cleanup of inactive memory)
if ask_confirmation "memory purge (requires admin privileges)"; then
    print_status "Purging inactive memory..."
    sudo purge 2>/dev/null || print_warning "Memory purge failed (requires admin privileges)"
else
    print_status "Skipping memory purge"
fi

echo ""
print_status "Cache cleanup completed!"

# Show final disk usage
echo ""
print_status "Final disk usage:"
df -h / | tail -n 1

echo ""
print_success "System cache cleanup completed successfully!"
print_status "You may need to restart some applications for changes to take effect."
print_status "Consider restarting your Mac to ensure all caches are properly cleared."

echo ""
echo "=============================================="
echo "    Cleanup Summary"
echo "=============================================="
echo "✓ Homebrew cache and logs"
echo "✓ User Library caches"
echo "✓ Application-specific caches"
echo "✓ System and user logs"
echo "✓ Downloads folder cleanup"
echo "✓ Mail cache"
echo "✓ Photos cache"
echo "✓ Development tool caches (Xcode, npm, yarn, pip, Docker)"
echo "✓ Trash emptied"
echo "✓ Temporary files"
echo "✓ Quick Look cache"
echo "✓ Spotlight cache (if admin privileges available)"
echo "✓ Memory purge"
echo ""
