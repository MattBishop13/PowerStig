#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $stigRulesToTest = @(
        @{
            ConfigSection = '/system.webServer/security/requestFiltering'
            Key           = 'allowHighBitCharacters'
            Value         = 'false'
            CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

            Open the IIS 8.5 Manager.

            Click on the site name.

            Double-click the "Request Filtering" icon.

            Click Edit Feature Settings in the "Actions" pane.

            If the "Allow high-bit characters" check box is checked, this is a finding.'
        }
        @{
            ConfigSection = '/system.webServer/security/requestFiltering'
            Key           = 'allowDoubleEscaping'
            Value         = 'false'
            CheckContent  = 'Follow the procedures below for each site hosted on the IIS 8.5 web server:

            Open the IIS 8.5 Manager.

            Click on the site name.

            Double-click the "Request Filtering" icon.

            Click Edit Feature Settings in the "Actions" pane.

            If the "Allow double escaping" check box is checked, this is a finding.'
        }
        @{
            ConfigSection = '/system.web/machineKey'
            Key           = 'validation'
            Value         = 'HMACSHA256'
            CheckContent  = 'Open the IIS 8.5 Manager.

            Click the IIS 8.5 web server name.

            Double-click the "Machine Key" icon in the website Home Pane.

            If "HMACSHA256" or stronger encryption is not selected for the Validation method and/or "Auto" is not selected for the Encryption method, this is a finding.

            Verify "HMACSHA256"'
        }
    )

    Describe 'WebConfigurationProperty Rule Conversion' {

        foreach ( $stig in $stigRulesToTest )
        {
            Context $stig.Key {

                [xml] $StigRule = Get-TestStigRule -CheckContent $stig.CheckContent -XccdfTitle 'IIS'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $StigRule.Save( $TestFile )
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                It 'Should return an WebConfigurationPropertyRule Object' {
                    $rule.GetType() | Should -be 'WebConfigurationPropertyRule'
                }
                It "Should return ConfigSection '$($stig.ConfigSection)'" {
                    $rule.ConfigSection | Should -be $stig.ConfigSection
                }
                It "Should return Key '$($stig.Key)'" {
                    $rule.Key | Should -be $stig.Key
                }
                It "Should return Value '$($stig.Value)'" {
                    $rule.Value | Should -be $stig.Value
                }
                It 'Should set the correct DscResource' {
                    $rule.DscResource | Should -be 'xWebConfigKeyValue'
                }
                It 'Should Set the status to pass' {
                    $rule.ConversionStatus | Should -be 'pass'
                }
            }
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
