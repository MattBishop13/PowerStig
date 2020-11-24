#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $testStrings = @(
        @{
            OptionName = 'Network security: Force logoff when logon hours expire'
            OptionValue = 'Enabled'
            OrganizationValueRequired = $false
            CheckContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".

            Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

            If the value for "Network security: Force logoff when logon hours expire" is not set to "Enabled", this is a finding.'
        },
        @{
            OptionName = 'Accounts: Rename administrator account'
            OptionValue = $null
            OrganizationValueRequired = $true
            OrganizationValueTestString = "'{0}' -ne 'Administrator'"
            CheckContent = 'Verify the effective setting in Local Group Policy Editor.
            Run "gpedit.msc".

            Navigate to Local Computer Policy -&gt; Computer Configuration -&gt; Windows Settings -&gt; Security Settings -&gt; Local Policies -&gt; Security Options.

            If the value for "Accounts: Rename administrator account" is not set to a value other than "Administrator", this is a finding.'
        }
    )

    Describe 'Security Option Conversion' {

        foreach ( $testString in $testStrings )
        {
            [xml] $stigRule = Get-TestStigRule -CheckContent $testString.CheckContent -XccdfTitle Windows
            $TestFile = Join-Path -Path $env:TEMP -ChildPath 'TextData.xml'
            $stigRule.Save( $TestFile )
            $rule = ConvertFrom-StigXccdf -Path $TestFile

            It 'Should return an SecurityOptionRule Object' {
                $rule.GetType() | Should -be 'SecurityOptionRule'
            }
            It "Should set Option Name to '$($testString.OptionName)'" {
                $rule.OptionName | Should -be $testString.OptionName
            }
            It "Should set Option Value to '$($testString.OptionValue)'" {
                $rule.OptionValue | Should -be $testString.OptionValue
            }
            It "Should set OrganizationValueRequired to $($testString.OrganizationValueRequired)" {
                $rule.OrganizationValueRequired | Should -be $testString.OrganizationValueRequired
            }
            It "Should set OrganizationValueTestString to $($testString.OrganizationValueTestString)" {
                $rule.OrganizationValueTestString | Should -be $testString.OrganizationValueTestString
            }
            It 'Should set the correct DscResource' {
                $rule.DscResource | Should -be 'SecurityOption'
            }
            It 'Should Set the status to pass' {
                $rule.conversionstatus | Should -be 'pass'
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
