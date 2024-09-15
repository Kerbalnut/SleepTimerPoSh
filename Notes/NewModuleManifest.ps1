
<#
.SYNOPSIS
.DESCRIPTION
.NOTES
#>
[CmdletBinding()]
param (
	[Parameter()]
	[String]
	#$ModulePath = "$env:USERPROFILE\Documents\GitHub\SleepTimerPoSh\Examples\TestModuleManifest\MyTest.psd1",
	$ModulePath = "$env:USERPROFILE\Documents\GitHub\SleepTimerPoSh\SleepTimer\SleepTimer.psd1",
	
	[String]$AuthorName = "Kerbalnut",
	
	[guid]$Guid,
	# Specifies a unique identifier for the module. The GUID can be used to distinguish among modules with the same name.
	# If you omit this parameter, `New-ModuleManifest` creates a GUID key in the manifest and generates a GUID for the value.
	# To create a new GUID in PowerShell, type `[guid]::NewGuid()`.
	
	[uri]$ProjectUri = "https://github.com/Kerbalnut/SleepTimerPoSh",
	[uri]$LicenseURI = "https://github.com/Kerbalnut/SleepTimerPoSh/blob/main/LICENSE",
	
	[String[]]$Tags = @("PowerShell","Desktop","Timer","Sleep")
	
)

$Description = "The SleepTimer module contains functions for a countdown timer that will put your computer to sleep/locked/restart/shutdown/hibernate state after a set time. It may also include little unrelated helper functions for testing and experimentation. See `Get-Command -Module SleepTimer` for all functions in this module."

$ReleaseNotes = "Test/Experimental release of SleepTimer module."

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
-Description $Description `
-FileList '' `
-FunctionsToExport '' `
-LicenseUri $LicenseURI `
-PowerShellVersion 2.0 `
-ProjectUri $ProjectUri `
-ReleaseNotes $ReleaseNotes `
-Tags $Tags 







