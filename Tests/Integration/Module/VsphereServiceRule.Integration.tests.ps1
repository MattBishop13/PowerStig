#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

$testCases = @(
    @{
        Key = 'TSM-SSH'
        Policy = 'off'
        Running = 'False'
        CheckContent = 'From the vSphere Web Client select the ESXi Host and go to Configure >> System >> Security Profile. Under Services select Edit and view the "SSH" service and verify it is stopped.

        or

        From a PowerCLI command prompt while connected to the ESXi host run the following command:

        Get-VMHost | Get-VMHostService | Where {$_.Label -eq "SSH"}

        If the ESXi SSH service is running, this is a finding.'
    }
)

try
{
    Describe 'VsphereService Rule Conversion' {

        Context 'When VsphereService is converted' {

            It 'Should return a correctly converted "<Key>" Rule' -TestCases $testCases {
                param ($Key, $Policy, $Running, $CheckContent)

                [xml] $stigRule = Get-TestStigRule -Checkcontent $CheckContent -XccdfTitle 'Vsphere'
                $testFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($testFile)
                $rule = ConvertFrom-StigXccdf -Path $testFile

                $rule.GetType().Name   | Should -be 'VsphereServiceRule'
                $rule.Key              | Should -be $Key
                $rule.Policy           | Should -be $Policy
                $rule.Running          | Should -be $Running
                $rule.DscResource      | Should -be 'VMHostService'
                $rule.ConversionStatus | Should -be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
