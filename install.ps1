$configPath = (Join-Path $PSScriptRoot '.config')

# Set up symlinks
if ($IsWindows) {
    Get-ChildItem -Path (Join-Path $configPath 'powershell') | ForEach-Object {
        New-Item -Path (Join-Path '~/Documents/PowerShell' $_.Name) -ItemType SymbolicLink -Value $_.FullName -Force
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
}
