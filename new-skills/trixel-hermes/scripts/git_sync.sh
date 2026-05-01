#!/bin/bash
PROJECT_ROOTS=("/storage/emulated/0/PERSONALS 1/trixel-technologies" "/storage/emulated/0/TRIXEL")

for root in "${PROJECT_ROOTS[@]}"; do
    if [ -d "$root" ]; then
        echo "Checking projects in $root..."
        find "$root" -maxdepth 2 -name ".git" -type d | while read -r gitdir; do
            repo_dir=$(dirname "$gitdir")
            echo "Syncing $(basename "$repo_dir")..."
            cd "$repo_dir" || continue
            git pull origin main
            git add .
            git commit -m "Hermes Sync: $(date +'%Y-%m-%d %H:%M:%S')"
            git push origin main
        done
    fi
done
