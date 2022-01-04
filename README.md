Quick example:
```
PS > Import-Module .\Add-PSDependentAccount.ps1
PS > Add-PASDependentAccount -MasterPassName "Operating System-ioSHARPWindowsDomainServiceAccount-iosharp.lab-serviceAccount01" -SafeName Windows -PlatformId INIFile -address server01.iosharp.lab -platformAccountProperties @{'FilePath' = 'C:\ExampleScheduledTask\example2.ini'; 'ConnectionType' = 'Windows File Sharing'; 'INISection' = 'Main'; 'INIParameterName' = 'Password'} -EnsureUniqueName
```

Note: This script does not manage the PACLI session to the Vault. The expectation is that PACLI has already logged on to the Vault and is ready to execute commands. The commandlet will check if this is the case and if not throw an exception.