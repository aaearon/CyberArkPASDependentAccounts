#Requires -Module PoShPACLI
function Add-PASDependentAccount {
    [CmdletBinding()]
    param (
        # Name of the master password (account) this dependency will be related to.
        [Parameter(Mandatory = $true)]
        [string]
        $MasterPassName,

        # Name of the safe the master password (account) is stored in. The dependency will be added there.
        [Parameter(Mandatory = $true)]
        [string]
        $SafeName,

        # The ID of the platform the dependency will be added as.
        [Parameter(Mandatory = $true)]
        [string]
        $PlatformId,

        # The address the dependency is located.
        [Parameter(Mandatory = $true)]
        [string]
        $address,

        # Whether to disable CPM password management.
        [Parameter(Mandatory = $false)]
        [boolean]
        $automaticManagementEnabled,

        # User-provided reason as to why CPM password management is disabled.
        [Parameter(Mandatory = $false)]
        [string]
        $manualManagementReason,

        # Dependency-specific required and optional properties to define.
        [Parameter(Mandatory = $true)]
        [hashtable]
        $platformAccountProperties
    )

    begin {
        # Check if PACLI is connected to a Vault if not throw an error.
    }

    process {
        Open-PVSafe -safe $SafeName
        # Check if object exists

        # Operating System-ioSHARPWindowsDomainServiceAccount-iosharp.lab-serviceAccount01-INIFile-server01.iosharp.lab
        $fileName = "$MasterPassName-$PlatformId-$Address"
        # PACLI needs a password value provided. We will pass a dummy value and the next password change will update it.
        Add-PVPasswordObject -safe $SafeName -folder Root -file $fileName -Password ("dummy" | ConvertTo-SecureString -AsPlainText -Force)

        # Platform-independent properties
        Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category 'MasterPassName' -value $MasterPassName
        Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category 'MasterPassFolder' -value Root
        Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category 'PolicyId' -value $PlatformId
        Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category 'address' -value $address
        if ($automaticManagementEnabled -eq $false -and $manualManagementReason) {
            Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category 'CPMDisabled' -value $manualManagementReason
        }
        if ($automaticManagementEnabled -eq $false -and $manualManagementReason -eq $null) {
            Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category 'CPMDisabled' -value 'NoReason'
        }

        # Platform-specific properties
        foreach ($Property in $platformAccountProperties.GetEnumerator()) {
            Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category $Property.Key -value $Property.Value
        }
    }

    end {

    }
}