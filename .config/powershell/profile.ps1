#region UX config

$hasOhMyPosh = Import-Module oh-my-posh -MinimumVersion 3.0 -PassThru -ErrorAction SilentlyContinue
if ($hasOhMyPosh) {
    $themePath = '~/.config/powershell/PoshThemes/TylerLeonhardt.json'
    if (Test-Path $themePath) {
        Set-PoshPrompt -Theme $themePath
    } else {
        Set-PoshPrompt -Theme material
    }
}

# We still need posh-git for git completers
Import-Module posh-git -ErrorAction SilentlyContinue

if (Get-Module PSReadLine) {
    Set-PSReadLineKeyHandler -Chord Alt+Enter -Function AddLine
    Set-PSReadLineOption -ContinuationPrompt "  " -PredictionSource History -Colors @{
        Operator = "`e[95m"
        Parameter = "`e[95m"
        InlinePrediction = "`e[36;7;238m"
    }

    # Searching for commands with up/down arrow is really handy.  The
    # option "moves to end" is useful if you want the cursor at the end
    # of the line while cycling through history like it does w/o searching,
    # without that option, the cursor will remain at the position it was
    # when you used up arrow, which can be useful if you forget the exact
    # string you started the search on.
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

#endregion

#region Helper functions

# Allows idweb to be open from mac
function idweb {
    kdestroy --all
    kinit --keychain tyleonha@REDMOND.CORP.MICROSOFT.COM
    open https://idweb -a Safari.app
}

#endregion

#region Argument completers

# dotnet CLI

if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# `dotnet suggest`-based CLIs

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
if (-not $IsWindows) {
    Import-Module Microsoft.PowerShell.UnixCompleters -ErrorAction SilentlyContinue
}

#endregion

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

#region Hooks

# Set CurrentDirectory when LocationChangedAction is invoked.
# This allows iTerm2's "Reuse previous session's directory" to work
$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction += {
    [Environment]::CurrentDirectory = $pwd.Path
}

#endregion
