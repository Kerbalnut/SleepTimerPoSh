# Work In Progress

# SleepTimerPoSh

A PowerShell module for 'Start-SleepTimer' function, along with other associated support functions.

The inspiration is to create a simple-to-use software to put your computer to sleep after a specified countdown timer, just like the 'sleep timer' function on most televisions.

Additional options include changing the computer's power state to sleep/hibernate/shutdown/restart/locked, or to set a target activation time rather than a countdown timer.

Table of Contents:

- [Work In Progress](#work-in-progress)
- [SleepTimerPoSh](#sleeptimerposh)
- [Examples](#examples)
- [Installing](#installing)
- [Updating](#updating)
- [Building](#building)
	- [Prerequisites for publishing to PowerShell Gallery:](#prerequisites-for-publishing-to-powershell-gallery)
		- [Install/Update PowerShellGet and PackageManagement](#installupdate-powershellget-and-packagemanagement)
			- [Installing .NET Framework 4.5 (if necessary)](#installing-net-framework-45-if-necessary)
			- [Enable TLS 1.2 in Profile](#enable-tls-12-in-profile)
			- [Update PowerShellGet](#update-powershellget)
			- [Start a new PowerShell session](#start-a-new-powershell-session)
			- [Add PowerShell Gallery as a trusted repository](#add-powershell-gallery-as-a-trusted-repository)
			- [Install Microsoft.PowerShell.PSResourceGet module](#install-microsoftpowershellpsresourceget-module)
			- [Update all modules](#update-all-modules)
		- [Install necessary CI/CD modules:](#install-necessary-cicd-modules)


# Examples

WIP

# Installing

WIP

# Updating

WIP

# Building

Building includes publishing the finished module to PowerShell Gallery, and the necessary modules to do so must be installed.

[Getting Started with the PowerShell Gallery](https://learn.microsoft.com/en-us/powershell/gallery/getting-started?view=powershellget-3.x)

## Prerequisites for publishing to PowerShell Gallery:

[How to Install PowerShellGet and PSResourceGet](https://learn.microsoft.com/en-us/powershell/gallery/powershellget/install-powershellget?view=powershellget-3.x)

### Install/Update PowerShellGet and PackageManagement

How to check if PowerShell modules **PowerShellGet** and **PackageManagement** versions greater than **1.0.0.1** are installed:

```PowerShell
Get-Module PowerShellGet, PackageManagement, Microsoft.PowerShell.PSResourceGet -ListAvailable
```

Required Module versions:

| Module Name         | Required Version                 |
|--------------------:|:---------------------------------|
| *PowerShellGet*     | any version greater than 1.0.0.1 |
| *PackageManagement* | any version greater than 1.0.0.1 |
| *Microsoft.PowerShell.PSResourceGet* | any version installed |

<details>
    <summary>Or, run this code below to verify: <i>(Click to expand/collapse)</i></summary>

---

Run in a PowerShell session to test if you have the required prerequisites installed.:

```PowerShell
# Check PowerShellGet version:
$PowerShellGetModules = Get-Module PowerShellGet -ListAvailable
$PowerShellGet = $False
foreach ($Module in $PowerShellGetModules) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		$PowerShellGet = $True
		$PowerShellGetVer = [version]$Module.Version
	}
}

# Check PackageManagement version:
$PackageManagementModules = Get-Module PackageManagement -ListAvailable
$PackageManagement = $False
foreach ($Module in $PackageManagementModules) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		$PackageManagement = $True
		$PackageManagementVer = [version]$Module.Version
	}
}

# Display results:
If ($PowerShellGet) {
	Write-Host "[v] - Good  - PowerShellGet version [$PowerShellGetVer] > [1.0.0.1]" -ForegroundColor Green -BackgroundColor Black
} Else {
	Write-Host "[X] - Error - PowerShellGet version is NOT greater than [1.0.0.1]" -ForegroundColor Red -BackgroundColor Black
}
If ($PackageManagement) {
	Write-Host "[v] - Good  - PackageManagement version [$PackageManagementVer] > [1.0.0.1]" -ForegroundColor Green -BackgroundColor Black
} Else {
	Write-Host "[X] - Error - PackageManagement version is NOT greater than [1.0.0.1]" -ForegroundColor Red -BackgroundColor Black
}
If ((Get-Module Microsoft.PowerShell.PSResourceGet -ListAvailable)) {
	Write-Host "[v] - Good  - PSResourceGet is installed." -ForegroundColor Green -BackgroundColor Black
} Else {
	Write-Host "[X] - Error - PSResourceGet is NOT installed." -ForegroundColor Red -BackgroundColor Black
}
```

---

<!-- &#11206;. -->
&#11205;

---

</details>

---


<details>
    <summary>To install a version greater than 1.0.0.1 of either module: <i>(Click to expand/collapse)</i></summary>

---

Windows PowerShell 5.1 comes with version 1.0.0.1 of the **PowerShellGet** and **PackageManagement** preinstalled. This version of PowerShellGet has a limited features and must be updated to work with the PowerShell Gallery.

*How to get PowerShell version:*

```PowerShell
$PSVersionTable.PSVersion
```

[Source - How to Install PowerShellGet and PSResourceGet](https://learn.microsoft.com/en-us/powershell/gallery/powershellget/install-powershellget?view=powershellget-3.x)

- PowerShellGet requires **.NET Framework 4.5** or above.
- To access the PowerShell Gallery, you must use **Transport Layer Security (TLS) 1.2** or higher. 

#### Installing .NET Framework 4.5 (if necessary)

How to check if .NET Framework is installed (PowerShell):

```PowerShell
# Check if .NET Framework is installed
If (!(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full")) {
    Write-Warning ".NET Framework is not installed"
}
```

How to check installed .NET Framework version (PowerShell):

```PowerShell
# Check if correct .NET Framework version (greater than or equal to 4.5)
$DotNetVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Version
If ($DotNetVersion -ge 4.5) {
	Write-Host "Correct .NET Framework version installed! $DotNetVersion >= 4.5" -ForegroundColor Green -BackgroundColor Black
} Else {
	Write-Host "Need to update .NET Framework to 4.5 or higher. Current version: $DotNetVersion" -ForegroundColor Red -BackgroundColor Black
}
```

<details>
    <summary>If .NET Framework 4.5 or greater is not installed:</summary>

---

Windows PowerShell 5.1 comes with version 1.0.0.1 of the **PowerShellGet** and **PackageManagement** preinstalled. This version of PowerShellGet has a limited features and must be updated to work with the PowerShell Gallery.

If you're running Windows PowerShell 5.1 with PowerShellGet 1.0.0.1, see [Update PowerShellGet for Windows PowerShell 5.1](https://learn.microsoft.com/en-us/powershell/gallery/powershellget/update-powershell-51?view=powershellget-3.x) 

*Get PowerShell version:*

```PowerShell
$PSVersionTable.PSVersion
```

- PowerShellGet requires .NET Framework 4.5 or above. For more information, see [Install the .NET Framework for developers](https://learn.microsoft.com/en-us/dotnet/framework/install/guide-for-developers)

All .NET Framework versions since .NET Framework 4 are in-place updates, so only a single 4.x version can be present on a system.

---

<!-- &#11206;. -->
&#11205;

---

</details>

---

#### Enable TLS 1.2 in Profile

To access the PowerShell Gallery, you must use Transport Layer Security (TLS) 1.2 or higher. 

The following command will enable TLS 1.2 in your PowerShell session:

```PowerShell
[Net.ServicePointManager]::SecurityProtocol =
    [Net.ServicePointManager]::SecurityProtocol -bor
    [Net.SecurityProtocolType]::Tls12
```

It's easiest to add this command to your **PowerShell profile** script to ensure TLS 1.2 is configured for every PowerShell session. For more information about profiles, see [about_Profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.4).

PowerShell Profile locations:

- All Users, All Hosts
  - Windows - `$PSHOME\Profile.ps1`
  - Linux - `/opt/microsoft/powershell/7/profile.ps1`
  - macOS - `/usr/local/microsoft/powershell/7/profile.ps1`
- All Users, Current Host
  - Windows - `$PSHOME\Microsoft.PowerShell_profile.ps1`
  - Linux - `/opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1`
  - macOS - `/usr/local/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1`
- Current User, All Hosts
  - Windows - `$HOME\Documents\PowerShell\Profile.ps1`
  - Linux - `~/.config/powershell/profile.ps1`
  - macOS - `~/.config/powershell/profile.ps1`
- Current user, Current Host
  - Windows - `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
  - Linux - `~/.config/powershell/Microsoft.PowerShell_profile.ps1`
  - macOS - `~/.config/powershell/Microsoft.PowerShell_profile.ps1`

How to create your **PowerShell Profile** file, if necessary **(Run As Administrator)**:

```PowerShell
# (PowerShell: Run As Administrator)
# Fill in your chosen profile location from list above:
$PoShProfile = "$PSHOME\Profile.ps1"

If (!(Test-Path -Path $PoShProfile)) {
  New-Item -Path $PoShProfile -ItemType File -Force
  Set-Content -Path $PoShProfile -Value "Write-Host `"Loading PowerShell Profile: '$PoShProfile'`" -ForegroundColor White -BackgroundColor Black`n"
} Else {
  Write-Output "File already exists: '$PoShProfile'"
}
```

Check if the TLS 1.2 code snippet has already been added to your Profile:

```PowerShell
# Verify by reading file contents and printing to console:
Write-Host " `n----- Showing '$PoShProfile' Content: -----" -ForegroundColor Yellow -BackgroundColor Black; Get-Content $PoShProfile; Write-Host "----- End $((Get-Item $PoShProfile).Name) content -----`n" -ForegroundColor Yellow -BackgroundColor Black
```

Or, inspect it in your default `.ps1`-file editor application:

```PowerShell
# Open file with defualt program using Invoke-Item:
ii $PoShProfile # Invoke-Item $PoShProfile
```

How to enable TLS 1.2 in your PowerShell sessions **(Run As Administrator)**:

```PowerShell
# (PowerShell: Run As Administrator)
# Include a descriptive comment for the code being added to Profile:
$TLS12 = @"
# To access the PowerShell Gallery, you must use Transport Layer Security (TLS) 1.2 or higher. The following command will enable TLS 1.2 in your PowerShell session:
[Net.ServicePointManager]::SecurityProtocol =
    [Net.ServicePointManager]::SecurityProtocol -bor
    [Net.SecurityProtocolType]::Tls12
Write-Host "TLS v1.2 loaded for PowerShell Gallery compatibility" -ForegroundColor Blue -BackgroundColor White
"@

# Add padding to the string:
$TLS12 = "`n`n$TLS12`n`n"

# Add the code snippet to Profile:
Add-Content -Path $PoShProfile -Value $TLS12

# Verify the change by reading file contents back:
Write-Host " `n----- Showing $PoShProfile Content: -----" -ForegroundColor Yellow -BackgroundColor Black; Get-Content $PoShProfile; Write-Host "----- End $((Get-Item $PoShProfile).Name) content -----`n" -ForegroundColor Yellow -BackgroundColor Black
```

To view the file in your default editor:

```PowerShell
# Open file with defualt program using Invoke-Item:
ii $PoShProfile # Invoke-Item $PoShProfile
```

#### Update PowerShellGet

To update the preinstalled module (1.0.0.1 that comes with v5.1) you must use `Install-Module`. After you have installed the new version from the PowerShell Gallery, you can use `Update-Module` to install newer releases.

Windows PowerShell 5.1 comes with **PowerShellGet** version 1.0.0.1, which doesn't include the NuGet provider. The provider is required by **PowerShellGet** when working with the PowerShell Gallery.

```PowerShell
Get-Module PowerShellGet -ListAvailable
```

If only 1.0.0.1 is installed, run these commands *(Run As Administrator)*:

```PowerShell
Install-PackageProvider -Name NuGet -Force
```

```PowerShell
Install-Module PowerShellGet -AllowClobber -Force
```

Or, to run the correct commands automatically *(Run As Administrator)*:

```PowerShell
$PowerShellGetModules = Get-Module PowerShellGet -ListAvailable

$NewerVersionInstalled = $False
foreach ($Module in $PowerShellGetModules) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		Write-Host "Installed version $($Module.Version) is greater than 1.0.0.1"
		$NewerVersionInstalled = $True
    $NewVer = [version]$Module.Version
	}
}
If ($NewerVersionInstalled) {
	Write-Host "A newer version ($NewVer) of PowerShellGet is already installed, Update-Module can be used."
	Update-Module PowerShellGet
} Else {
	Write-Host "1.0.0.1 or lower of PowerShellGet is installed, to upgrade to a newer version, Install-Module must be used."
	Install-PackageProvider -Name NuGet -Force
	Install-Module PowerShellGet -AllowClobber -Force
}
```

#### Start a new PowerShell session

After you have installed the new version of PowerShellGet, you should close your current PowerShell session right now, and open a new *(Administrator)* one. PowerShell automatically loads the newest version of the module when you use a PowerShellGet cmdlet.

Once a new PowerShell window is open, check PowerShellGet version:

```PowerShell
Get-Module PowerShellGet, PackageManagement -ListAvailable
```

#### Add PowerShell Gallery as a trusted repository

We also recommend that you register the PowerShell Gallery as a trusted repository. Use the following command:
PowerShell

```PowerShell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
```

#### Install Microsoft.PowerShell.PSResourceGet module

Microsoft.PowerShell.PSResourceGet is the new package management solution for PowerShell. With this module, you no longer need to use PowerShellGet and PackageManagement. However, it can be installed side-by-side with the existing PowerShellGet module. To install Microsoft.PowerShell.PSResourceGet side-by-side with your existing PowerShellGet version, open any PowerShell console and run:

Check if *Microsoft.PowerShell.PSResourceGet* is installed:

```PowerShell
Get-Module Microsoft.PowerShell.PSResourceGet -ListAvailable
```

> Microsoft.PowerShell.PSResourceGet is preinstalled with PowerShell 7.4 and later.

Install *Microsoft.PowerShell.PSResourceGet* if necessary:

```PowerShell
Install-Module Microsoft.PowerShell.PSResourceGet -Repository PSGallery -Force
```

Check that all necessary modules are installed:

```PowerShell
Get-Module PowerShellGet, PackageManagement, Microsoft.PowerShell.PSResourceGet -ListAvailable
```

| Module Name         | Required Version                 |
|--------------------:|:---------------------------------|
| *PowerShellGet*     | any version greater than 1.0.0.1 |
| *PackageManagement* | any version greater than 1.0.0.1 |
| *Microsoft.PowerShell.PSResourceGet* | any version |

Or, run this code below to verify:

```PowerShell
# Check PowerShellGet version:
$PowerShellGetModules = Get-Module PowerShellGet -ListAvailable
$PowerShellGet = $False
foreach ($Module in $PowerShellGetModules) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		$PowerShellGet = $True
		$PowerShellGetVer = [version]$Module.Version
	}
}

# Check PackageManagement version:
$PackageManagementModules = Get-Module PackageManagement -ListAvailable
$PackageManagement = $False
foreach ($Module in $PackageManagementModules) {
	If ([version]$Module.Version -gt [version]'1.0.0.1') {
		$PackageManagement = $True
		$PackageManagementVer = [version]$Module.Version
	}
}

# Display results:
If ($PowerShellGet) {
	Write-Host "[v] - Good  - PowerShellGet version [$PowerShellGetVer] > [1.0.0.1]" -ForegroundColor Green -BackgroundColor Black
} Else {
	Write-Host "[X] - Error - PowerShellGet version is NOT greater than [1.0.0.1]" -ForegroundColor Red -BackgroundColor Black
}
If ($PackageManagement) {
	Write-Host "[v] - Good  - PackageManagement version [$PackageManagementVer] > [1.0.0.1]" -ForegroundColor Green -BackgroundColor Black
} Else {
	Write-Host "[X] - Error - PackageManagement version is NOT greater than [1.0.0.1]" -ForegroundColor Red -BackgroundColor Black
}
If ((Get-Module Microsoft.PowerShell.PSResourceGet -ListAvailable)) {
	Write-Host "[v] - Good  - PSResourceGet is installed." -ForegroundColor Green -BackgroundColor Black
} Else {
	Write-Host "[X] - Error - PSResourceGet is NOT installed." -ForegroundColor Red -BackgroundColor Black
}
```

#### Update all modules

How-to update all modules:

```PowerShell
Update-Module PowerShellGet, PackageManagement, Microsoft.PowerShell.PSResourceGet
```

Update help text:

```PowerShell
Update-Help -Module PowerShellGet, PackageManagement -Force
Update-Help -Module Microsoft.PowerShell.PSResourceGet -Force
```

---

<!-- &#11206;. -->
&#11205;

---

</details>

---

### Install necessary CI/CD modules:

- [CI/CD pipeline for PowerShell](https://renehernandez.io/tutorials/ci-cd-pipeline-for-powershell/)
- [powershell.sample-module - A sample CI/CD pipeline for a PowerShell module.](https://github.com/andrewmatveychuk/powershell.sample-module)
- [A sample CI/CD pipeline for PowerShell module](https://andrewmatveychuk.com/a-sample-ci-cd-pipeline-for-powershell-module/)
- [powershellget-module - Unofficial example of PowerShellGet-friendly package.](https://github.com/apurin/powershellget-module)
- [Publish PowerShell functions to PowerShell Gallery](https://www.codewrecks.com/post/general/powershell-gallery/)
- [PowerShell: Automatic Module Semantic Versioning](https://powershellexplained.com/2017-10-14-Powershell-module-semantic-version/)

| Module Name                                | Purpose  |
|-------------------------------------------:|:---------|
| [InvokeBuild](https://github.com/nightroman/Invoke-Build) | Build automation |
| [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) | Linter/Syntax checker |
| [Pester](https://github.com/pester/Pester) | Tests |
| [PSDepend](https://github.com/RamblingCookieMonster/PSDepend) | Dependency management |
| [BuildHelpers](https://github.com/RamblingCookieMonster/BuildHelpers) | Increment version number |

How to check if these modules are installed:

```PowerShell
Get-Module InvokeBuild, PSScriptAnalyzer, Pester, PSDepend, BuildHelpers -ListAvailable
```

Or use this function to test

```PowerShell
function Test-MyPsMods {
	param ()
	If ((Get-Module InvokeBuild -ListAvailable)) {
		Write-Host "[v] - Good  - InvokeBuild is installed." -ForegroundColor Green -BackgroundColor Black
	} Else {
		Write-Host "[X] - Error - InvokeBuild is NOT installed." -ForegroundColor Red -BackgroundColor Black
	}
	If ((Get-Module PSScriptAnalyzer -ListAvailable)) {
		Write-Host "[v] - Good  - PSScriptAnalyzer is installed." -ForegroundColor Green -BackgroundColor Black
	} Else {
		Write-Host "[X] - Error - PSScriptAnalyzer is NOT installed." -ForegroundColor Red -BackgroundColor Black
	}
	If ((Get-Module Pester -ListAvailable)) {
		Write-Host "[v] - Good  - Pester is installed." -ForegroundColor Green -BackgroundColor Black
	} Else {
		Write-Host "[X] - Error - Pester is NOT installed." -ForegroundColor Red -BackgroundColor Black
	}
	If ((Get-Module PSDepend -ListAvailable)) {
		Write-Host "[v] - Good  - PSDepend is installed." -ForegroundColor Green -BackgroundColor Black
	} Else {
		Write-Host "[X] - Error - PSDepend is NOT installed." -ForegroundColor Red -BackgroundColor Black
	}
	If ((Get-Module BuildHelpers -ListAvailable)) {
		Write-Host "[v] - Good  - BuildHelpers is installed." -ForegroundColor Green -BackgroundColor Black
	} Else {
		Write-Host "[X] - Error - BuildHelpers is NOT installed." -ForegroundColor Red -BackgroundColor Black
	}
}
Test-MyPsMods
```

Import modules if they already are present on the system:

```PowerShell
Import-Module InvokeBuild, PSScriptAnalyzer, Pester, PSDepend, BuildHelpers -Force
```

How to install the modules if they are not present:

```PowerShell
Install-Module InvokeBuild, PSScriptAnalyzer, Pester, PSDepend, BuildHelpers -Force
```

Show all the commands from a specific module:

```PowerShell
Get-Command -Module BuildHelpers
```

How to update the modules:

```PowerShell
Update-Module InvokeBuild, PSScriptAnalyzer, Pester, PSDepend, BuildHelpers
```

<details>
    <summary><h4>Work In Progress</h4></summary>

---

---

<!-- &#11206;. -->
&#11205;

---

</details>

---


<h1>Work In Progress</h1>

