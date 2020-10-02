New-Item -Path ~/.config -ItemType SymbolicLink -Value (Join-Path $PSScriptRoot '.config')

Install-Module PSDepend
Invoke-PSDepend
