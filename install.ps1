$configPath = (Join-Path $PSScriptRoot '.config')

# Set up symlinks
Get-ChildItem -Path $configPath | ForEach-Object {
    New-Item -Path (Join-Path '~/.config' $_.Name) -ItemType SymbolicLink -Value $_.FullName
}

pwsh -c 'Install-Module -Scope CurrentUser -Force -AllowPrerelease -AllowClobber PowerShellGet'
Install-PSResource -RequiredResourceFile (Join-Path $PSScriptRoot 'requirements.json')
