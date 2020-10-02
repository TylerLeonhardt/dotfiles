@{
    PSDependOptions = @{
        Target = 'CurrentUser'
        Parameters = @{
            Repository = 'PSGallery'
            AllowPrerelease = $True
        }
    }

    'posh-git' = 'latest'
    'oh-my-posh' = 'latest'
    'Microsoft.PowerShell.SecretManagement' = 'latest'
    'Microsoft.PowerShell.UnixCompleters'   = 'latest'
    'Microsoft.PowerShell.ConsoleGuiTools'  = 'latest'
}
