
<#
.SYNOPSIS
Script for the New-ModuleManifest command to create a new .psd1 file.
.DESCRIPTION
.NOTES
#>
[CmdletBinding()]
param (
	[Parameter()]
	[String]
	#$ModulePath = "$env:USERPROFILE\Documents\GitHub\SleepTimerPoSh\Examples\TestModuleManifest\MyTest.psd1",
	$ModulePath = "$env:USERPROFILE\Documents\GitHub\SleepTimerPoSh\SleepTimer\SleepTimer.psd1",
	
	# MyModule.psm1 as a RootModule inside module manifest.
	$RootModule = "$env:USERPROFILE\Documents\GitHub\SleepTimerPoSh\SleepTimer\SleepTimer.psm1",
	
	[String]$AuthorName = "Kerbalnut",
	[String]$CompanyName = "Kerbalnut",
	
	[version]$ModuleVersion = 1.0,
	
	[guid]$Guid,
	# Specifies a unique identifier for the module. The GUID can be used to distinguish among modules with the same name.
	# If you omit this parameter, `New-ModuleManifest` creates a GUID key in the manifest and generates a GUID for the value.
	# To create a new GUID in PowerShell, type `[guid]::NewGuid()`.
	
	[uri]$ProjectUri = "https://github.com/Kerbalnut/SleepTimerPoSh",
	[uri]$LicenseURI = "https://github.com/Kerbalnut/SleepTimerPoSh/blob/main/LICENSE",
	
	[String[]]$Tags = @("PowerShell","Desktop","Timer","Sleep"),
	
	$Description = "The SleepTimer module contains functions for a countdown timer that will put your computer to sleep/locked/restart/shutdown/hibernate state after a set time. It may also include little unrelated helper functions for testing and experimentation. See `Get-Command -Module SleepTimer` for all functions in this module.",
	
	$ReleaseNotes = "Test/Experimental release of SleepTimer module."
	
)

[version]$PowerShellVersion = 2.0

Get-Location | Out-Host
Write-Host $ModulePath

<#

New-ModuleManifest `
-Path $ModulePath `
-AliasesToExport '' `
#-AliasesToExport <System.String[]>`
-Author $AuthorName `
#-ClrVersion <System.Version>`
-CmdletsToExport '' `
#-CmdletsToExport <System.String[]>`
#-CompanyName <System.String>`
#-Confirm`
-CompatiblePSEditions 'Desktop' `
#                     {Desktop | Core}
#-Copyright <System.String>`
-Description $Description`
#-DotNetFrameworkVersion <System.Version>`
#-DscResourcesToExport <System.String[]>`
-FileList ''`
#-FileList <System.String[]>`
#-FormatsToProcess <System.String[]>`
-FunctionsToExport ''`
#-FunctionsToExport <System.String[]>`
#-Guid $Guid`
#-HelpInfoUri <System.String>`
#-IconUri <System.Uri>`
-LicenseUri [uri]$LicenseURI`
#-LicenseUri <System.Uri>`
#-ModuleList <System.Object[]>`
#-ModuleVersion <System.Version>`
#-NestedModules <System.Object[]>`
#-PassThru`
#-PowerShellHostName <System.String>`
#-PowerShellHostVersion <System.Version>`
-PowerShellVersion 2.0`
#-PowerShellVersion <System.Version>`
#-PrivateData <System.Object>`
#-ProcessorArchitecture {None | MSIL | X86 | IA64 | Amd64 | Arm}`
-ProjectUri [uri]$ProjectUri`
#-ProjectUri <System.Uri>`
-ReleaseNotes "Initial module creation."`
#-RequiredAssemblies <System.String[]>`
#-RequiredModules <System.Object[]>`
#-ScriptsToProcess <System.String[]>`
-Tags $Tags`
#-Tags <System.String[]>`
#-TypesToProcess <System.String[]>`
#-VariablesToExport <System.String[]>`
#-DefaultCommandPrefix <System.String>`
#-RootModule <System.String>`
#-WhatIf`
#<CommonParameters>

#>


New-ModuleManifest `
-Path $ModulePath `
-AliasesToExport '' `
-Author $AuthorName `
-CmdletsToExport '' `
-CompanyName $CompanyName `
-Description $Description `
-FileList '' `
-FunctionsToExport '' `
-LicenseUri $LicenseURI `
-PowerShellVersion $PowerShellVersion `
-ProjectUri $ProjectUri `
-ReleaseNotes $ReleaseNotes `
-Tags $Tags `
-RootModule $RootModule `






# End of script








Get-Module PowerShellGet, PackageManagement, Microsoft.PowerShell.PSResourceGet -ListAvailable


$a = Get-Module PowerShellGet, PackageManagement, Microsoft.PowerShell.PSResourceGet -ListAvailable


$a | Where-Object -Property 'Name' -eq 'PowerShellGet' 

$b = $a | Where-Object -Property 'Name' -eq 'PowerShellGet'


If ($b.Version -gt 1.0.0.1) {Write-Host "$($b.Version) is greater!"} else {Write-Host "$($b.Version) is lesser..."}



foreach ($Module in $b) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		Write-Host "Installed version $($Module.Version) is greater than 1.0.0.1"
	} Else {
		Write-Host "Installed version $($Module.Version) is NOT greater than 1.0.0.1"
	}
}


$NewerVersionInstalled = $False
foreach ($Module in $b) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		Write-Host "Installed version $($Module.Version) is greater than 1.0.0.1"
		$NewerVersionInstalled = $True
	} Else {
		Write-Host "Installed version $($Module.Version) is NOT greater than 1.0.0.1"
	}
}
If ($NewerVersionInstalled) {
	Write-Host "A newer version is already installed, Update-Module can be used"
} Else {
	Write-Host "1.0.0.1 or lower is installed, to upgrade to a newer version Install-Module must be used."
}


...

Get-Module PowerShellGet, PackageManagement, Microsoft.PowerShell.PSResourceGet -ListAvailable

$PowerShellGetModules = Get-Module PowerShellGet -ListAvailable

$NewerVersionInstalled = $False
foreach ($Module in $PowerShellGetModules) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		Write-Host "Installed version $($Module.Version) is greater than 1.0.0.1"
		$NewerVersionInstalled = $True
	} Else {
		Write-Host "Installed version $($Module.Version) is NOT greater than 1.0.0.1"
	}
}
If ($NewerVersionInstalled) {
	Write-Host "A newer version is already installed, Update-Module can be used"
} Else {
	Write-Host "1.0.0.1 or lower is installed, to upgrade to a newer version Install-Module must be used."
}







