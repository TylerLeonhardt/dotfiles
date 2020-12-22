@{
    PSDependOptions = @{
        Target = 'CurrentUser'
        Parameters = @{
            Repository = 'PSGallery'
            AllowPrerelease = $True
        }
    }

    'oh-my-posh' = 'latest'
    'Microsoft.PowerShell.SecretManagement' = 'latest'
    'Microsoft.PowerShell.UnixCompleters'   = 'latest'
    'Microsoft.PowerShell.ConsoleGuiTools'  = 'latest'
}
