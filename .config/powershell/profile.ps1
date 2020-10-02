#region Update PowerShell Daily

$updateJob = Start-ThreadJob -ScriptBlock {
    Invoke-Expression "& {$(Invoke-RestMethod aka.ms/install-powershell.ps1)} -Daily"
}

$eventJob = Register-ObjectEvent -InputObject $updateJob -EventName StateChanged -Action {
    if($Event.Sender.State -eq [System.Management.Automation.JobState]::Completed) {
    	Get-EventSubscriber $eventJob.Name | Unregister-Event
	    Remove-Job $eventJob -ErrorAction SilentlyContinue
    	Receive-Job $updateJob -Wait -AutoRemoveJob -ErrorAction SilentlyContinue
    }
}

#endregion

#region Theme config

if (Get-Module PSReadLine) {
    Import-Module posh-git
    Import-Module oh-my-posh
    $ThemeSettings.MyThemesLocation = "~/.config/powershell/oh-my-posh/Themes"
    Set-Theme Sorin-NL

    Set-PSReadLineKeyHandler -Chord Alt+Enter -Function AddLine
    Set-PSReadLineOption -ContinuationPrompt "  " -Colors @{ Operator = "`e[95m"; Parameter = "`e[95m" }
}

#endregion

#region Helper functions

# allows idweb to be open from mac
function idweb {
    kdestroy --all; kinit --keychain tyleonha@REDMOND.CORP.MICROSOFT.COM; open https://idweb -a Safari.app
}

#endregion

#region Argument completers

# dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# dotnet suggest-based CLIs
if (Get-Command dotnet-suggest -ErrorAction SilentlyContinue) {
    $availableToComplete = (dotnet-suggest list) | Out-String
    $availableToCompleteArray = $availableToComplete.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)

    Register-ArgumentCompleter -Native -CommandName $availableToCompleteArray -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $fullpath = (Get-Command $wordToComplete.CommandElements[0]).Source

        $arguments = $wordToComplete.Extent.ToString().Replace('"', '\"')
        dotnet-suggest get -e $fullpath --position $cursorPosition -- "$arguments" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
    $env:DOTNET_SUGGEST_SCRIPT_VERSION = "1.0.0"
}

# UnixCompleters
Import-Module Microsoft.PowerShell.UnixCompleters -ErrorAction SilentlyContinue

#endregion

#region Hooks

# Set CurrentDirectory when LocationChangedAction is invoked.
# This allows iTerm2's "Reuse previous session's directory" to work
$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction += {
    [Environment]::CurrentDirectory = $pwd.ProviderPath
}

#endregion

#region Global variables

# For PSZoom
$global:ZoomApiKey = Get-Secret -Name ZoomApiKey -AsPlainText -ErrorAction SilentlyContinue
$global:ZoomApiSecret = Get-Secret -Name ZoomApiSecret -AsPlainText -ErrorAction SilentlyContinue

#endregion

#region Start up

if (Test-Path "/Applications/Remove Sophos Endpoint.app") {
    # Since it's a .app, the best we can do is pop the GUI
    open "/Applications/Remove Sophos Endpoint.app"
}

#endregion
