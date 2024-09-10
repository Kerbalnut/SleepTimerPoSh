
<#
.SYNOPSIS
Set a sleep timer for the local computer.
.DESCRIPTION
This script is a series of funcitons to schedule a task or run a countdown timer to sleep/hibernate/shutdown/reboot the local computer.
.NOTES
.EXAMPLE
Start-SleepTimer -Hours 2 -Minutes 30 -Action 'sleep'
Starts a sleep countdown timer for 2 hours and 30 minutes from now. 
#>
[CmdletBinding(
	DefaultParameterSetName = 'StringName',
	SupportsShouldProcess = $True
)]
Param(
	[Parameter(HelpMessage = "Immediately executes power state command")]
	[Alias('ScriptCmd','ScheduledCmd')]
	[Switch]$SetPower,
	
	[Parameter(
		Mandatory = $False, 
		Position = 0, 
		ValueFromPipeline = $True, 
		ValueFromPipelineByPropertyName = $True, 
		ParameterSetName = 'StringName'
	)]
	[ValidateSet('Sleep','Suspend','Standby','Hibernate')]
	[Alias('PowerAction')]
	[String]$Action,
	[Switch]$DisableWake,
	[Switch]$Force
)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Hardcoded overrides:
$VerbosePreference = 'Continue'
#$VerbosePreference = 'SilentlyContinue'
#$VerbosePreference = 'Continue'
#$VerbosePreference = 'SilentlyContinue'
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$CommonParameters = @{ # These get activated when adding [CmdletBinding()] and param() to a script/function.
	Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
	Debug = [System.Management.Automation.ActionPreference]$DebugPreference
}


#-----------------------------------------------------------------------------------------------------------------------
# [Functions:]----------------------------------------------------------------------------------------------------------
Write-Verbose -Message "[$FunctionName]: Loading Functions"


#-----------------------------------------------------------------------------------------------------------------------
# Define functions:

function Stop-ValheimServer {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		$ProcessName = "valheim_server"
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{ # These get activated when adding [CmdletBinding()] and param() to a script/function.
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	#[System.Management.Automation.ConfirmImpact]$ConfirmPreference = 'High' # ConfirmPreference var has 4 possible ConfirmImpact values: None, Low, Medium, or High (default).
	If ($ConfirmPreference -eq 'Low') {$Confirm = $True} Else {$Confirm = $False} # When calling a function with -Confirm, the value of $ConfirmPreference gets set to Low inside the scope of your function.
	$RiskMitigationParameters = @{ # These params -WhatIf and -Confirm get automatically added when adding [CmdletBinding(SupportsShouldProcess)] to a script/function.
		WhatIf = [bool]$WhatIfPreference
		Confirm = [bool]$Confirm
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Write-Host "Stopping Valheim Server process: $ProcessName" -ForegroundColor Black -BackgroundColor Red
	try {
		$ServerProcessId = (Get-Process -Name $ProcessName -ErrorAction Stop @CommonParameters).Id
	}
	catch {
		Write-Warning "No '$ProcessName' process detected. No process to stop. Skipping..."
		Return
	}
	If ([bool]$WhatIfPreference) {
		Write-Information "What If: Running ($($MyInvocation.MyCommand.Name)) taskkill.exe /pid $ServerProcessId"
		Write-Host "What If: Running ($($MyInvocation.MyCommand.Name)) taskkill.exe /pid $ServerProcessId" -BackgroundColor Black -ForegroundColor Gray
	}
	# # $PSCmdlet.ShouldProcess('TARGET')
	# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
	# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
	# What if: Performing the operation "OPERATION" on target "TARGET".
	# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
	# What if: MESSAGE
	#If ($PSCmdlet.ShouldProcess('TARGET','OPERATION')){
	If ($PSCmdlet.ShouldProcess("$ProcessName ($ServerProcessId)",'taskkill.exe /pid')) {
		#taskkill.exe /pid $ServerProcessId
		#Start-Process taskkill.exe -Wait -ArgumentList "/pid $ServerProcessId"
		Start-Process cmd.exe -Wait @CommonParameters -ArgumentList "/C taskkill.exe /pid $ServerProcessId"
	}
} # / function Stop-ValheimServer

function Start-ValheimServer {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		$ServerStartupScript = "D:\SteamLibrary\steamapps\common\Valheim dedicated server\start_headless_server.bat",
		#$ServerStartupScript = "D:\SteamLibrary\steamapps\common\Valheim dedicated server\start_headless_server_test.bat",
		$ThunderstoreMMProfileName = "wordpass_server_vanilla",
		
		[Parameter(Mandatory=$False)]
		$LaunchParams
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{ # These get activated when adding [CmdletBinding()] and param() to a script/function.
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	#[System.Management.Automation.ConfirmImpact]$ConfirmPreference = 'High' # ConfirmPreference var has 4 possible ConfirmImpact values: None, Low, Medium, or High (default).
	If ($ConfirmPreference -eq 'Low') {$Confirm = $True} Else {$Confirm = $False} # When calling a function with -Confirm, the value of $ConfirmPreference gets set to Low inside the scope of your function.
	$RiskMitigationParameters = @{ # These params -WhatIf and -Confirm get automatically added when adding [CmdletBinding(SupportsShouldProcess)] to a script/function.
		WhatIf = [bool]$WhatIfPreference
		Confirm = [bool]$Confirm
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# Finish setting up remaining parameters:
	If (!($LaunchParams)) {
		$LaunchParams = "--doorstop-enable true --doorstop-target `"$env:APPDATA/Thunderstore Mod Manager/DataFolder/Valheim/profiles/$ThunderstoreMMProfileName/BepInEx/core/BepInEx.Preloader.dll`""
		$LaunchParams = $LaunchParams -replace '\\','/'
	}
	# Set folder location:
	$OrigDir = Get-Location
	Set-Location -Path (Split-Path -Path $ServerStartupScript -Parent)
	$TempLaunchFile = Join-Path -Path (Get-Location) -ChildPath "TEMP_DELETE_ME_LaunchValheimServer.bat"
	# Start server:
	Write-Host "Starting Valheim Server: `"$ThunderstoreMMProfileName`" $ServerStartupScript " -ForegroundColor Black -BackgroundColor Green
	# Startup method:
	#$Method = 0 # Brute force: Write the whole command to a batch file, and execute that file. This for sure prevents any funny business with extra quotes or variable expansion, and as a bonus leaves a .bat file that can be inspected and run independently for fine-tuned troubleshooting. But as a big downside, this method requires writing to disk unnecessarily. Mainly just for testing.
	#$Method = 1 # Start-Process: Generates a new cmd.exe process in new window.
	#
	#$argsString = "/K `"`"$ServerStartupScript`" $LaunchParams`""
	$argsString = "/C `"`"$ServerStartupScript`" $LaunchParams`""
	$Method = 1
	switch ($Method) {
		0 {
			$argsString = "/K `"`"$ServerStartupScript`" $LaunchParams`""
			If ([bool]$WhatIfPreference) {
				Write-Information "What If: Running $PSCommandPath ($($MyInvocation.MyCommand.Name)): Start-Process -FilePath $TempLaunchFile -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName"
				Write-Host "What If: Running $PSCommandPath ($($MyInvocation.MyCommand.Name)): Start-Process -FilePath $TempLaunchFile -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName" -BackgroundColor Black -ForegroundColor Gray
			}
			# # $PSCmdlet.ShouldProcess('TARGET')
			# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
			# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
			# What if: Performing the operation "OPERATION" on target "TARGET".
			# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
			# What if: MESSAGE
			If ($PSCmdlet.ShouldProcess('Start-Process -FilePath $TempLaunchFile -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName',"Start-Process -FilePath $TempLaunchFile -WorkingDirectory $(((Get-Item -Path $ServerStartupScript).Directory).FullName)")) {
				Remove-Item -Path $TempLaunchFile -Force -ErrorAction SilentlyContinue
				Start-Sleep -Milliseconds 200
				New-Item -Path $TempLaunchFile | Out-Null
				Set-Content -Path $TempLaunchFile -Value "cmd.exe $argsString"
				Start-Sleep -Milliseconds 200
				Start-Process -FilePath $TempLaunchFile -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName
			}
		}
		1 {
			If ([bool]$WhatIfPreference) {
				Write-Information "What If: Running $PSCommandPath ($($MyInvocation.MyCommand.Name)): Start-Process cmd.exe -ArgumentList $argsString -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName"
				Write-Host "What If: Running $PSCommandPath ($($MyInvocation.MyCommand.Name)): Start-Process cmd.exe -ArgumentList $argsString -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName" -BackgroundColor Black -ForegroundColor Gray
			}
			# # $PSCmdlet.ShouldProcess('TARGET')
			# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
			# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
			# What if: Performing the operation "OPERATION" on target "TARGET".
			# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
			# What if: MESSAGE
			If ($PSCmdlet.ShouldProcess('Start-Process cmd.exe -ArgumentList $argsString -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName',"Start-Process cmd.exe -ArgumentList $argsString -WorkingDirectory $(((Get-Item -Path $ServerStartupScript).Directory).FullName)")) {
				#$argsString = "/C `"`"$ServerStartupScript`" $LaunchParams`""
				Start-Process cmd.exe -ArgumentList $argsString -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName
				#Start-Process cmd.exe -ArgumentList "/K echo Hello World" -WorkingDirectory ((Get-Item -Path $ServerStartupScript).Directory).FullName
			}
		}
		Default {
			Write-Warning "No startup method detected: '$Method'"
			Write-Error "No startup method detected: '$Method'"
			Pause
		}
	}
	# Reset folder location
	Start-Sleep -Milliseconds 1000
	Set-Location -Path $OrigDir
} # / function Start-ValheimServer

function Register-ServerRestart {
	[CmdletBinding(
		SupportsShouldProcess,
		DefaultParameterSetName = 'MinuteMark'
	)]
	param (
		$ServerStartupScript = "D:\SteamLibrary\steamapps\common\Valheim dedicated server\start_headless_server.bat",
		$ProcessName = "valheim_server",
		$ThunderstoreMMProfileName = "wordpass_server_vanilla",
		
		[Parameter(Mandatory=$False)]
		$LaunchParams,
		[Parameter(Mandatory=$False)]
		$CronJobMobFile,
		
		# Set to $True if planning to keep the server offline for a little while
		[switch]$ShutDown,
		
		[Parameter(ParameterSetName = 'MinuteMark')]
		[ValidateRange(0,59)]
		[int]$MinuteMark,
		[Parameter(ParameterSetName = 'MinutesFromNow')]
		[int]$MinutesFromNow,
		[Parameter(ParameterSetName = 'DateTimeOnce')]
		[DateTime]$DateTimeOnce,
		[Parameter(ParameterSetName = 'DateTimeOnce',Mandatory=$False)]
		[TimeSpan]$RepeatInterval,
		[Parameter(ParameterSetName = 'DateTimeDaily')]
		[DateTime]$DateTimeDaily,
		[Parameter(ParameterSetName = 'DateTimeDaily',Mandatory=$False)]
		[Int32]$DaysInterval,
		
		[switch]$RunWithHighestPrivileges,
		[switch]$RunAsSystemServiceAccount,
		
		[int]$SecondsBuffer = 25,
		
		[string]$SchedTaskName = "Restart Server",
		[string]$SchedTaskPath = "Valheim Server"
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{ # These get activated when adding [CmdletBinding()] and param() to a script/function.
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	#[System.Management.Automation.ConfirmImpact]$ConfirmPreference = 'High' # ConfirmPreference var has 4 possible ConfirmImpact values: None, Low, Medium, or High (default).
	If ($ConfirmPreference -eq 'Low') {$Confirm = $True} Else {$Confirm = $False} # When calling a function with -Confirm, the value of $ConfirmPreference gets set to Low inside the scope of your function.
	$RiskMitigationParameters = @{ # These params -WhatIf and -Confirm get automatically added when adding [CmdletBinding(SupportsShouldProcess)] to a script/function.
		WhatIf = [bool]$WhatIfPreference
		Confirm = [bool]$Confirm
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# Finish setting up remaining parameters:
	If (!($LaunchParams)) {
		$LaunchParams = "--doorstop-enable true --doorstop-target `"$env:APPDATA/Thunderstore Mod Manager/DataFolder/Valheim/profiles/$ThunderstoreMMProfileName/BepInEx/core/BepInEx.Preloader.dll`""
		$LaunchParams = $LaunchParams -replace '\\','/'
	}
	If (!($CronJobMobFile)) {
		$CronJobMobFile = "$env:APPDATA\Thunderstore Mod Manager\DataFolder\Valheim\profiles\$ThunderstoreMMProfileName\BepInEx\config\cron.yaml"
	}
	
	#-----------------------------------------------------------------------------------------------------------------------
	
	# Scheduled Trigger:
	#$T = New-ScheduledTaskTrigger -Once [-RepetitionInterval <TimeSpan>] -At <DateTime>
	#$T = New-ScheduledTaskTrigger -Daily [-DaysInterval <Int32>] -At <DateTime>
	#$MiniTime = "$((Get-Date).Hour):$((Get-Date).Minute)"
	$MiniTimeNow = "$(Get-Date -UFormat '%I:%M %p / %R')"
	# %I 	Hour in 12-hour format 	05
	# %M 	Minutes 	35
	# %p 	AM or PM 	
	# %R 	Time in 24-hour format -no seconds 	17:45
	# %r 	Time in 12-hour format 	09:15:36 AM
	If ($MinuteMark -Or $MinuteMark -eq 0) {
		[string]$SchedTaskName = $SchedTaskName + "_MinMark"
		If ((Get-Date -Minute $MinuteMark) -le (Get-Date)) {
			#Write-Host "Next hour"
			$DateTimeOnce = (Get-Date -Minute $MinuteMark -Second 0) + (New-TimeSpan -Hours 1)
		} Else {
			$DateTimeOnce = Get-Date -Minute $MinuteMark -Second 0
		}
		$MiniTime = "$(Get-Date -Date $DateTimeOnce -UFormat '%I:%M %p / %R')"
		$DescripTypeRate = "at minute mark '$($MinuteMark)': $MiniTime, $DateTimeOnce"
		$T = New-ScheduledTaskTrigger -Once -At $DateTimeOnce
	} ElseIf ($MinutesFromNow) {
		[string]$SchedTaskName = $SchedTaskName + "_MinsFromNow"
		$DateTimeOnce = (Get-Date -Second 0) + (New-TimeSpan -Minutes $MinutesFromNow)
		$MiniTime = "$(Get-Date -Date $DateTimeOnce -UFormat '%I:%M %p / %R')"
		$DescripTypeRate = "$MinutesFromNow minutes from $($MiniTimeNow) at $($MiniTime): $DateTimeOnce"
		$T = New-ScheduledTaskTrigger -Once -At $DateTimeOnce
	} ElseIf ($DateTimeOnce) {
		$MiniTime = "$(Get-Date -Date $DateTimeOnce -Second 0 -UFormat '%I:%M %p / %R')"
		If ($RepeatInterval) {
			[string]$SchedTaskName = $SchedTaskName + "_OnceRepeat"
			$DescripTypeRate = "once every $($RepeatInterval.ToString()) starting at $MiniTime, $DateTimeOnce"
			$T = New-ScheduledTaskTrigger -Once -RepetitionInterval $RepeatInterval -At $DateTimeOnce
		} Else {
			[string]$SchedTaskName = $SchedTaskName + "_Once"
			$DescripTypeRate = "once at $MiniTime, $DateTimeOnce"
			$T = New-ScheduledTaskTrigger -Once -At $DateTimeOnce
		}
	} ElseIf ($DateTimeDaily) {
		$MiniTime = "$(Get-Date -Date $DateTimeDaily -Second 0 -UFormat '%I:%M %p / %R')"
		If ($DaysInterval) {
			[string]$SchedTaskName = $SchedTaskName + "_DaysRepeat"
			$DescripTypeRate = "every $DaysInterval days at $MiniTime, starting $DateTimeDaily"
			$T = New-ScheduledTaskTrigger -Daily -DaysInterval $DaysInterval -At $DateTimeDaily
		} Else {
			[string]$SchedTaskName = $SchedTaskName + "_Daily"
			$DescripTypeRate = "daily at $MiniTime, starting $DateTimeDaily"
			$T = New-ScheduledTaskTrigger -Daily -At $DateTimeDaily
		}
	} Else {
		Write-Warning "No Scheduled Task Trigger defined -MinuteMark, -MinutesFromNow, -DateTimeOnce, -DateTimeDaily"
	}
	$SchedDescription = "Reboot Valheim server $DescripTypeRate`nAuto-scheduled on: $(Get-Date)"
	
	# Scheduled Action:
	#$FilePath = "<filename>.ps1"
	$FilePath = $FunctionPath
	If ($ShutDown) {
		$ScriptArgs = "-RestartServer -SchedTaskName `"$SchedTaskName`" -SchedTaskPath `"$SchedTaskPath`" -ServerStartupScript `"$ServerStartupScript`" -SecondsBuffer $SecondsBuffer -ShutDown"
	} Else {
		$ScriptArgs = "-RestartServer -SchedTaskName `"$SchedTaskName`" -SchedTaskPath `"$SchedTaskPath`" -ServerStartupScript `"$ServerStartupScript`" -SecondsBuffer $SecondsBuffer"
	}
	If ($VerbosePreference -ne 'SilentlyContinue') {$ScriptArgs += " -Verbose"}
	If ($DebugPreference -ne 'SilentlyContinue') {$ScriptArgs += " -Debug"}
	If ([bool]$WhatIfPreference) {$ScriptArgs += " -WhatIf"}
	If ($Confirm) {$ScriptArgs += " -Confirm"}
	#$ScriptExecution = "Powershell.exe -file `"$FilePath`" $ScriptArgs"
	$ScriptExecution = "-NoLogo -ExecutionPolicy Bypass -NoProfile -NonInteractive -File `"$FilePath`" $ScriptArgs"
	#$A = New-ScheduledTaskAction Execute $ScriptExecution
	$A = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $ScriptExecution -WorkingDirectory $ScriptProjFolder
	
	#$P = "Contoso\Administrator"
	#$Env:UserName
	#$Env:UserDomain
	#$Env:ComputerName
	#$P = $Env:UserDomain + "\" + $Env:UserName
	If ($RunAsSystemServiceAccount) {
		#https://stackoverflow.com/questions/13965997/powershell-set-a-scheduled-task-to-run-when-user-isnt-logged-in
		$P = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
	} Else {
		If ($RunWithHighestPrivileges) {
			#https://stackoverflow.com/questions/13965997/powershell-set-a-scheduled-task-to-run-when-user-isnt-logged-in
			$P = New-ScheduledTaskPrincipal -UserId $Env:UserName -RunLevel Highest -LogonType Password 
			$UserCredential = Get-Credential -UserName $Env:UserName -Message "User password required for "
			$Password = $UserCredential.GetNetworkCredential().Password 
		} Else {
			$P = New-ScheduledTaskPrincipal -UserId $Env:UserName
		}
	}
	
	$S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility At
	
	# Check if task already exists:
	#$SchedTaskName = "Restart Server_MinMark"
	#$SchedTaskPath = "Valheim Server"
	If ((Get-ScheduledTask -TaskName "$SchedTaskName" -TaskPath "\$SchedTaskPath\" -ErrorAction SilentlyContinue)) {
		Write-Warning "Task already exists: `"$SchedTaskName`""
		Write-Host "Warning: Removing old task \$SchedTaskPath\$SchedTaskName" -BackgroundColor Black -ForegroundColor Red
		# # $PSCmdlet.ShouldProcess('TARGET')
		# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
		# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
		# What if: Performing the operation "OPERATION" on target "TARGET".
		# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
		# What if: MESSAGE
		If ($PSCmdlet.ShouldProcess("-TaskName `"$SchedTaskName`" -TaskPath `"\$SchedTaskPath\`"",'Unregister-ScheduledTask')) {
			#Unregister-ScheduledTask -TaskName "$SchedTaskName" -TaskPath "\$SchedTaskPath\" -Confirm:$false
		}
		Unregister-ScheduledTask -TaskName "$SchedTaskName" -TaskPath "\$SchedTaskPath\" -Confirm:$false
		#Unregister-ScheduledTask -TaskName "$SchedTaskName" -TaskPath "\$SchedTaskPath\" @RiskMitigationParameters
	}
	
	Write-Host "Scheduling new Task: `"$SchedTaskName`" folder: `"$SchedTaskPath`""
	#$A = New-ScheduledTaskAction Execute $ScriptExecution
	#$T = New-ScheduledTaskTrigger -AtLogon
	#$P = "Contoso\Administrator"
	#$S = New-ScheduledTaskSettingsSet
	#$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
	#Register-ScheduledTask -User $Env:UserName
	If ($RunAsSystemServiceAccount) {
		Write-Verbose "Scheduling as System Service Account"
		#Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S
		$CommandScript = {
			Write-Host "Hello World!"
			pause
		}
		
		$global:globSchedTaskName = $SchedTaskName
		$global:globSchedTaskPath = $SchedTaskPath
		$global:globSchedDescription = $SchedDescription
		$global:globA = $A
		$global:globP = $P
		$global:globT = $T
		$global:globS = $S
		$CommandScript = {
			Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S
			pause
		}
		$CommandScript = @"
Register-ScheduledTask -TaskName `"$SchedTaskName`" -TaskPath `"$SchedTaskPath`" -Description `"$SchedDescription`" -Action `"$A`" -Principal `"$P`" -Trigger `"$T`" -Settings `"$S`"
pause
"@
		###
		$CommandScript = {
			Register-ScheduledTask -TaskName $global:globSchedTaskName -TaskPath $global:globSchedTaskPath -Description $global:globSchedDescription -Action $global:globA -Principal $global:globP -Trigger $global:globT -Settings $global:globS
			#pause
		}
		
		# # $PSCmdlet.ShouldProcess('TARGET')
		# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
		# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
		# What if: Performing the operation "OPERATION" on target "TARGET".
		# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
		# What if: MESSAGE
		If ($PSCmdlet.ShouldProcess("-Verb RunAs -Wait -ArgumentList `"-Command $CommandScript`"",'Start-Process powershell.exe')) {
			#Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList "-Command $CommandScript"
		}
		Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList "-Command $CommandScript"
	} Else { # / If ($RunAsSystemServiceAccount) 
		If ($RunWithHighestPrivileges) {
			Write-Verbose "Scheduling task $SchedTaskName to run with highest privileges"
			If ($PSCmdlet.ShouldProcess("-TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Trigger $T -Settings $S -User $Env:UserName -Password $Password -RunLevel Highest",'Register-ScheduledTask')) {
				#Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Trigger $T -Settings $S -User $Env:UserName -Password $Password -RunLevel Highest
			}
			Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Trigger $T -Settings $S -User $Env:UserName -Password $Password -RunLevel Highest
		} Else {
			If ($PSCmdlet.ShouldProcess("-TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S ",'Register-ScheduledTask')) {
				#Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S 
			}
			Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S 
		}
	} # / If/Else ($RunAsSystemServiceAccount) 
	
	#-----------------------------------------------------------------------------------------------------------------------
	
	# Update cron file
	Write-Host "Updating cron file:"
	$global:CronJobMobFileOrig = $CronJobMobFile + ".orig"
	Write-Host "Backing up current cron file: $CronJobMobFileOrig"
	# # $PSCmdlet.ShouldProcess('TARGET')
	# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
	# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
	# What if: Performing the operation "OPERATION" on target "TARGET".
	# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
	# What if: MESSAGE
	If ($PSCmdlet.ShouldProcess("-Path $CronJobMobFile -Destination $CronJobMobFileOrig",'Copy-Item')) {
		Copy-Item -Path $CronJobMobFile -Destination $CronJobMobFileOrig
	}
	
	If ($DateTimeOnce) {
		[DateTime]$RestartDateTime = $DateTimeOnce
	} ElseIf ($DateTimeDaily) {
		[DateTime]$RestartDateTime = $DateTimeDaily
	}
	$30MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 30)
	$20MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 20)
	$10MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 10)
	$5MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 5)
	$4MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 4)
	$3MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 3)
	$2MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 2)
	$1MinsOut = $RestartDateTime - (New-TimeSpan -Minutes 1)
	
	function Convert-TimeZones {
		<#
		.LINK
		https://craigforrester.com/posts/convert-times-between-time-zones-with-powershell/
		#>
		[CmdletBinding(DefaultParameterSetName='ToUTC')]
		param (
			[Parameter()]
			[DateTime]$InDateTime,
			
			[Parameter(ParameterSetName='ToUTC')]
			[Switch]$UTC,
			
			[Parameter(ParameterSetName='FromToTZ',Mandatory=$False)]
			[String]$FromTZ,
			[Parameter(ParameterSetName='FromToTZ',Mandatory=$True)]
			[String]$ToTZ
		)
		
		If ($UTC) {
			# Convert to UTC:
			[DateTime]$InDateTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date -Date $InDateTime), 'Greenwich Standard Time')
		} Else {
			# Assign India time zone info to a variable
			#$intz = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -match "India Standard" }
			
			# Assign Eastern Australia time zone info to a variable
			#$autz = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -match "AUS Eastern" }
			
			If ($FromTZ) {
				$FromTZ = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -match "$FromTZ" }
			} Else {
				$FromTZ = ""
			}
			
			$ToTZ = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -match "$ToTZ" }
			
			$time_to_convert = ((Get-Date -Date $InDateTime).ToString('yyyy-MM-ddTHH:mm:ss'))
			
			#[System.TimeZoneInfo]::ConvertTime($time_to_convert, $intz, $autz)
			[DateTime]$InDateTime = [System.TimeZoneInfo]::ConvertTime($time_to_convert, $FromTZ, $ToTZ)
		}
		Return $InDateTime
	} # / function Convert-TimeZones 
	
	function ConvertTo-CronString {
		[CmdletBinding()]
		param (
			[DateTime]$InDateTime
		)
		# Convert to UTC:
		#[DateTime]$InDateTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date -Date $InDateTime), 'Greenwich Standard Time')
		#https://craigforrester.com/posts/convert-times-between-time-zones-with-powershell/
		[DateTime]$InDateTime = Convert-TimeZones -InDateTime $InDateTime -UTC
		
		# Cron schedule format:
		#https://crontab.guru/
		# minute - hour - day(month) - month - day(week)
		# schedule: 55 * * * *
		#[String]$CronString = $InDateTime.Minute + " " + $InDateTime.Hour + " " + $InDateTime.Day + " " + $InDateTime.Month + [string]' *'
		[String]$CronString = "$($InDateTime.Minute) $($InDateTime.Hour) $($InDateTime.Day) $($InDateTime.Month) *"
		
		Return $CronString
	} # / function ConvertTo-CronString 
	
	$30MinsCron = ConvertTo-CronString -InDateTime $30MinsOut
	$20MinsCron = ConvertTo-CronString -InDateTime $20MinsOut
	$10MinsCron = ConvertTo-CronString -InDateTime $10MinsOut
	$5MinsCron = ConvertTo-CronString -InDateTime $5MinsOut
	$4MinsCron = ConvertTo-CronString -InDateTime $4MinsOut
	$3MinsCron = ConvertTo-CronString -InDateTime $3MinsOut
	$2MinsCron = ConvertTo-CronString -InDateTime $2MinsOut
	$1MinsCron = ConvertTo-CronString -InDateTime $1MinsOut
	
	###
	$CronJobsShutdown = @"

  - command: broadcast center Server will shutdown for maintenance in 10 minutes
    schedule: $10MinsCron
  - command: save
    schedule: $5MinsCron
  - command: broadcast center Server will shutdown for maintenance in 5 minutes
    schedule: $5MinsCron
  - command: broadcast center Server will shutdown for maintenance in 4 minutes
    schedule: $4MinsCron
  - command: broadcast center Server will shutdown for maintenance in 3 minutes
    schedule: $3MinsCron
  - command: broadcast center Server will shutdown for maintenance in 2 minutes - Saving world
    schedule: $2MinsCron
  - command: save
    schedule: $2MinsCron
  - command: broadcast center Server will shutdown for maintenance in 1 minute - Please log out
    schedule: $1MinsCron
"@
	###
	###
	$CronJobsRestart = @"

  - command: save
    schedule: $5MinsCron
  - command: broadcast center Server will reboot in 5 minutes
    schedule: $5MinsCron
  - command: broadcast center Server will reboot in 4 minutes
    schedule: $4MinsCron
  - command: broadcast center Server will reboot in 3 minutes
    schedule: $3MinsCron
  - command: broadcast center Server will reboot in 2 minutes - Saving world
    schedule: $2MinsCron
  - command: save
    schedule: $2MinsCron
  - command: broadcast center Server will reboot in 1 minute - Please log out
    schedule: $1MinsCron
"@
	###
	If ($ShutDown) {
		$CronJobs = $CronJobsShutdown
	} Else {
		$CronJobs = $CronJobsRestart
	}
	#$CronJobs = "`n$CronJobs"
	
	$CronZones = "[]"
	
	###
	$CronJoin = @"

  - command: save
  - command: say Hello `$`$name, the server will be restarting shortly.
"@
	###
	#$CronJoin = "`n$CronJoin"
	###
	$CronJoin = @"

  - command: save
  - command: say Welcome `$`$name!
"@
	###
	#$CronJoin = "`n$CronJoin"
	#$CronJoin = "[]"
	
	###
	$CronTemplate = @"
timezone: UTC
interval: 10
jobs: $CronJobs
zone: $CronZones
join: $CronJoin
logJobs: true
logZone: true
logJoin: true
discordConnector: true
"@
	###
	
	Write-Host "Writing cron file content: $CronJobMobFile"
	If ($PSCmdlet.ShouldProcess("-Path $CronJobMobFile -Value $CronTemplate",'Set-Content')) {
		Set-Content -Path $CronJobMobFile -Value $CronTemplate
	}
	
	#-----------------------------------------------------------------------------------------------------------------------
	
	Return
} # / function Register-ServerRestart

function Restart-ValheimServer {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		$ServerStartupScript = "D:\SteamLibrary\steamapps\common\Valheim dedicated server\start_headless_server.bat",
		$ProcessName = "valheim_server",
		$ThunderstoreMMProfileName = "wordpass_server_vanilla",
		
		[Parameter(Mandatory=$False)]
		$LaunchParams,
		[Parameter(Mandatory=$False)]
		$CronJobMobFile,
		
		# Set to $True if planning to keep the server offline for a little while
		[switch]$ShutDown,
		
		[string]$SchedTaskName = "Restart Server",
		[string]$SchedTaskPath = "Valheim Server",
		
		[int]$SecondsBuffer = 25
		
		# Risk mitigation parameters, used for testing and troubleshooting:
		#[switch]$WhatIf, # Set as $True to turn on, $False or leave null to turn off.
		#[switch]$Confirm # Set as $True to turn on, $False or leave null to turn off.
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{ # These get activated when adding [CmdletBinding()] and param() to a script/function.
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	#[System.Management.Automation.ConfirmImpact]$ConfirmPreference = 'High' # ConfirmPreference var has 4 possible ConfirmImpact values: None, Low, Medium, or High (default).
	If ($ConfirmPreference -eq 'Low') {$Confirm = $True} Else {$Confirm = $False} # When calling a function with -Confirm, the value of $ConfirmPreference gets set to Low inside the scope of your function.
	$RiskMitigationParameters = @{ # These params -WhatIf and -Confirm get automatically added when adding [CmdletBinding(SupportsShouldProcess)] to a script/function.
		WhatIf = [bool]$WhatIfPreference
		Confirm = [bool]$Confirm
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# Finish setting up remaining parameters:
	If (!($LaunchParams)) {
		$LaunchParams = "--doorstop-enable true --doorstop-target `"$env:APPDATA/Thunderstore Mod Manager/DataFolder/Valheim/profiles/$ThunderstoreMMProfileName/BepInEx/core/BepInEx.Preloader.dll`""
		$LaunchParams = $LaunchParams -replace '\\','/'
	}
	If (!($CronJobMobFile)) {
		$CronJobMobFile = "$env:APPDATA\Thunderstore Mod Manager\DataFolder\Valheim\profiles\$ThunderstoreMMProfileName\BepInEx\config\cron.yaml"
	}
	
	# Shut down server:
	Write-Host "Stopping server:"
	# # $PSCmdlet.ShouldProcess('TARGET')
	# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
	# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
	# What if: Performing the operation "OPERATION" on target "TARGET".
	# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
	# What if: MESSAGE
	If ($PSCmdlet.ShouldProcess("-ProcessName $ProcessName $($CommonParameters)",'Stop-ValheimServer')) {
		#Stop-ValheimServer -ProcessName $ProcessName @CommonParameters # @RiskMitigationParameters
	}
	Stop-ValheimServer -ProcessName $ProcessName @CommonParameters @RiskMitigationParameters
	# Starting shutdown wait buffer
	#$SecondsBuffer = 15
	$Title = "Waiting $SecondsBuffer seconds for Valheim server to cleanly shut down ..."
	Write-Host $Title
	[int]$Steps = $SecondsBuffer
	[int]$StepNumber = 0
	$Message = "0% -- ($StepNumber / $Steps)"
	Write-Progress -Activity $Title -Status $Message -PercentComplete (($StepNumber / $Steps) * 100)
	# Executing wait buffer
	for ($i = $StepNumber; $i -lt $Steps; $i++) {
		$ShowPercent = ($i / $Steps) * 100
		$Message = "$([int]$ShowPercent)% -- ($i / $Steps)"
		$SecondsRemaining = $Steps - $i
		Write-Progress -Activity $Title -Status $Message -PercentComplete $ShowPercent -SecondsRemaining $SecondsRemaining
		Start-Sleep -Seconds 1
	}
	# Ending wait buffer
	Write-Progress -Activity $Title -Status $Message -PercentComplete 100 -Completed
	
	# Remove scheduled task
	Write-Host "Removing scheduled task: $SchedTaskName"
	If ((Get-ScheduledTask -TaskName "$SchedTaskName" -TaskPath "\$SchedTaskPath\" -ErrorAction SilentlyContinue)) {
		# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
		# What if: Performing the operation "OPERATION" on target "TARGET".
		If ($PSCmdlet.ShouldProcess("-TaskName `"$SchedTaskName`" -TaskPath `"\$SchedTaskPath\`"",'Unregister-ScheduledTask')) {
			Unregister-ScheduledTask -TaskName "$SchedTaskName" -TaskPath "\$SchedTaskPath\" -Confirm:$false
		}
		#Unregister-ScheduledTask -TaskName "$SchedTaskName" -TaskPath "\$SchedTaskPath\" -Confirm:$false
	} Else {
		Write-Warning "Task does not exist: `"$SchedTaskName`""
		Write-Host "Nothing to remove, task did not exist: \$SchedTaskPath\$SchedTaskName" -BackgroundColor Black -ForegroundColor Red
	}
	
	# Reset cron file
	Write-Host "Reseting cron file:"
	try {
		Get-Variable -Name CronJobMobFileOrig -Scope global -ErrorAction Stop
	}
	catch {
		$global:CronJobMobFileOrig = $CronJobMobFile + ".orig"
	}
	# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
	# What if: Performing the operation "OPERATION" on target "TARGET".
	If ($PSCmdlet.ShouldProcess("-Path $global:CronJobMobFileOrig -Destination $CronJobMobFile -Force",'Copy-Item')) {
		Copy-Item -Path $global:CronJobMobFileOrig -Destination $CronJobMobFile -Force
	}
	# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
	# What if: Performing the operation "OPERATION" on target "TARGET".
	If ($PSCmdlet.ShouldProcess("-Path $global:CronJobMobFileOrig",'Remove-Item')) {
		Remove-Item -Path $global:CronJobMobFileOrig
	}
	
	# Start-up server
	If (($ShutDown)) {
		Write-Host "Shutting down server."
	} Else {
		Write-Host "Restarting server:"
		If ($LaunchParams) {
			# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
			# What if: Performing the operation "OPERATION" on target "TARGET".
			If ($PSCmdlet.ShouldProcess("-ServerStartupScript $ServerStartupScript -ThunderstoreMMProfileName $ThunderstoreMMProfileName -LaunchParams $LaunchParams",'Start-ValheimServer')) {
				#Start-ValheimServer -ServerStartupScript $ServerStartupScript -ThunderstoreMMProfileName $ThunderstoreMMProfileName -LaunchParams $LaunchParams @CommonParameters @RiskMitigationParameters
			}
			Start-ValheimServer -ServerStartupScript $ServerStartupScript -ThunderstoreMMProfileName $ThunderstoreMMProfileName -LaunchParams $LaunchParams @CommonParameters @RiskMitigationParameters
		} Else {
			# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
			# What if: Performing the operation "OPERATION" on target "TARGET".
			If ($PSCmdlet.ShouldProcess("-ServerStartupScript $ServerStartupScript -ThunderstoreMMProfileName $ThunderstoreMMProfileName",'Start-ValheimServer')) {
				#Start-ValheimServer -ServerStartupScript $ServerStartupScript -ThunderstoreMMProfileName $ThunderstoreMMProfileName @CommonParameters @RiskMitigationParameters
			}
			Start-ValheimServer -ServerStartupScript $ServerStartupScript -ThunderstoreMMProfileName $ThunderstoreMMProfileName @CommonParameters @RiskMitigationParameters
		}
	}
	
	Return
} # / function Restart-ValheimServer

Write-Verbose -Message "[$FunctionName]: End loading Functions"
# [/Functions]----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

$newSampleModuleParameters = @{
    DestinationPath   = 'C:\Users\G\Documents\GitHub\SleepTimerTest'
    ModuleType        = 'CompleteSample'
    ModuleName        = 'SleepTimerTest'
    ModuleAuthor      = 'My Name'
    ModuleDescription = 'MyCompleteSample Description'
}

$newSampleModuleParameters = @{
    DestinationPath   = 'C:\Users\G\Documents\GitHub\SleepTimerTest'
    ModuleType        = 'SimpleModule'
    ModuleName        = 'SleepTimerPoSh'
    ModuleAuthor      = 'Kerbalnut'
    ModuleDescription = "PowerShell module for Sleep Timer functions to change computer's power state to sleep/hibernate/shutdown/restart"
}

#New-SampleModule @newSampleModuleParameters




#Set-PowerState -Action Sleep @CommonParameters #@RiskMitigationParameters
#Set-PowerState -Action Sleep @CommonParameters -WhatIf #@RiskMitigationParameters
#-WhatIf 
#return
#exit


#powershell.exe -File "C:\Users\G\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\Start-SleepTimer.ps1"


#$ScriptExecution = "Powershell.exe -file `"$FilePath`" $ScriptArgs"
#$ScriptExecution = "-NoLogo -ExecutionPolicy Bypass -NoProfile -NonInteractive -File `"$FilePath`" $ScriptArgs"
#$A = New-ScheduledTaskAction Execute $ScriptExecution
#$A = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument $ScriptExecution -WorkingDirectory $ScriptProjFolder




#-----------------------------------------------------------------------------------------------------------------------
# [Main:]---------------------------------------------------------------------------------------------------------------
Write-Verbose -Message "[$FunctionName]: Starting main script logic"

If ($SetPower) {
	Write-Verbose -Message "[$FunctionName]: Activating Power state command"
	$PowerStateParams = @{
		DisableWake = $DisableWake
		Force = $Force
	}
	Set-PowerState -Action $Action @PowerStateParams @CommonParameters @RiskMitigationParameters
}


Write-Verbose -Message "[$FunctionName]: End of script file."
# [/Main]---------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------


