# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions

<#
    .SYNOPSIS
        Finds the Certificate Name  property from a RootCertificateRule.

    .PARAMETER CheckContent
        An array of the string data taken from the STIG setting.
#>
function Set-RootCertificateName
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter()]
        [string[]]
        $CheckContent
    )

    if ($checkContent.Count -gt 1)
    {
        if ($CheckContent -match "Issuer:\sCN")
        {
            $certificateName = ($CheckContent | Select-String -Pattern '(?<=Issuer:\sCN=)[^,]+' -AllMatches).Matches.Value | Select-Object -Unique
        }
        else
        {
            $certificateName = ($CheckContent | Select-String -Pattern '(?<=Subject:\sCN=)[^,]+' -AllMatches).Matches.Value | Select-Object -Unique
        }
      
    }
    elseif ($CheckContent -match 'Root\sCA')
    {
        $certificateName = ($CheckContent | Select-String -Pattern "^.*\s[^,]").Matches.Value
    }

    if ($null -ne $certificateName)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Root Certifcate: {0}" -f $certificateName)
        return $certificateName
    }
    else
    {
        return $null
    }
}

<#
    .SYNOPSIS
        Finds the Thumbprint property from a RootCertificateRule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Set-RootCertificateThumbprint
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter()]
        [string[]]
        $CheckContent
    )

    if ($checkContent.Count -gt 1)
    {
        $certificateThumbprint = ($CheckContent | Select-String -Pattern '(?<=Thumbprint:\s).*' -AllMatches).Matches.Value | Select-Object -Unique
    }
    elseif ($CheckContent -match 'Root\sCA')
    {
        $certificateThumbprint = ($CheckContent | Select-String -Pattern "(?<=,).*").Matches.Value
    }

    if ($null -ne $certificateThumbprint)
    {
        Write-Verbose -Message $("[$($MyInvocation.MyCommand.Name)] Found Root Certifcate: {0}" -f $certificateThumbprints)
        return $certificateThumbprint
    }
    else
    {
        return $null
    }
}

<#
    .SYNOPSIS
        Tests if multiple rules exist in a RootCertificateRule.

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Test-MultipleRootCertificateRule
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $certificateNames = ($CheckContent | Select-String -Pattern '(?<=Subject:\sCN=)[^,]+' -AllMatches).Matches.Value | Select-Object -Unique

    if ($certificateNames.count -gt 1)
    {
        return $true
    }
    return $false
}

<#
    .SYNOPSIS
        Consumes the checkcontent as a string array and outputs a list of names and thumbprints as an array

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Split-MultipleRootCertificateRule
{
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]
        $CheckContent
    )

    $multipleCertificatesRules = @()
    $certificateNames = ($CheckContent | Select-String -Pattern '(?<=Subject:\sCN=)[^,]+' -AllMatches).Matches.Value
    $certificateThumbprints = ($CheckContent | Select-String -Pattern '(?<=Thumbprint:\s).*' -AllMatches).Matches.Value | Select-Object -Unique
    $issuerNames = ($CheckContent | Select-String -Pattern '(?<=Issuer:\sCN=)[^,]+' -AllMatches).Matches.Value
    $index = 0

    foreach ($certificate in $certificateNames)
    {
        if ($issuerNames.Count -eq $certificateNames.Count)
        {
            $multipleCertificateRule = @()
            $multipleCertificateRule += ($issuerNames[$index] + "," + $certificateThumbprints[$index])
            $multipleCertificatesRules += $multipleCertificateRule
            $index += 1
        }
        else
        {
            $multipleCertificateRule = @()
            $multipleCertificateRule += ($certificateNames[$index] + "," + $certificateThumbprints[$index])
            $multipleCertificatesRules += $multipleCertificateRule
            $index += 1
        }
    }

    return $multipleCertificatesRules
}

<#
    .SYNOPSIS
        This function takes a certificate name and outputs a organizational setting string

    .PARAMETER CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-RootCertificateOrganizationValueTestString
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CertificateName
    )

    $organizationValueTestString = "{0}{1}{2}" -f "location for ", $CertificateName, " certificate is present"
    return $organizationValueTestString
}
