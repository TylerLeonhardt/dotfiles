#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

function ConvertTo-ScriptExtent {
    <#
    .EXTERNALHELP ..\PowerShellEditorServices.Commands-help.xml
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Language.IScriptExtent])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ByOffset')]
        [Alias('StartOffset', 'Offset')]
        [int]
        $StartOffsetNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByOffset')]
        [Alias('EndOffset')]
        [int]
        $EndOffsetNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByPosition')]
        [Alias('StartLine', 'Line')]
        [int]
        $StartLineNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByPosition')]
        [Alias('StartColumn', 'Column')]
        [int]
        $StartColumnNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByPosition')]
        [Alias('EndLine')]
        [int]
        $EndLineNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByPosition')]
        [Alias('EndColumn')]
        [int]
        $EndColumnNumber,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByPosition')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByOffset')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByBuffer')]
        [Alias('File', 'FileName')]
        [string]
        $FilePath = $psEditor.GetEditorContext().CurrentFile.Path,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByBuffer')]
        [Alias('Start')]
        [Microsoft.PowerShell.EditorServices.Extensions.IFilePosition, Microsoft.PowerShell.EditorServices]
        $StartBuffer,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='ByBuffer')]
        [Alias('End')]
        [Microsoft.PowerShell.EditorServices.Extensions.IFilePosition, Microsoft.PowerShell.EditorServices]
        $EndBuffer,

        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='ByExtent')]
        [System.Management.Automation.Language.IScriptExtent]
        $Extent
    )
    begin {
        $fileContext = $psEditor.GetEditorContext().CurrentFile
        $emptyExtent = [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::Empty
    }

    process {
        # Already a InternalScriptExtent, FileScriptExtent or is empty.
        $returnAsIs = $Extent -and
                     (0 -ne $Extent.StartOffset   -or
                      0 -ne $Extent.EndOffset     -or
                      $Extent -eq $emptyExtent)

        if ($returnAsIs) { return $Extent }

        if ($StartOffsetNumber) {
            $startOffset = $StartOffsetNumber
            $endOffset   = $EndOffsetNumber

            # Allow creating a single position extent with just the offset parameter.
            if (-not $EndOffsetNumber) {
                $endOffset = $startOffset
            }

            return [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::FromOffsets(
                $fileContext,
                $startOffset,
                $endOffset)
        }

        if ($StartBuffer) {
            if (-not $EndBuffer)
            {
                $EndBuffer = $StartBuffer
            }

            return [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::FromPositions(
                $fileContext,
                $StartBuffer.Line,
                $StartBuffer.Column,
                $EndBuffer.Line,
                $EndBuffer.Column)
        }

        if (-not $StartColumnNumber) { $StartColumnNumber = 1 }
        if (-not $StartLineNumber)   { $StartLineNumber   = 1 }
        if (-not $EndLineNumber)     { $EndLineNumber     = 1 }
        if (-not $EndColumnNumber)   { $EndColumnNumber   = 1 }

        return [Microsoft.PowerShell.EditorServices.Extensions.FileScriptExtent, Microsoft.PowerShell.EditorServices]::FromPositions(
            $StartLineNumber,
            $StartColumnNumber,
            $EndLineNumber,
            $EndColumnNumber)
    }
}

# SIG # Begin signature block
# MIIjkgYJKoZIhvcNAQcCoIIjgzCCI38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBVjWyLzFTPJixL
# KzXqB5auzmX0hivAyAMtLvdHBJUAtKCCDYUwggYDMIID66ADAgECAhMzAAABiK9S
# 1rmSbej5AAAAAAGIMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwMzA0MTgzOTQ4WhcNMjEwMzAzMTgzOTQ4WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCSCNryE+Cewy2m4t/a74wZ7C9YTwv1PyC4BvM/kSWPNs8n0RTe+FvYfU+E9uf0
# t7nYlAzHjK+plif2BhD+NgdhIUQ8sVwWO39tjvQRHjP2//vSvIfmmkRoML1Ihnjs
# 9kQiZQzYRDYYRp9xSQYmRwQjk5hl8/U7RgOiQDitVHaU7BT1MI92lfZRuIIDDYBd
# vXtbclYJMVOwqZtv0O9zQCret6R+fRSGaDNfEEpcILL+D7RV3M4uaJE4Ta6KAOdv
# V+MVaJp1YXFTZPKtpjHO6d9pHQPZiG7NdC6QbnRGmsa48uNQrb6AfmLKDI1Lp31W
# MogTaX5tZf+CZT9PSuvjOCLNAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUj9RJL9zNrPcL10RZdMQIXZN7MG8w
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzQ1ODM4NjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# ACnXo8hjp7FeT+H6iQlV3CcGnkSbFvIpKYafgzYCFo3UHY1VHYJVb5jHEO8oG26Q
# qBELmak6MTI+ra3WKMTGhE1sEIlowTcp4IAs8a5wpCh6Vf4Z/bAtIppP3p3gXk2X
# 8UXTc+WxjQYsDkFiSzo/OBa5hkdW1g4EpO43l9mjToBdqEPtIXsZ7Hi1/6y4gK0P
# mMiwG8LMpSn0n/oSHGjrUNBgHJPxgs63Slf58QGBznuXiRaXmfTUDdrvhRocdxIM
# i8nXQwWACMiQzJSRzBP5S2wUq7nMAqjaTbeXhJqD2SFVHdUYlKruvtPSwbnqSRWT
# GI8s4FEXt+TL3w5JnwVZmZkUFoioQDMMjFyaKurdJ6pnzbr1h6QW0R97fWc8xEIz
# LIOiU2rjwWAtlQqFO8KNiykjYGyEf5LyAJKAO+rJd9fsYR+VBauIEQoYmjnUbTXM
# SY2Lf5KMluWlDOGVh8q6XjmBccpaT+8tCfxpaVYPi1ncnwTwaPQvVq8RjWDRB7Pa
# 8ruHgj2HJFi69+hcq7mWx5nTUtzzFa7RSZfE5a1a5AuBmGNRr7f8cNfa01+tiWjV
# Kk1a+gJUBSP0sIxecFbVSXTZ7bqeal45XSDIisZBkWb+83TbXdTGMDSUFKTAdtC+
# r35GfsN8QVy59Hb5ZYzAXczhgRmk7NyE6jD0Ym5TKiW5MIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCFWMwghVfAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAGIr1LWuZJt6PkAAAAA
# AYgwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIIcT
# dLvXeOSauRtcwVK37JJvktUsNDo3OiSF44gpGwuwMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAHb//+/8r/jVIFooUvissNyEosp9vdQJyuI+z
# bCzQjFm01Bmnfj3Sccz5AHKf5ofQ07x7YOqP15zU++JU9KluUZFN5W9qqoDJnlVs
# fDCtel4DfM+Va91NsUOftZUAsFqxscg/sE3PsiFL5yR7L66LNmGe5XtNps67XHT9
# V3okJp/BeLiM+PanzP5thcRrPoUS4odIjj9iS49S3Cud9C+3Yl+5luUAM8cXqV4m
# nEYfSb/RwW1oDZNu27V4FZy/TP4utoRlgbIlbDZhl0VHrJ0JWcDEXdVdt0J54DWu
# W0uO708kEqjFw9XsiqcFm2u5cgYPn5G6h4O8rd3bfrTQwK8AUaGCEu0wghLpBgor
# BgEEAYI3AwMBMYIS2TCCEtUGCSqGSIb3DQEHAqCCEsYwghLCAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFUBgsqhkiG9w0BCRABBKCCAUMEggE/MIIBOwIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCBkZ0zWRUUpCmR9wZCuPuT6H7BPgeqm6IFK
# HiPyJ7QcdAIGXtUEUegpGBIyMDIwMDYxMTE5MjMwOS4wNlowBIACAfSggdSkgdEw
# gc4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsT
# IE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFs
# ZXMgVFNTIEVTTjpGN0E2LUUyNTEtMTUwQTElMCMGA1UEAxMcTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgU2VydmljZaCCDkEwggT1MIID3aADAgECAhMzAAABJYvei2xyJjHd
# AAAAAAElMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwMB4XDTE5MTIxOTAxMTQ1OFoXDTIxMDMxNzAxMTQ1OFowgc4xCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBP
# cGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpG
# N0E2LUUyNTEtMTUwQTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANB7H2N2YFvs4cnB
# JiYxSitk3ABy/xXLfpOUm7NxXHsb6UWq3bONY4yVI4ySbVegC4nxVnlKEF50ANcM
# YMrEc1mEu7cRbzHmi38g6TqLMtOUAW28hc6DNez8do4zvZccrKQxkcB0v9+lm0BI
# zk9qWaxdfg6XyVeSb2NHnkrnoLur36ENT7a2MYdoTVlaVpuU1RcGFpmC0IkJ3rRT
# Jm+Ajv+43Nxp+PT9XDZtqK32cMBV3bjK39cJmcdjfJftmweMi4emyX4+kNdqLUPB
# 72nSvIJmyX1I4wd7G0gd72qVNu1Zgnxa1Yugf10QxDFUueY88M5WYGPstmFKOLfw
# 31WnP8UCAwEAAaOCARswggEXMB0GA1UdDgQWBBTzqsrlByb5ATk0FcYI8iIIF0Mk
# +DAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEug
# SaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9N
# aWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsG
# AQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Rp
# bVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQCTHFk8YSAiACGypk1NmTnxXW9C
# InmNrbEeXlOoYDofCPlKKguDcVIuJOYZX4G0WWlhS2Sd4HiOtmy42ky19tMx0bun
# /EDIhW3C9edNeoqUIPVP0tyv3ilV53McYnMvVNg1DJkkGi4J/OSCTNxw64U595Y9
# +cxOIjlQFbk52ajIc9BYNIYehuhbV1Mqpd4m25UNNhsdMqzjON8IEwWObKVG7nZm
# mLP70wF5GPiIB6i7QX/fG8jN6mggqBRYJn2aZWJYSRXAK1MZtXx4rvcp4QTS18xT
# 9hjZSagY9zxjBu6sMR96V6Atb5geR+twYAaV+0Kaq0504t6CEugbRRvH8HuxMIIG
# cTCCBFmgAwIBAgIKYQmBKgAAAAAAAjANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMTAwNzAxMjEzNjU1
# WhcNMjUwNzAxMjE0NjU1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkdDbx3EYo6IOz8E5f1+n9p
# lGt0VBDVpQoAgoX77XxoSyxfxcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEw
# WbEwRA/xYIiEVEMM1024OAizQt2TrNZzMFcmgqNFDdDq9UeBzb8kYDJYYEbyWEeG
# MoQedGFnkV+BVLHPk0ySwcSmXdFhE24oxhr5hoC732H8RsEnHSRnEnIaIYqvS2SJ
# UGKxXf13Hz3wV3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo8noqCjHw
# 2k4GkbaICDXoeByw6ZnNPOcvRLqn9NxkvaQBwSAJk3jN/LzAyURdXhacAQVPIk0C
# AwEAAaOCAeYwggHiMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpcijGQ
# 80N7fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8E
# BAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2U
# kFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5j
# b20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmww
# WgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYD
# VR0gAQH/BIGVMIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYI
# KwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0
# AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAAfmiFEN4sbgmD+BcQM9
# naOhIW+z66bM9TG+zwXiqf76V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RXCCtR
# gkQS+7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1mCRWS3TvQhDIr79/xn/yN31aPxzy
# mXlKkVIArzgPF/UveYFl2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCf
# Mkon/VWvL/625Y4zu2JfmttXQOnxzplmkIz/amJ/3cVKC5Em4jnsGUpxY517IW3D
# nKOiPPp/fZZqkHimbdLhnPkd/DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs
# 9/S/fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF0M2n0O99g/DhO3EJ3110
# mCIIYdqwUB5vvfHhAN/nMQekkzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL
# 2IK0cs0d9LiFAR6A+xuJKlQ5slvayA1VmXqHczsI5pgt6o3gMy4SKfXAL1QnIffI
# rE7aKLixqduWsqdCosnPGUFN4Ib5KpqjEWYw07t0MkvfY3v1mYovG8chr1m1rtxE
# PJdQcdeh0sVV42neV8HR3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQNdrvCScc
# 1bN+NR4Iuto229Nfj950iEkSoYICzzCCAjgCAQEwgfyhgdSkgdEwgc4xCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29m
# dCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVT
# TjpGN0E2LUUyNTEtMTUwQTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaIjCgEBMAcGBSsOAwIaAxUARdMv4VBtzYb7cxde8hEpWvahcKeggYMw
# gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUF
# AAIFAOKMsM0wIhgPMjAyMDA2MTExNzMxNTdaGA8yMDIwMDYxMjE3MzE1N1owdDA6
# BgorBgEEAYRZCgQBMSwwKjAKAgUA4oywzQIBADAHAgEAAgIKvDAHAgEAAgISgzAK
# AgUA4o4CTQIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIB
# AAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAKdraeWxNc1GfdDS
# 3PJd6G/9hYeyOtOj4Eb1/9lfVrkjqFcpbC6ISlBSp7N5CtFm9Owt5n9OFE44Qg9A
# eWFrf/IqbOWpQpfSJGz5i43h/igdWZqBoGC7h2hHdkElGWw7qpkkxccwn7yPuJyg
# rdMd/0ntl+4cvkPBwcfwPGSWPdJDMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAEli96LbHImMd0AAAAAASUwDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgpihCMCcLYJo291b+yO1i6nY0G3rDpaAQPh90syt/hFMwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCBd38ayLm8wX/qJfYIOH5V+YvlG+poWQXCW6LKN
# 70H3DjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# JYvei2xyJjHdAAAAAAElMCIEIIrbyuadxRR3eBaXEJn61A8N25zRa1SpL0ZAyMXx
# x6F5MA0GCSqGSIb3DQEBCwUABIIBAIbAOtpbVXnSHVSDIhlEW82/Z9XEVCDGqEt3
# pWbh83h5nGFp165x+ZDkm1kQ45vme0OKP7A7pPuMz4fFb6xiv0SfsIzfBk0SXzy4
# 20EIgunJ+CzB33Kenmr5Qxq4KEahjavsVaCLIPpABZp+3kA+74HHgExwbyWx1Dvh
# biS6vDMKkusRZ/HmXH4HuGeEWb2NWJjubkGuUYohwuSBjJZ6+Iy0o3IDQZsgmxj+
# 7qCs7dmcZbngynfB5Lath9iV54vB5j4JOpSeyQEn2gqjvSOUSFvaSLMWG/A2W9wW
# P+A9g0J8Gmt4DX44OD2dN/pyJtJ09dzkqVE7V1w/F+AoRJ9Wi+s=
# SIG # End signature block
