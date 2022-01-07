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
        $platformAccountProperties,

        # Adds a random, 8 character string to the end of the dependent account name.
        [Parameter(Mandatory = $false)]
        [switch]
        $EnsureUniqueName
    )

    begin {
        # Just used to check if PACLI is connected to a Vault and if not stop right there.
        Get-PVUserList -ErrorAction Stop | Out-Null
    }

    process {
        Open-PVSafe -safe $SafeName | Out-Null

        # This will generate something like Operating System-ioSHARPWindowsDomainServiceAccount-iosharp.lab-serviceAccount01-INIFile-server01.iosharp.lab
        $fileName = "$MasterPassName-$PlatformId-$Address"

        # If an object is added with a name that matches a deleted account, it will undelete that object instead (older activities, existing file categories, etc.
        # will still be there.) This will generate something like Operating System-ioSHARPWindowsDomainServiceAccount-iosharp.lab-serviceAccount01-INIFile-server01.iosharp.lab-77bfca12
        if ($EnsureUniqueName) { $fileName = "$fileName-$($((new-guid).Guid).Split('-')[0])" }

        # PACLI needs a password value provided. We will pass an empty value as the value does not matter. When the CPM updates a dependent account, it only updates the target
        # server using the password of the account defined in MasterPassName and never the password of the dependent account in the Vault.
        Add-PVPasswordObject -safe $SafeName -folder Root -file $fileName -Password (" " | ConvertTo-SecureString -AsPlainText -Force)

        # Platform-independent properties
        Set-FileCategory -safe $safeName -folder Root -file $fileName -category 'MasterPassName' -value $MasterPassName
        Set-FileCategory -safe $safeName -folder Root -file $fileName -category 'MasterPassFolder' -value Root
        Set-FileCategory -safe $safeName -folder Root -file $fileName -category 'PolicyId' -value $PlatformId
        Set-FileCategory -safe $safeName -folder Root -file $fileName -category 'address' -value $address
        if ($automaticManagementEnabled -eq $false -and $manualManagementReason) {
            Set-FileCategory -safe $safeName -folder Root -file $fileName -category 'CPMDisabled' -value $manualManagementReason
        }
        if ($automaticManagementEnabled -eq $false -and $manualManagementReason -eq $null) {
            Set-FileCategory -safe $safeName -folder Root -file $fileName -category 'CPMDisabled' -value 'NoReason'
        }

        # Platform-specific properties
        foreach ($Property in $platformAccountProperties.GetEnumerator()) {
            Set-FileCategory -safe $safeName -folder Root -file $fileName -category $Property.Key -value $Property.Value -ErrorAction Stop
        }

        Close-PVSafe -safe $safeName | Out-Null
    }

    end {

    }
}

# If an object exists and we try to 'Add' a category, it will throw an error and we need
# to 'Set' the category instead. As adding a PVPasswordObject will undelete a previously deleted
# PVPasswordObject, there is a chance when adding we will unknowngily undelete an object and thus
# need to 'Set' vs 'Add' a category. As to not have a bunch of try/catch statements, we create
# our own, short wrapper function here which implements the try/catch in order to not have it X
# amount of times above.
function Set-FileCategory {
    param (
        $safeName,
        $file,
        $category,
        $value
    )

    try {
        Add-PVFileCategory -safe $safeName -folder Root -file $fileName -category $category -value $value -ErrorAction Stop
    }
    catch {
        Set-PVFileCategory -safe $safeName -folder Root -file $fileName -category $category -value $value -ErrorAction Stop
    }
}