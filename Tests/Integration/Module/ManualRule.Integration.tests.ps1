#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $checkContent = 'Verify servers are located in controlled access areas that are accessible only to authorized personnel.  If systems are not adequately protected, this is a finding.'

    Describe 'Manual Check Conversion' {
        [xml] $stigRule = Get-TestStigRule -CheckContent $checkContent -XccdfTitle Windows
        $TestFile = Join-Path -Path $env:TEMP -ChildPath 'TextData.xml'
        $stigRule.Save( $TestFile )
        $rule = ConvertFrom-StigXccdf -Path $TestFile

        It 'Should return an ManualRule Object' {
            $rule.GetType() | Should -be 'ManualRule'
        }
        It "Should set the correct DscResource" {
            $rule.DscResource | Should -be 'None'
        }
    }
}

finally
{
    . $PSScriptRoot\.tests.Footer.ps1
}
