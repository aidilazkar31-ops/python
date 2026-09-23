Param(
    [string]$RemoteUrl = 'https://github.com/aidilazkar31-ops/python.git',
    [string]$CommitMessage = 'Initial commit from workspace'
)

function Check-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is not installed. Install Git for Windows and rerun: https://git-scm.com/download/win"
        exit 1
    }
}

Check-Git

Write-Output "Working directory: $(Get-Location)"

if (-not (Test-Path -Path (Join-Path (Get-Location) '.git'))) {
    Write-Output "Initializing new git repository..."
    git init
    git branch -M main
} else {
    Write-Output "Repository already initialized."
}

Write-Output "Staging changes..."
git add -A

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Output "No changes to commit."
} else {
    Write-Output "Committing changes..."
    git commit -m "$CommitMessage"
}

Write-Output "Configuring remote origin to $RemoteUrl"
$remoteExists = (git remote | Select-String -SimpleMatch 'origin' -Quiet)
if (-not $remoteExists) {
    git remote add origin $RemoteUrl
} else {
    git remote set-url origin $RemoteUrl
}

Write-Output "Pushing to remote..."
try {
    git push -u origin main
    Write-Output "Push completed."
} catch {
    Write-Error "Push failed. Check authentication (use PAT for HTTPS or set up SSH keys)."
    exit 1
}
