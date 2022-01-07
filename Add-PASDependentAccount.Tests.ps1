BeforeAll {
    . $PSScriptRoot\Add-PASDependentAccount.ps1

    Mock -CommandName Get-PVUserList -MockWith {}
    Mock -CommandName Open-PVSafe -MockWith {}
    Mock -CommandName Add-PVPasswordObject -MockWith {}
    Mock -CommandName Set-PVFileCategory -MockWith {}
    Mock -CommandName Close-PVSafe -MockWith {}
}

Describe 'Add-PASDependentAccount' {
    It 'takes an object returned by Get-PASAccount in the pipeline' {
        $SinglePASAccountResult = [PSCustomObject]@{
            name     = 'localAdmin01@server02.iosharp.lab'
            userName = 'localAdmin01'
            Id       = '20_1'
            address  = 'server02.iosharp.lab'
            safeName = 'Windows'
        }

        $SinglePASAccountResult | Add-PASDependentAccount -PlatformId INIFile -address server01.iosharp.lab -platformAccountProperties @{'FilePath' = 'C:\Example\example2.ini'; 'ConnectionType' = 'Windows File Sharing'; 'INISection' = 'Main'; 'INIParameterName' = 'Password'}

        Should -Invoke -CommandName Add-PVPasswordObject -ParameterFilter {$file -eq 'localAdmin01@server02.iosharp.lab-INIFile-server01.iosharp.lab' -and $SafeName -eq 'Windows'}
    }
}

