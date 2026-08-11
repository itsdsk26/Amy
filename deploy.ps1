<#
deploy.ps1 - Initialize, commit, and push a static site to GitHub, optionally creating the repo via GitHub CLI.

Usage examples:
    # Push to an existing remote
    .\deploy.ps1 -RemoteUrl "https://github.com/OWNER/REPO.git" -CommitMessage "Deploy site"

    # Create repo with gh CLI and push
    .\deploy.ps1 -Owner OWNER -Repo REPO -CreateWithGH
#>

Param(
    [string]$Owner,
    [string]$Repo,
    [string]$RemoteUrl,
    [string]$CommitMessage = "Deploy site",
    [switch]$CreateWithGH
)

Set-StrictMode -Version Latest

try {
    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
    Set-Location $scriptPath

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "git is not installed or not on PATH. Install Git and retry."
        exit 1
    }

    # Initialize repo if needed
    & git rev-parse --is-inside-work-tree > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Initializing git repository..."
        git init
    }

    # Stage files
    git add .

    # Commit if there are changes
    $status = git status --porcelain
    if ($status) {
        git commit -m $CommitMessage
    } else {
        Write-Host "No changes to commit."
    }

    # Ensure branch is 'main'
    git branch --show-current > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $current = git rev-parse --abbrev-ref HEAD
        if ($current -ne 'main') { git branch -M main }
    } else {
        git branch -M main
    }

    if ($CreateWithGH) {
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            Write-Error "GitHub CLI 'gh' not found. Install it or use -RemoteUrl instead."
            exit 1
        }
        if (-not $Owner -or -not $Repo) {
            Write-Error "When using -CreateWithGH, provide -Owner and -Repo.
Example: .\deploy.ps1 -Owner myUser -Repo myRepo -CreateWithGH"
            exit 1
        }
        Write-Host "Creating GitHub repo $Owner/$Repo and pushing..."
        gh repo create "$Owner/$Repo" --public --source=. --push --confirm
    }
    else {
        if ($RemoteUrl) {
            # Add or update remote origin
            & git remote get-url origin > $null 2>&1
            if ($LASTEXITCODE -eq 0) {
                git remote set-url origin $RemoteUrl
            } else {
                git remote add origin $RemoteUrl
            }
            Write-Host "Pushing to origin/main..."
            git push -u origin main
        } else {
            Write-Host "No remote configured. Provide -RemoteUrl or use -CreateWithGH to create one."
        }
    }

    Write-Host "Done."
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}
