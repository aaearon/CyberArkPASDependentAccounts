Quick example:
```
PS > Import-Module .\Add-PSDependentAccount.ps1
PS > Add-PASDependentAccount -MasterPassName "Operating System-ioSHARPWindowsDomainServiceAccount-iosharp.lab-serviceAccount01" -SafeName Windows -PlatformId INIFile -address server01.iosharp.lab -platformAccountProperties @{'FilePath' = 'C:\ExampleScheduledTask\example2.ini'; 'ConnectionType' = 'Windows File Sharing'; 'INISection' = 'Main'; 'INIParameterName' = 'Password'} -EnsureUniqueName
```