# Manage CyberArk Dependent Accounts

A commandlet that leverages [PoShPACLI](https://github.com/pspete/PoShPACLI) to easily add CyberArk dependent accounts in a style similiar to [psPAS](https://pspas.pspete.dev/).

The original idea had `Remove-PASDependentAccount` and `Set-PASDependentAccount` but the functionality would be that of the already-existing PoShPACLI commandlets `Remove-PVFile` and `Set-PVFileCategory`.

Note: This script does not manage the PACLI session to the Vault. The expectation is that PACLI has already logged on to the Vault and is ready to execute commands. The commandlet will check if this is the case and if not throw an exception.

## Example

```powershell
PS > Import-Module .\Add-PASDependentAccount.ps1
PS > Add-PASDependentAccount `
        -MasterPassName "Operating System-ioSHARPWindowsDomainServiceAccount-iosharp.lab-serviceAccount01" `
        -SafeName Windows `
        -PlatformId INIFile `
        -address server01.iosharp.lab `
        -platformAccountProperties @{'FilePath' = 'C:\Example\example2.ini'; 'ConnectionType' = 'Windows File Sharing'; 'INISection' = 'Main'; 'INIParameterName' = 'Password'} `
        -EnsureUniqueName
```

### Passing an Account object from psPAS

```powershell
PS > Get-PASAccount -search "admin01 server02.iosharp.lab" `
        | Add-PASDependentAccount -PlatformId INIFile `
        -address server02.iosharp.lab `
        -platformAccountProperties @{'FilePath' = 'C:\Example\example2.ini'; 'ConnectionType' = 'Windows File Sharing'; 'INISection' = 'Main'; 'INIParameterName' = 'Password'}
```
