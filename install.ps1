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

Install-Module PSDepend -Force
Invoke-PSDepend -Force (Join-Path $PSScriptRoot 'requirements.psd1')
