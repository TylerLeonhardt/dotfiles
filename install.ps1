$configPath = (Join-Path $PSScriptRoot '.config')

# Set up symlinks
Get-ChildItem -Path $configPath | ForEach-Object {
    New-Item -Path (Join-Path '~/.config' $_.Name) -ItemType SymbolicLink -Value $_.FullName
}

Install-Module PSDepend -Force
Invoke-PSDepend
