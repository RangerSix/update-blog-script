# update.ps1
# This script automates updating the blog on GitHub with advanced error handling.

# Stop the script if any command fails
$ErrorActionPreference = "Stop"

Write-Host "Starting the blog update process..."

# 1. Verify that Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in your PATH. Aborting."
    exit 1
}

# 2. Initialize Git repository
try {
    Write-Host "Initializing Git repository..."
    git init
} catch {
    Write-Error "Failed to initialize Git repository: $_"
    exit 1
}

# 3. Stage all changes
try {
    Write-Host "Staging all changes..."
    git add .
} catch {
    Write-Error "Failed to stage changes: $_"
    exit 1
}

# 4. Check for changes before committing
try {
    $gitStatus = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($gitStatus)) {
        Write-Host "No changes to commit. Skipping commit step."
    } else {
        Write-Host "Committing changes..."
        git commit -m "update"
    }
} catch {
    Write-Error "Failed during commit process: $_"
    exit 1
}

# 5. Verify if remote 'origin' exists before adding it
try {
    $remotes = git remote
    if ($remotes -notmatch "origin") {
        Write-Host "Remote 'origin' does not exist. Adding remote..."
        git remote add origin https://github.com/yourgitusername/yourgitrepository.git
    } else {
        Write-Host "Remote 'origin' already exists. Skipping addition."
    }
} catch {
    Write-Error "Failed checking or adding remote: $_"
    exit 1
}

# 6. Set branch to master
try {
    Write-Host "Setting the branch to master..."
    git branch -M master
} catch {
    Write-Error "Failed to set branch 'master': $_"
    exit 1
}

# 7. Push changes to GitHub
try {
    Write-Host "Pushing changes to the 'master' branch on GitHub..."
    git push -u origin master
} catch {
    Write-Error "Failed to push to GitHub: $_"
    exit 1
}

# 8. Create a subtree split of the 'public' folder for Hostinger deployment
try {
    Write-Host "Creating subtree split of 'public' into branch 'hostinger-deploy'..."
    git subtree split --prefix public -b hostinger-deploy
} catch {
    Write-Error "Failed to create subtree split: $_"
    exit 1
}

# 9. Force push the subtree to the 'hostinger' branch on GitHub
try {
    Write-Host "Deploying to the 'hostinger' branch with a force push..."
    git push origin hostinger-deploy:hostinger --force
} catch {
    Write-Error "Failed to push subtree to 'hostinger' branch: $_"
    exit 1
}

# 10. Clean up the temporary branch
try {
    Write-Host "Deleting temporary branch 'hostinger-deploy'..."
    git branch -D hostinger-deploy
} catch {
    Write-Error "Failed to delete temporary branch 'hostinger-deploy': $_"
    exit 1
}

Write-Host "Blog update process completed successfully!"