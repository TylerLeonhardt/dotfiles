#requires -Version 2 -Modules posh-git

# PUT IN ~/.config/powershell/oh-my-posh/Themes

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    #check the last command state and indicate if failed
    If ($lastCommandFailed) {
        $prompt = Write-Prompt -Object "$($sl.PromptSymbols.FailedCommandSymbol) " -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor
    }

    if ($PSVersionTable.GitCommitId.Length -gt 20) {
        $prompt += Write-Prompt -Object '[DEV] ' -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    }

    $user = [System.Environment]::UserName
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object "`e[1m$user`e[0m " -ForegroundColor $sl.Colors.PromptForegroundColor
    }

    # Writes the path
    $prompt += Write-Prompt -Object "$(Get-FullPath -dir $pwd) " -ForegroundColor $sl.Colors.DriveForegroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $prompt += Write-Prompt -Object "git:" -ForegroundColor $sl.Colors.PromptForegroundColor
        $prompt += Write-Prompt -Object "$($themeInfo.VcInfo) " -ForegroundColor $themeInfo.BackgroundColor
    }

    # write virtualenv
    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object 'env:' -ForegroundColor $sl.Colors.PromptForegroundColor
        $prompt += Write-Prompt -Object "$(Get-VirtualEnvName) " -ForegroundColor $themeInfo.VirtualEnvForegroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object "$($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
    }

    $prompt += Set-Newline

    # Writes the postfixes to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.AdminIconForegroundColor
    $prompt += Write-Prompt -Object $sl.PromptSymbols.PromptIndicator -ForegroundColor $sl.Colors.GitNoLocalChangesAndAheadColor
    $prompt += ' '
    $prompt
    
    if($global:PostPromptHook) {
        . $global:PostPromptHook
    }
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x276F)
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.WithForegroundColor = [ConsoleColor]::DarkRed
$sl.Colors.WithBackgroundColor = [ConsoleColor]::Magenta
