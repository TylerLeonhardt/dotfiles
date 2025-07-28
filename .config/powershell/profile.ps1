$IsUnix = $IsLinux -or $IsMacOS

#region UX config

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $themePath = '~/.config/powershell/PoshThemes/TylerLeonhardt.json'
    if (Test-Path $themePath) {
        oh-my-posh init pwsh --config $themePath | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# We still need posh-git for git completers
Import-Module posh-git -ErrorAction SilentlyContinue

if (Get-Module PSReadLine -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Chord Alt+Enter -Function AddLine
    Set-PSReadLineOption -ContinuationPrompt "  "
    if ($IsCoreCLR) {
        Set-PSReadLineOption -PredictionSource History -Colors @{
            Operator = "`e[95m"
            Parameter = "`e[95m"
            InlinePrediction = "`e[36;7;238m"
        }
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

#endregion

#region Update PowerShell Daily

if ($IsCoreCLR) {
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
}

#endregion

#region Hooks

# Set CurrentDirectory when LocationChangedAction is invoked.
# This allows iTerm2's "Reuse previous session's directory" to work
if ($IsUnix) {
    $ExecutionContext.SessionState.InvokeCommand.LocationChangedAction += {
        [Environment]::CurrentDirectory = $pwd.Path
    }
}

#endregion

#region gpg
if ($IsUnix -and (Get-Command -ErrorAction SilentlyContinue gpgconf)) {
    $env:GPG_TTY = tty
    gpgconf --launch gpg-agent
}
#endregion
