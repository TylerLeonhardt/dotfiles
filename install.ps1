$configPath = (Join-Path $PSScriptRoot '.config')

# Set up symlinks
if ($IsWindows) {
    $myDocuments = [System.Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
    Get-ChildItem -Path (Join-Path $configPath 'powershell') | ForEach-Object {
        $powerShellFile = Join-Path -Path $myDocuments,'PowerShell' -ChildPath $_.Name
        Remove-Item -Recurse -Force $powerShellFile -ErrorAction SilentlyContinue
        New-Item -Path $powerShellFile -ItemType SymbolicLink -Value $_.FullName -Force

        # Apply to Windows PowerShell as well just in case I don't have PowerShell
        $winPowerShellFile = Join-Path -Path $myDocuments,'WindowsPowerShell' -ChildPath $_.Name
        Remove-Item -Recurse -Force $winPowerShellFile -ErrorAction SilentlyContinue
        New-Item -Path $winPowerShellFile -ItemType SymbolicLink -Value $_.FullName -Force
    }
} else {
    Get-ChildItem -Path $configPath | ForEach-Object {
        New-Item -Path (Join-Path '~/.config' $_.Name) -ItemType SymbolicLink -Value $_.FullName -Force
    }
}

# Install oh-my-posh
switch($true) {
    $IsLinux {
        if (!(Get-Command curl -ErrorAction SilentlyContinue)) {
            throw "curl is not installed. Please install curl and try again."
        }
        curl -s https://ohmyposh.dev/install.sh | bash -s
    }
    $IsMacOS {
        if (!(Get-Command brew -ErrorAction SilentlyContinue)) {
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        }
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    }
    $IsWindows {
        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "winget is not installed. Please install winget and try again."
        }
        winget install JanDeDobbeleer.OhMyPosh -s winget
    }
    default {
        # Windows PowerShell
        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "winget is not installed. Please install winget and try again."
        }
        winget install JanDeDobbeleer.OhMyPosh -s winget
    }
}
