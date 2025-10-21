#!/bin/bash

# Set up variables
API_TIMEOUT=60

# Simple logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >&2
}

# Function to get all repositories for a GitLab group
get_gitlab_group_repos() {
    local groupname="$1"
    local gitlab_url="${2:-https://gitlab.com}"
    local temp_file=$(mktemp)
    local page=1
    local all_repos=""
    
    log_message "INFO" "Fetching repository list for GitLab group: $groupname at $gitlab_url"
    
    while true; do
        if curl -s --connect-timeout "$API_TIMEOUT" \
            "$gitlab_url/api/v4/groups/$groupname/projects?per_page=100&page=$page" > "$temp_file"; then
            
            # Check if we got an error response
            if grep -q '"message":' "$temp_file"; then
                local error_msg=$(grep -o '"message":"[^"]*"' "$temp_file" | cut -d'"' -f4)
                log_message "ERROR" "GitLab API error for group $groupname: $error_msg"
                rm -f "$temp_file"
                return 1
            fi
            
            local repos_on_page
            if command -v jq >/dev/null 2>&1; then
                repos_on_page=$(jq -r '.[].path' "$temp_file" 2>/dev/null || echo "")
            else
                repos_on_page=$(grep -o '"path":"[^"]*"' "$temp_file" | cut -d'"' -f4)
            fi
            
            # If no repos on this page, we're done
            if [[ -z "$repos_on_page" ]]; then
                break
            fi
            
            all_repos="$all_repos$repos_on_page"$'\n'
            ((page++))
        else
            log_message "ERROR" "Failed to fetch repositories for GitLab group: $groupname"
            rm -f "$temp_file"
            return 1
        fi
    done
    
    rm -f "$temp_file"
    echo "$all_repos" | grep -v '^$' | sort
}

# Test the GitLab group function
echo "Testing GitLab group detection for 'garuda-linux'..."
echo "=================================================="

repos=$(get_gitlab_group_repos "garuda-linux")
if [[ $? -eq 0 ]]; then
    echo "✅ Successfully fetched repositories for garuda-linux group!"
    echo "Number of repositories found: $(echo "$repos" | wc -l)"
    echo ""
    echo "First 10 repositories:"
    echo "$repos" | head -10
    echo ""
    if [[ $(echo "$repos" | wc -l) -gt 10 ]]; then
        echo "Last 5 repositories:"
        echo "$repos" | tail -5
        echo ""
    fi
else
    echo "❌ Failed to fetch repositories for garuda-linux"
    exit 1
fi

echo "Test completed successfully! The garuda-linux error should now be fixed."
echo "The script now supports both GitLab users and groups automatically."
