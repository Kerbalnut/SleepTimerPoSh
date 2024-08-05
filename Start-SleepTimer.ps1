
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
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Risk mitigation parameters:
#[System.Management.Automation.ConfirmImpact]$ConfirmPreference = 'High' # ConfirmPreference var has 4 possible ConfirmImpact values: None, Low, Medium, or High (default).
If ($ConfirmPreference -eq 'Low') {$Confirm = $True} Else {$Confirm = $False} # When calling a function with -Confirm, the value of $ConfirmPreference gets set to Low inside the scope of your function.
$RiskMitigationParameters = @{ # These params -WhatIf and -Confirm get automatically added when adding [CmdletBinding(SupportsShouldProcess)] to a script/function.
	WhatIf = [bool]$WhatIfPreference
	Confirm = [bool]$Confirm
}
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Get this script's path:
#$ScriptFolder = $PSScriptRoot
#$ScriptPath = $PSCommandPath
$ScriptPath = $MyInvocation.MyCommand.Definition
$ScriptName = $MyInvocation.MyCommand.Name
Write-Verbose -Message "[$ScriptName]: Starting script `"$ScriptPath`""
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#-----------------------------------------------------------------------------------------------------------------------
# [Functions:]----------------------------------------------------------------------------------------------------------
Write-Verbose -Message "[$ScriptName]: Loading Functions"

#-----------------------------------------------------------------------------------------------------------------------
Function Set-PowerState {
	<#
	.SYNOPSIS
	Instantly changes the power state of local computer to sleep, hibernate, restart, shutdown, logoff, or lock
	.DESCRIPTION
	By default will put the current PC to sleep. Will execute immediately. For timed operations see Start-SleepTimer instead.
	
	Use -WhatIf switch to see what would happen without changing power state.
	.PARAMETER DisableWake
	Only applies to Sleep and Hibernate actions.
	
	From the original StackOverflow answer:
	https://stackoverflow.com/questions/20713782/suspend-or-hibernate-from-powershell
	Note: In my testing, the -DisableWake option did not make any distinguishable difference that I am aware of. I was still capable of using the keyboard and mouse to wake the computer, even when this parameter was set to $True.
	
	About disableWakeEvent... This parameter can prevent SetWaitableTimer() to awake the computer. SetWaitableTimer() used by Task Scheduler (at least). See details here: msdn.microsoft.com/en-us/library/windows/desktop/aa373235.aspx – CoolCmd
	
	From:
	https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.application.setsuspendstate?view=windowsdesktop-7.0&redirectedfrom=MSDN#System_Windows_Forms_Application_SetSuspendState_System_Windows_Forms_PowerState_System_Boolean_System_Boolean_
	
	disableWakeEvent    Boolean 
	`true` to disable restoring the system's power status to active on a wake event, `false` to enable restoring the system's power status to active on a wake event.
	.PARAMETER Action
	Pick which power state to put the computer into. Default is 'sleep'. Some states have multiple aliases.
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Value:                      Description: 
	------                      ----------------------------------------------------------------- 
	Sleep / Suspend / Standby   Puts computer in a low power state. Resumes the fastest but computer
	                            will still draw a little power. Power loss in this state will cause
	                            data loss/corruption.
	Hibernate                   Saves current work to disk (HDD/SSD), and turns off computer.
	                            Computer will draw no power and all applications and system
	                            state will resume as loaded when powered back on.
	Reboot / Restart            Restarts the computer. All applications will be closed. Computer
	                            will go through entire BIOS/POST/boot process again. This may 
	                            also trigger any pending OS updates.
	Shutdown / Stop             Shuts down computer completely. If 'Fast Boot'/'Fast Startup' feature
	                            on Win 8 and up is enabled, not all OS and application data will be
	                            reset, and computer will enter a hybrid shutdown/hibernate state by
	                            signing-out user account and saving remaining data to hiberfil.sys.
	                            This can improve boot times but will not always provide clean reset
	                            of system state, use restart/reboot option for that instead. Or 
	                            disable the 'Fast Boot'/'Fast Startup' feature.
	Lock                        Keeps all applications running and locks computer. User password /
	                            authentication will be required to log back into account. If Win 10
	                            'Fast User Switching' is not enabled other users will not be able
	                            to log in when computer is locked in this state. See "SwitchUser"
	LogOut / SignOut / LogOff   Current user profile will be signed out. All applications will be
	 / SignOff                  closed.
	SwitchUser                  Work In Progress
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.PARAMETER Force
	.PARAMETER WhatIf
	When this switch is enabled the power state will not be changed. The action that would've been performed is printed to console instead.
	.EXAMPLE
	Set-PowerState -Action Sleep
	
	Puts computer to sleep immediately. Computer will draw a little power, but will resume with applications loaded faster than Hibernation. Data loss/corruption can occur if power is lost in this state.
	.EXAMPLE
	Set-PowerState -Action Hibernate -DisableWake -Force
	
	Puts computer into hibernation. Data will be saved to disk (HDD/SSD) hiberfil.sys and power will be shut off. When powered back on data will be loaded from hiberfil.sys back into RAM memory and applications will resume in same state.
	.NOTES
	Changelog:
	v1.1.0 - Added Shutdown, Restart, and LogOff options using shutdown.exe and Lock option using rundll32.exe user32.dll,LockWorkStation
	v1.0.0 - Created function with switches for Sleep (default), Hibernate, DisableWake, and Force using [System.Windows.Forms.PowerState].
	
	References:
	https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.powerstate?view=windowsdesktop-7.0
	
	Hibernate 	1 	
	Indicates a system hibernation power mode. When a system enters hibernation, the contents of its memory are saved to disk before the computer is turned off. When the system is restarted, the desktop and previously active programs are restored.
	
	Suspend 	0 	
	Indicates a system suspended power mode. When a system is suspended, the computer switches to a low-power state called standby. When a computer is in standby mode, some devices are turned off and the computer uses less power. The system can restore itself more quickly than returning from hibernation. Because standby does not save the memory state to disk, a power failure while in standby can cause loss of information.
	
	https://superuser.com/questions/463646/is-there-a-command-line-tool-to-put-windows-8-to-sleep/463652#463652
	
	Shutdown:
	%windir%\System32\shutdown.exe -s
	
	Reboot:
	%windir%\System32\shutdown.exe -r
	
	Logoff:
	%windir%\System32\shutdown.exe -l
	
	Standby (disable hibernation, execute the standby command, then re-enable hibernation after 2 seconds):
	powercfg -hibernate off  &&  start /min "" %windir%\System32\rundll32.exe powrprof.dll,SetSuspendState Standby  &&  ping -n 3 127.0.0.1  &&  powercfg -hibernate on
	
	Sleep (same method as STANDBY, but this command):
	%windir%\System32\rundll32.exe powrprof.dll,SetSuspendState 0,1,0
	
	Hibernate:
	%windir%\System32\rundll32.exe powrprof.dll,SetSuspendState Hibernate
	
	https://answers.microsoft.com/en-us/windows/forum/all/how-to-switch-user-at-locked-screen-in-windows-10/6288fc46-6731-4b94-be2b-9aae068aeb58
	Windows 10: Enable or Disable Fast User Switching
	http://www.technipages.com/windows-10-enable-or-disable-fast-user-switching
	
	Option 1 – Group Policy [This worked for me]
	
	Hold the Windows Key and press "R" to bring up the Run dialog box.
	Type "gpedit.msc" then press "Enter".
	The Local Group Policy Editor appears. Expand the following:
	Local Computer Policy
	Computer Configuration
	Administrative Templates
	System
	Logon
	
	Open "Hide Entry Points for Fast User Switching".
	Select "Enabled" to turn Fast User Switching off. Set it to "Disable" to turn it on.
	
	Option 2 – Registry
	
	Hold the Windows Key and press "R" to bring up the Run dialog box.
	Type "regedit" then press "Enter".
	Expand the following:
	HKEY_LOCAL_MACHINE
	SOFTWARE
	Microsoft
	Windows
	CurrentVersion
	Policies
	System
	Look for a value called "HideFastUserSwitching". If it does not exist, right-click the "System" folder, select "New DWORD 32-bit value", then type a name of "HideFastUserSwitching". Press "Enter" to create the value.
	Double-click "HideFastUserSwitching". Change the "Value data" to "1" to disable Fast User Switching, set it to "0" to enable it.
	.LINK
	https://stackoverflow.com/questions/20713782/suspend-or-hibernate-from-powershell
	.LINK
	https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.application.setsuspendstate?redirectedfrom=MSDN&view=windowsdesktop-6.0#System_Windows_Forms_Application_SetSuspendState_System_Windows_Forms_PowerState_System_Boolean_System_Boolean_
	.LINK
	https://superuser.com/questions/463646/is-there-a-command-line-tool-to-put-windows-8-to-sleep/463652#463652
	#>
	[CmdletBinding(
		DefaultParameterSetName = 'StringName',
		SupportsShouldProcess = $True
	)]
	Param(
		[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'StringName')]
		[ValidateSet('Sleep','Suspend','Standby','Hibernate','Lock','Reboot','Restart','Shutdown','Stop','LogOut','SignOut','LogOff','SignOff')]
		[Alias('PowerAction')]
		[String]$Action = 'Sleep',
		
		#[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'PowerState')]
		#[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Suspend,
		
		[Switch]$DisableWake,
		[Switch]$Force
	) # End Param
	Begin {
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		$CommonParameters = @{ # These get activated when adding [CmdletBinding()] and param() to a script/function.
			Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
			Debug = [System.Management.Automation.ActionPreference]$DebugPreference
		}
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# Risk mitigation parameters:
		#[System.Management.Automation.ConfirmImpact]$ConfirmPreference = 'High' # ConfirmPreference var has 4 possible ConfirmImpact values: None, Low, Medium, or High (default).
		If ($ConfirmPreference -eq 'Low') {$Confirm = $True} Else {$Confirm = $False} # When calling a function with -Confirm, the value of $ConfirmPreference gets set to Low inside the scope of your function.
		$RiskMitigationParameters = @{ # These params -WhatIf and -Confirm get automatically added when adding [CmdletBinding(SupportsShouldProcess)] to a script/function.
			WhatIf = [bool]$WhatIfPreference
			Confirm = [bool]$Confirm
		}
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# Get this function's path:
		$FunctionPath = $PSCommandPath
		#$FunctionContent = $MyInvocation.MyCommand.Definition
		$FunctionName = $MyInvocation.MyCommand.Name
		#$FunctionName = $MyInvocation.MyCommand
		Write-Verbose -Message "[$FunctionName]: Starting function `"$FunctionPath`""
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Executing Begin block"
		
		If (!$DisableWake -or $null -eq $DisableWake -or $DisableWake -eq '') { $DisableWake = $false }
		If (!$Force -or $null -eq $Force -or $Force -eq '') { $Force = $false }
		
		#Write-Verbose -Message ('Force is: {0}' -f $Force)
		#Write-Verbose -Message ('DisableWake is: {0}' -f $DisableWake)
		Write-Verbose "[$FunctionName]: Force is: '$Force'"
		Write-Verbose "[$FunctionName]: DisableWake is: '$DisableWake'"
		Write-Verbose "[$FunctionName]: Power Action: '$Action'"
		
		Add-Type -AssemblyName System.Windows.Forms
		
		If ($Action -eq 'Sleep' -Or $Action -eq 'Suspend' -Or $Action -eq 'Standby') {
			[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Suspend
			$PowerString = "Sleep"
		}
		If ($Action -eq 'Hibernate') {
			[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Hibernate
			$PowerString = "Hibernate"
		}
		If ($Action -eq 'Lock') {
			$PowerString = "Lock"
		}
		If ($Action -eq 'Reboot' -or $Action -eq 'Restart') {
			$PowerString = "Reboot"
		}
		If ($Action -eq 'Shutdown' -or $Action -eq 'Stop') {
			$PowerString = "Shutdown"
		}
		If ($Action -eq 'LogOut' -or $Action -eq 'SignOut' -or $Action -eq 'LogOff' -or $Action -eq 'SignOff') {
			$PowerString = "LogOff"
		}
		
		Write-Verbose "[$FunctionName]: PowerString: `'$PowerString`'"
		Write-Verbose "[$FunctionName]: PowerState: `'$PowerState`'"
		Write-Verbose "[$FunctionName]: End Begin block"
	} # End Begin
	Process {
		Write-Verbose -Message "[$FunctionName]: Executing Process block"
		<#
		# ShouldProcess Message formats:
		# # $PSCmdlet.ShouldProcess('TARGET')
		# What if: Performing the operation "FUNCTION_NAME" on target "TARGET".
		# ## $PSCmdlet.ShouldProcess('TARGET','OPERATION')
		# What if: Performing the operation "OPERATION" on target "TARGET".
		# ## $PSCmdlet.ShouldProcess('MESSAGE','TARGET','OPERATION')
		# What if: MESSAGE
		#>
		#If ($PSCmdlet.ShouldProcess('TARGET','OPERATION')){
		#If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME' ; [System.Windows.Forms.Application]","SetSuspendState($PowerState ($Action), Force=$Force, DisableWake=$DisableWake)")) {
		[int]$Method = 0
		If ($PowerString -eq "Sleep" -or $PowerString -eq "Hibernate") {
			[int]$Method = 0
		}
		If ($PowerString -eq "Reboot" -or $PowerString -eq "Shutdown" -or $PowerString -eq "LogOff") {
			[int]$Method = 1
		}
		If ($PowerString -eq "Lock") {
			[int]$Method = 2
		}
		switch ($Method) {
			0 { # [System.Windows.Forms.Application]::SetSuspendState()
				If ($PowerString -eq "Sleep" -or $PowerString -eq "Hibernate") {
					If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME' ; [System.Windows.Forms.Application]","SetSuspendState($PowerState ($Action), Force=$Force, DisableWake=$DisableWake)")) {
						Try {
							$Result = [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake)
						} Catch {
							Write-Error -Exception $_
							Write-Error "[$FunctionName]: Changing power state failed using method '$Method': [System.Windows.Forms.Application]::SetSuspendState(PowerState='$PowerState', Force='$Force', DisableWake='$DisableWake')"
						}
					}
				} Else {
					Write-Error "[$FunctionName]: Wrong method '$Method' selected for power state '$PowerString' command: 'f$PowerState'"
				}
			}
			1 { # shutdown.exe
				<#
				Shutdown:
				%windir%\System32\shutdown.exe -s
				Reboot:
				%windir%\System32\shutdown.exe -r
				Logoff:
				%windir%\System32\shutdown.exe -l
				#>
				If ($PowerString -eq "LogOff") {
					#If ($PSCmdlet.ShouldProcess('TARGET','OPERATION')){
					If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME' ; shutdown -l","& `"$env:windir\System32\shutdown.exe`" /l")) {
						& "$env:windir\System32\shutdown.exe" /l
					}
				} ElseIf ($PowerString -eq "Reboot") {
					If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME' ; shutdown -r","& `"$env:windir\System32\shutdown.exe`" /r /t 0")) {
						& "$env:windir\System32\shutdown.exe" /r /t 0
					}
				} ElseIf ($PowerString -eq "Shutdown") {
					If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME' ; shutdown -s","& `"$env:windir\System32\shutdown.exe`" /s /t 0")) {
						& "$env:windir\System32\shutdown.exe" /s /t 0
					}
				} Else {
					Write-Error "[$FunctionName]: Wrong method '$Method' selected for power state '$PowerString' command."
				}
			}
			2 {
				#If ($PSCmdlet.ShouldProcess('TARGET','OPERATION')){
				If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME' ; rundll32.exe user32.dll,LockWorkStation","& 'rundll32.exe' user32.dll,LockWorkStation")) {
					#rundll32.exe user32.dll,LockWorkStation
					& 'rundll32.exe' user32.dll,LockWorkStation
				}
			}
			3 {
				If ($PowerString -eq "Reboot") {
					#If ($PSCmdlet.ShouldProcess('TARGET','OPERATION')){
					If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME'","Restart-Computer")) {
						Restart-Computer
						#Restart-Computer -Force
					}
				} ElseIf ($PowerString -eq "Shutdown") {
					If ($PSCmdlet.ShouldProcess("'$env:COMPUTERNAME'","Stop-Computer")) {
						Stop-Computer
					}
				} Else {
					Write-Error "[$FunctionName]: Wrong method '$Method' selected for power state '$PowerString' command."
				}
			}
			4 {
				
				#'powercfg -hibernate off  &&  start /min "" %windir%\System32\rundll32.exe powrprof.dll,SetSuspendState Standby  &&  ping -n 3 127.0.0.1  &&  powercfg -hibernate on'
				& 'powercfg' -hibernate off # Requires admin elevation
				$PowerString = "Sleep"
				$Result = [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake)
				Start-Sleep -Milliseconds 500
				& 'powercfg' -hibernate on # Requires admin elevation
				
			}
			Default {
				Throw "[$FunctionName]: Error selecting power state change method. Should be integer between 0-2 = '$Method'"
			}
		} # End / switch ($Method)
		
		Write-Verbose -Message "[$FunctionName]: Completed Process block"
	} # End Process
	End {
		Write-Verbose -Message "[$FunctionName]: Executing End block"
		Return $Result
	} # End End block
} # End Function Set-PowerState
#-----------------------------------------------------------------------------------------------------------------------
#Set-PowerState -Action Sleep @CommonParameters #@RiskMitigationParameters
Set-PowerState -Action Sleep @CommonParameters -WhatIf #@RiskMitigationParameters
#Set-PowerState -Action Hibernate @CommonParameters #-WhatIf #@RiskMitigationParameters
#return

#-----------------------------------------------------------------------------------------------------------------------
Function Format-ShortTimeString {
	<#
	.SYNOPSIS
	Formats a seconds input value into a short human-readable string
	.DESCRIPTION
	Converts any seconds value into short-form time string. By default prefers very short strings, seconds will be omitted unless total time value is under 1 hour. This can be made even shorter or longer using switches such as -Round or -ExactTime.
	.PARAMETER Seconds
	Required input Integer value representing total seconds value.
	.PARAMETER Round
	Omits seconds from output string, if input is over 60 seconds. Be default seconds are only omitted if value is less than 60 minutes.
	.PARAMETER ExactTime
	Always shows seconds value in output string.
	.EXAMPLE
	Format-ShortTimeString -Seconds 59
	Format-ShortTimeString -Seconds 60
	Format-ShortTimeString -Seconds 61
	Format-ShortTimeString -Seconds 299
	Format-ShortTimeString -Seconds 61 -Round
	Format-ShortTimeString -Seconds 299 -Round
	Format-ShortTimeString -Seconds 3600
	Format-ShortTimeString -Seconds 5400
	Format-ShortTimeString -Seconds 7200
	Format-ShortTimeString -Seconds 86399
	Format-ShortTimeString -Seconds 86400
	Format-ShortTimeString -Seconds 86401
	Format-ShortTimeString -Seconds 88200
	Format-ShortTimeString -Seconds 90000
	Format-ShortTimeString -Seconds 91800
	Format-ShortTimeString -Seconds 93600
	
	Format-ShortTimeString -Seconds 86329
	Format-ShortTimeString -Seconds 86330
	Format-ShortTimeString -Seconds 86331
	Format-ShortTimeString -Seconds 86399
	Format-ShortTimeString -Seconds 86400
	Format-ShortTimeString -Seconds 86429
	Format-ShortTimeString -Seconds 86430
	Format-ShortTimeString -Seconds 86431
	
	Format-ShortTimeString -Seconds 86329 -Round
	Format-ShortTimeString -Seconds 86330 -Round
	Format-ShortTimeString -Seconds 86331 -Round
	Format-ShortTimeString -Seconds 86399 -Round
	Format-ShortTimeString -Seconds 86400 -Round
	Format-ShortTimeString -Seconds 86429 -Round
	Format-ShortTimeString -Seconds 86430 -Round
	Format-ShortTimeString -Seconds 86431 -Round
	
	Format-ShortTimeString -Seconds 93529
	Format-ShortTimeString -Seconds 93530
	Format-ShortTimeString -Seconds 93531
	Format-ShortTimeString -Seconds 93599
	Format-ShortTimeString -Seconds 93600
	Format-ShortTimeString -Seconds 93629
	Format-ShortTimeString -Seconds 93630
	Format-ShortTimeString -Seconds 93631
	.EXAMPLE
	# Countdown from 24h exactly (86400 seconds)
	for ($i = 86400; $i -ge 0; $i--) {
		Write-Host "$($i.ToString().PadLeft(5,' ')) = '$(Format-ShortTimeString -Seconds $i)'"
	}
	.EXAMPLE
	Write-Host "Countdown from 24h 1m to 2m less"
	$StartTime = New-TimeSpan -Hours 24 -Minutes 1
	$EndTime = $StartTime - (New-TimeSpan -Minutes 2)
	for ($i = $StartTime.TotalSeconds; $i -ge $EndTime.TotalSeconds; $i--) {
		Write-Host "$($i.ToString().PadLeft(5,' ')) = '$(Format-ShortTimeString -Seconds $i)'"
	}
	.EXAMPLE
	Write-Host "Countdown from 93631 seconds (1d 2h 31s) to 2m less"
	$StartTime = New-TimeSpan -Seconds 93631
	$EndTime = $StartTime - (New-TimeSpan -Minutes 2)
	for ($i = $StartTime.TotalSeconds; $i -ge $EndTime.TotalSeconds; $i--) {
		Write-Host "$($i.ToString().PadLeft(5,' ')) = '$(Format-ShortTimeString -Seconds $i)'"
	}
	.EXAMPLE
	Write-Host "Countdown from 93631 seconds (1d 2h 31s) to 2m less, with -ExactTime switch"
	$StartTime = New-TimeSpan -Seconds 93631
	$EndTime = $StartTime - (New-TimeSpan -Minutes 2)
	for ($i = $StartTime.TotalSeconds; $i -ge $EndTime.TotalSeconds; $i--) {
		Write-Host "$($i.ToString().PadLeft(5,' ')) = '$(Format-ShortTimeString -Seconds $i -ExactTime)'"
	}
	.EXAMPLE
	Write-Host "Countdown from 86431 seconds (1d 31s) to 2m less, with -Round switch"
	$StartTime = New-TimeSpan -Seconds 86431
	$EndTime = $StartTime - (New-TimeSpan -Minutes 2)
	for ($i = $StartTime.TotalSeconds; $i -ge $EndTime.TotalSeconds; $i--) {
		Write-Host "$($i.ToString().PadLeft(5,' ')) = '$(Format-ShortTimeString -Seconds $i -Round)'"
	}
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
		[Alias('Second','s')]
		[int]$Seconds,
		
		[Switch]$Round,
		
		[switch]$ExactTime
	)
	$FunctionName = $MyInvocation.MyCommand
	Write-Verbose -Message "[$FunctionName]: Beginning function"
	
	$TS = New-TimeSpan -Seconds $Seconds
	
	If ($ExactTime) {
		$Result = ""
		If ($TS.Days -gt 0) {
			$Result += "$($TS.Days)d "
		}
		If ($TS.Hours -gt 0) {
			$Result += "$($TS.Hours)h "
		}
		If ($TS.Minutes -gt 0) {
			$Result += "$($TS.Minutes)m "
		}
		If ($TS.Seconds -gt 0) {
			$Result += "$($TS.Seconds)s"
		}
		$Result = $Result.Trim()
	} Else {
		If ($TS.TotalSeconds -le 60) {
			$Result = "$([math]::Round($TS.TotalSeconds,1))" + "s"
		} Else {
			If ($TS.TotalMinutes -lt 60) {
				If ($TS.Seconds -eq 0 -Or $Round) {
					$Result = "$([math]::Round($TS.TotalMinutes,1))" + "m"
				} Else {
					$Result = "$($TS.Minutes)m $($TS.Seconds)s"
				}
			} Else {
				If ($TS.TotalHours -lt 24) {
					If ($([math]::Round($TS.TotalMinutes,0)) -eq 1440) {
						$Result = "24h"
					} Else {
						If ($TS.Minutes -eq 0) {
							$Result = "$($TS.Hours)h"
						} Else {
							$Result = "$($TS.Hours)h $($TS.Minutes)m"
						}
					}
				} ElseIf ($([math]::Round($TS.TotalMinutes,0)) -eq 1440) {
					$Result = "24h"
				} Else {
					If ($TS.Minutes -eq 0) {
						If ($TS.Hours -eq 0) {
							$Result = "$($TS.Days)d"
						} Else {
							$Result = "$($TS.Hours)h $($TS.Minutes)m"
							$Result = "$($TS.Days)d $($TS.Hours)h"
						}
					} Else {
						If ($TS.Hours -eq 0) {
							$Result = "$($TS.Days)d $($TS.Minutes)m"
						} Else {
							$Result = "$($TS.Days)d $($TS.Hours)h $($TS.Minutes)m"
						} # End If ($TS.Hours -eq 0)
					} # End If ($TS.Minutes -eq 0)
				} # End If ($TS.TotalHours -lt 24)
			} # End If ($TS.TotalMinutes -lt 60)
		} # End If ($TS.TotalSeconds -le 60)
	} # End If/Else ($ExactTime)
	
	Write-Verbose -Message "[$FunctionName]: Ending function"
	Return $Result
} # End 
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function Start-SleepTimer {
	<#
	.SYNOPSIS
	Starts a countdown timer that puts the computer to sleep
	.DESCRIPTION
	Puts the computer to sleep or hibernates after a set amount of time. Defaults to hour and minute value selection.
	.PARAMETER TimerDuration
	Takes [TimeSpan] type input values. For example, like the output given by `New-TimeSpan` command.
	By default this function uses: (New-TimeSpan -Hours 2 -Minutes 30)
	.PARAMETER TicsBeforeCounterResync
	For methods that rely on wait operations from PowerShell loops, this value will determine how many seconds into the time count loop before this function corrects itself based on end time calculated at the beginning of execution.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	.EXAMPLE
	Start-SleepTimer -Hours 2 -Minutes 30 -Action 'sleep'
	Starts a sleep countdown timer for 2 hours and 30 minutes from now. 
	
	Start-SleepTimer -Hours 2 -Minutes 30 -Action 'sleep' -TicsBeforeCounterResync 59
	Start-SleepTimer -Hours 2 -Minutes 30 -Action 'sleep' -TicsBeforeCounterResync 9
	.EXAMPLE
	Start-SleepTimer -TimerDuration (New-TimeSpan -Seconds 10) -TicsBeforeCounterResync 9 -Verbose
	Sets a sleep timer for 10 seconds from now. The default action is to sleep/suspend the system, so the -Action parameter is not required.
	
	Start-SleepTimer -TimerDuration (New-TimeSpan -Seconds 60) -TicsBeforeCounterResync 9 -Verbose
	.EXAMPLE
	Start-SleepTimer -DateTime (Get-Date -Hour (12 + 8) -Minute 0 -Second 0) -Verbose -Action 'Hibernate'
	Sets a hibernate timer for 8 PM.
	.LINK
	https://ephos.github.io/posts/2018-8-20-Timers
	#>
	[Alias("Set-SleepTimer")]
	#Requires -Version 3
	#[CmdletBinding(DefaultParameterSetName = 'Timer')]
	#[CmdletBinding(DefaultParameterSetName = 'HoursMins')]
	[CmdletBinding(
		DefaultParameterSetName = 'HoursMins',
		SupportsShouldProcess = $True
	)]
	Param(
		[Parameter(
			Mandatory = $True, 
			Position = 0, 
			ValueFromPipeline = $True, 
			ValueFromPipelineByPropertyName = $True, 
			ParameterSetName = 'DateTime'
		)]
		[ValidateNotNullOrEmpty()]
		[Alias('SleepTime')]
		[DateTime]$DateTime,
		
		[Parameter(
			Mandatory = $False, 
			Position = 0, 
			ValueFromPipeline = $True, 
			ValueFromPipelineByPropertyName = $True, 
			ParameterSetName = 'Timer'
		)]
		[ValidateNotNullOrEmpty()]
		[Alias('SleepTimer','Timer')]
		[TimeSpan]$TimerDuration = (New-TimeSpan -Hours 2 -Minutes 0),
		#[TimeSpan]$TimerDuration = (New-TimeSpan -Hours 2 -Minutes 0),
		#[TimeSpan]$TimerDuration = (New-TimeSpan -Minutes 3),
		#[TimeSpan]$TimerDuration = (New-TimeSpan -Seconds 10),
		
		[Parameter(
			Mandatory = $True, 
			Position = 0, 
			ValueFromPipeline = $True, 
			ValueFromPipelineByPropertyName = $True, 
			ParameterSetName = 'HoursMins'
		)]
		[Int32]$Hours,
		
		[Parameter(
			Mandatory = $True, 
			Position = 1, 
			ValueFromPipelineByPropertyName = $True, 
			ParameterSetName = 'HoursMins'
		)]
		[Alias('Mins')]
		[Int32]$Minutes,
		
		[Parameter(
			Mandatory = $False, 
			#Position = 0, 
			#ValueFromPipeline = $True, 
			ValueFromPipelineByPropertyName = $True 
			#ParameterSetName = 'StringName'
		)]
		[ValidateSet('Sleep','Suspend','Standby','Hibernate')]
		[Alias('PowerAction')]
		[String]$Action = 'Sleep',
		[Switch]$DisableWake,
		[Switch]$Force,
		
		[Alias('Resync')]
		[int]$TicsBeforeCounterResync = 299
		#[int]$TicsBeforeCounterResync = 9
		
	) # End Params
	Begin {
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
		# Get this function's path:
		$FunctionPath = $PSCommandPath
		#$FunctionContent = $MyInvocation.MyCommand.Definition
		$FunctionName = $MyInvocation.MyCommand.Name
		#$FunctionName = $MyInvocation.MyCommand
		Write-Verbose -Message "[$FunctionName]: Starting function `"$FunctionPath`""
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Executing Begin block"
		Write-Verbose -Message "[$FunctionName]: Set up params"
		
		$StartTime = Get-Date
		
		#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 1)
		#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 5)
		#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Hours 2 -Minutes 30)
		
		If ($DateTime) {
			Write-Verbose "[$FunctionName]: ParameterSet selected: 'DateTime'"
			[DateTime]$EndTime = Get-Date -Date $DateTime -Millisecond 0
			[TimeSpan]$TimerDuration = [DateTime]$EndTime - (Get-Date -Date $StartTime -Millisecond 0)
		} ElseIf ($Hours -Or $Minutes) {
			Write-Verbose "[$FunctionName]: ParameterSet selected: 'HoursMins'"
			
			$TimeSpanParams = @{}
			If ($Hours) { $TimeSpanParams += @{Hours = $Hours} }
			If ($Minutes) { $TimeSpanParams += @{Minutes = $Minutes} }
			
			$TimerDuration = New-TimeSpan @TimeSpanParams @CommonParameters
			[DateTime]$EndTime = [DateTime]$StartTime + [TimeSpan]$TimerDuration
		} ElseIf ($TimerDuration) {
			Write-Verbose "[$FunctionName]: ParameterSet selected: 'Timer'"
			[DateTime]$EndTime = [DateTime]$StartTime + [TimeSpan]$TimerDuration
		}
		Write-Verbose "[$FunctionName]: `$EndTime = $EndTime"
		Write-Verbose "[$FunctionName]: `$TimerDuration = $TimerDuration"
		
		$SetPowerStateParams = @{
			DisableWake = $DisableWake
			Force = $Force
		}
		
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		Write-Verbose -Message "[$FunctionName]: Sub functions"
		#-----------------------------------------------------------------------------------------------------------------------
		#-----------------------------------------------------------------------------------------------------------------------
		function Register-SchdTask {
			<#
			.SYNOPSIS
			.DESCRIPTION
			.NOTES
			#>
			[CmdletBinding(
				SupportsShouldProcess,
				DefaultParameterSetName = 'MinutesFromNow'
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
			# Get this function's path:
			$FunctionPath = $PSCommandPath
			#$FunctionContent = $MyInvocation.MyCommand.Definition
			$FunctionName = $MyInvocation.MyCommand.Name
			#$FunctionName = $MyInvocation.MyCommand
			Write-Verbose -Message "[$FunctionName]: Starting function `"$FunctionPath`""
			#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			#-----------------------------------------------------------------------------------------------------------------------
			Write-Verbose "[$FunctionName]: Scheduled Task method:"
			return
			
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
			Write-Verbose "[$FunctionName]: $MiniTimeNow"
			If ($MinuteMark -Or $MinuteMark -eq 0) {
				Write-Verbose "[$FunctionName]: MinuteMark trigger frequency selected"
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
				Write-Verbose "[$FunctionName]: MinutesFromNow trigger frequency selected"
				[string]$SchedTaskName = $SchedTaskName + "_MinsFromNow"
				$DateTimeOnce = (Get-Date -Second 0) + (New-TimeSpan -Minutes $MinutesFromNow)
				$MiniTime = "$(Get-Date -Date $DateTimeOnce -UFormat '%I:%M %p / %R')"
				$DescripTypeRate = "$MinutesFromNow minutes from $($MiniTimeNow) at $($MiniTime): $DateTimeOnce"
				$T = New-ScheduledTaskTrigger -Once -At $DateTimeOnce
			} ElseIf ($DateTimeOnce) {
				Write-Verbose "[$FunctionName]: DateTimeOnce trigger frequency selected"
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
				Write-Verbose "[$FunctionName]: DateTimeOnce trigger frequency selected"
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
				Write-Warning "[$FunctionName]: No Scheduled Task Trigger defined -MinuteMark, -MinutesFromNow, -DateTimeOnce, -DateTimeDaily"
			}
			Write-Verbose "[$FunctionName]: '$DescripTypeRate'"
			Write-Verbose "[$FunctionName]: -At $DateTimeOnce"
			$SchedDescription = "Reboot Valheim server $DescripTypeRate`nAuto-scheduled on: $(Get-Date)"
			
			# Scheduled Action:
			#$FilePath = "<filename>.ps1"
			$FilePath = $ScriptPath
			$ScriptArgs = "-RestartServer -SchedTaskName `"$SchedTaskName`" -SchedTaskPath `"$SchedTaskPath`" -ServerStartupScript `"$ServerStartupScript`" -SecondsBuffer $SecondsBuffer"
			If ($VerbosePreference -ne 'SilentlyContinue') {$ScriptArgs += " -Verbose"}
			If ($DebugPreference -ne 'SilentlyContinue') {$ScriptArgs += " -Debug"}
			If ([bool]$WhatIfPreference) {$ScriptArgs += " -WhatIf"}
			If ($Confirm) {$ScriptArgs += " -Confirm"}
			Write-Verbose "[$FunctionName]: $ScriptArgs"
			#-File
			#	Runs the specified script in the local scope ("dot-sourced"), so that the
			#	functions and variables that the script creates are available in the
			#	current session. Enter the script file path and any parameters.
			#	File must be the last parameter in the command, because all characters
			#	typed after the File parameter name are interpreted
			#	as the script file path followed by the script parameters.
			#$ScriptExecution = "Powershell.exe -file `"$FilePath`" $ScriptArgs"
			$ScriptExecution = "-NoLogo -ExecutionPolicy Bypass -NoProfile -NonInteractive -File `"$FilePath`" $ScriptArgs"
			#-Command
			#	Executes the specified commands (and any parameters) as though they were
			#	typed at the Windows PowerShell command prompt, and then exits, unless
			#	NoExit is specified. The value of Command can be "-", a string. or a
			#	script block.
			#	
			#	If the value of Command is "-", the command text is read from standard
			#	input.
			#	
			#	If the value of Command is a script block, the script block must be enclosed
			#	in braces ({}). You can specify a script block only when running PowerShell.exe
			#	in Windows PowerShell. The results of the script block are returned to the
			#	parent shell as deserialized XML objects, not live objects.
			#	
			#	If the value of Command is a string, Command must be the last parameter
			#	in the command , because any characters typed after the command are
			#	interpreted as the command arguments.
			#	
			#	To write a string that runs a Windows PowerShell command, use the format:
			#		"& {<command>}"
			#	where the quotation marks indicate a string and the invoke operator (&)
			#	causes the command to be executed.
			$CommandExecution = "-NoLogo -ExecutionPolicy Bypass -NoProfile -NonInteractive -Command & {}"
			Write-Verbose "[$FunctionName]: $ScriptExecution"
			#$A = New-ScheduledTaskAction Execute $ScriptExecution
			$A = New-ScheduledTaskAction -Execute "Powershell.exe" -WorkingDirectory $ScriptProjFolder -Argument $ScriptExecution
			
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
				Write-Verbose "[$FunctionName]: Scheduling as System Service Account"
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
				###
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
					Write-Verbose "[$FunctionName]: Scheduling task $SchedTaskName to run with highest privileges"
					If ($PSCmdlet.ShouldProcess("-TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Trigger $T -Settings $S -User $Env:UserName -Password $Password -RunLevel Highest",'Register-ScheduledTask')) {
						Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Trigger $T -Settings $S -User $Env:UserName -Password $Password -RunLevel Highest
					}
					#Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Trigger $T -Settings $S -User $Env:UserName -Password $Password -RunLevel Highest
				} Else {
					If ($PSCmdlet.ShouldProcess("-TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S ",'Register-ScheduledTask')) {
						Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S 
					}
					#Register-ScheduledTask -TaskName $SchedTaskName -TaskPath $SchedTaskPath -Description $SchedDescription -Action $A -Principal $P -Trigger $T -Settings $S 
				}
			} # / If/Else ($RunAsSystemServiceAccount) 
			
			#-----------------------------------------------------------------------------------------------------------------------
			
			
			#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			Write-Verbose -Message "[$FunctionName]: Ending function"
			Return
		} # /End function Register-SchdTask
		#-----------------------------------------------------------------------------------------------------------------------
		#-----------------------------------------------------------------------------------------------------------------------
		Write-Verbose -Message "[$FunctionName]: End sub functions"
		#Register-SchdTask
		#return
		
		Write-Verbose "[$FunctionName]: End of Begin block."
	} # End of Begin
	Process {
		Write-Verbose -Message "[$FunctionName]: Executing Process block"
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		Write-Verbose -Message "[$FunctionName]: Main timer method selection"
		
		$Method = 0
		switch ($Method) {
			0 { # "PowerShell Start-Sleep wait method:"
				Write-Verbose "[$FunctionName]: PowerShell Start-Sleep wait method:"
				#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
				
				$RefreshRate = 1 # in seconds
				$RefreshRateFast = 200
				$RefreshRateSlow = 5
				#$TicsBeforeCounterResync = 9
				#$TicsBeforeCounterResync = 59
				#$TicsBeforeCounterResync = 299
				$HeaderBreaks = 5
				$ProgressBarId = 0
				
				If ($Action -eq 'Sleep' -Or $Action -eq 'Suspend') {
					$ActionVerb = "Sleeping"
				} ElseIf ($Action -eq 'Hibernate') {
					$ActionVerb = "Hibernating"
				}
				
				#-----------------------------------------------------------------------------------------------------------------------
				Function Get-NewlineSpacer([int]$LineBreaks,[switch]$Testing) {
					<#
					.EXAMPLE
					Get-NewlineSpacer -LineBreaks 0 -Testing
					Get-NewlineSpacer -LineBreaks 1 -Testing
					Get-NewlineSpacer -LineBreaks 2 -Testing
					Get-NewlineSpacer -LineBreaks 5 -Testing
					.EXAMPLE
					$NewlineSpace = Get-NewlineSpacer -LineBreaks 5
					$HeaderLineBreaks = Get-NewlineSpacer -LineBreaks $HeaderBreaks
					#>
					$NewlineSpace = ""
					If ($LineBreaks -gt 0) {
						for ($i = 0; $i -lt $LineBreaks; $i++) {
							$NewlineSpace += "`n"
						}
					}
					If ($Testing) {
						Write-Host "LineBreaks: `'$LineBreaks`' - Start"
						Write-Host "$($NewlineSpace)End"
					} Else {
						Return $NewlineSpace
					}
				} # End Function Get-NewlineSpacer
				#$HeaderLineBreaks = Get-NewlineSpacer -LineBreaks $HeaderBreaks
				#-----------------------------------------------------------------------------------------------------------------------
				
				#-----------------------------------------------------------------------------------------------------------------------
				Function Get-ProgressBarTest {
					<#
					.LINK
					https://thinkpowershell.com/how-to-make-a-powershell-progress-bar/
					#>
					For ($i=0; $i -le 100; $i++) {
						Start-Sleep -Milliseconds 20
						Write-Progress -Activity "Counting to 100" -Status "Current Count: $i" -PercentComplete $i -CurrentOperation "Counting ..."
					}
				} # End Function Get-ProgressBarTest
				#Get-ProgressBarTest
				#-----------------------------------------------------------------------------------------------------------------------
				
				#-----------------------------------------------------------------------------------------------------------------------
				Function Get-TimerProgressBarTest($Seconds) {
					For ($i=0; $i -le $Seconds; $i++) {
						$PercentageComplete = ($i/$Seconds).ToString("P")
						$PercentageComplete2 = "$( [math]::Round(( ($i/$Seconds)*100 ),2) ) %"
						Write-Progress -Activity "Counting to $Seconds" -Status "Current Count: $i/$Seconds - $PercentageComplete - $PercentageComplete2" -PercentComplete (($i/$Seconds)*100) -CurrentOperation "Counting ..."
						If ($i -ne $Seconds) {
							Start-Sleep -Seconds 1
						}
					}
					Write-Progress -Activity "Counting to $Seconds" "Current Count: $Seconds/$Seconds" -PercentComplete 100 -CurrentOperation "Complete!" #-Completed
					Start-Sleep -Seconds 2
				} # End Function Get-TimerProgressBarTest
				#Get-TimerProgressBarTest -Seconds 777
				#-----------------------------------------------------------------------------------------------------------------------
				
				#-----------------------------------------------------------------------------------------------------------------------
				Function Get-NestedProgressBarTest {
					<#
					.LINK
					https://thinkpowershell.com/how-to-make-a-powershell-progress-bar/
					#>
					For ($i=0; $i -le 10; $i++) {
						Start-Sleep -Milliseconds 1
						Write-Progress -Id 1 -Activity "First Write Progress" -Status "Current Count: $i" -PercentComplete $i -CurrentOperation "Counting ..."
						
						For ($j=0; $j -le 100; $j++) {
							Start-Sleep -Milliseconds 1
							Write-Progress -Id 2 -Activity "Second Write Progress" -Status "Current Count: $j" -PercentComplete $j -CurrentOperation "Counting ..."
						}
					}
				} # End Function Get-NestedProgressBarTest
				#Get-NestedProgressBarTest
				#-----------------------------------------------------------------------------------------------------------------------
				
				$SecondsToCount = $TimerDuration.TotalSeconds
				$OrigSecondsToCount = $TimerDuration.TotalSeconds
				$TimeLeft = $TimerDuration
				$OrigTimerDuration = $TimerDuration
				$TimerDurationWhole = $TimerDuration
				$EndTimeShort = Get-Date -Date $EndTime -Format t
				$EndTimeLong = Get-Date -Date $EndTime -Format T
				$StartTimeShort = Get-Date -Date $StartTime -Format t
				$StartTimeLong = Get-Date -Date $StartTime -Format T
				$SecondsCounter = 0
				$i = 0
				
				$CounterMethod = 0
				switch ($CounterMethod) {
					0 {
						Write-Verbose "Write-Progress method:"
						$ActivityName = "$ActionVerb device at $EndTimeLong - (Ctrl + C to Cancel)"
						$j = 0 # Clock re-sync counter, used with $TicsBeforeCounterResync
						$k = 0 # Re-sync operation counter
						$FloatTimeTotal = 0
						$ResyncTimeLabel = Format-ShortTimeString -Seconds $TicsBeforeCounterResync -Round
						do {
							#Clear-Host #cls
							
							#$i = $i + $RefreshRate
							$SecondsCounter = $SecondsCounter + $RefreshRate
							$TimeLeft = New-TimeSpan -Seconds ($SecondsToCount - $SecondsCounter)
							$TimeElapsed = New-TimeSpan -Seconds ($SecondsCounter)
							
							#https://devblogs.microsoft.com/scripting/use-powershell-and-conditional-formatting-to-format-time-spans/
							#$CountdownLabel = "{0:c}" -f $TimeLeft
							$CountdownLabel = "{0:g}" -f $TimeLeft
							#$CountdownLabel = "{0:G}" -f $TimeLeft
							
							$CountUpLabel = "{0:g}" -f $TimeElapsed
							
							$PercentageComplete = ($SecondsCounter / $SecondsToCount).ToString("P")
							
							If ($j -lt $TicsBeforeCounterResync) {
								$j++
								$Status = "Counting from $StartTimeShort every $RefreshRate second(s) for $TimerDurationWhole (orignally $OrigTimerDuration) up to $EndTimeShort before $ActionVerb..."
								If ($SecondsToCount -ne $OrigSecondsToCount) {
									$Diff = $SecondsToCount - $OrigSecondsToCount
									If ($Diff -ge 0) {$Diff = "+$Diff"}
									$SecondsToCountLabel = "$SecondsToCount (orig $OrigSecondsToCount $Diff)"
								} Else {
									$SecondsToCountLabel = $SecondsToCount
									#$SecondsToCountLabel = ""
								}
							} Else {
								$j = 0
								$k++
								
								#[TimeSpan]$NewTimerDurationWhole = [DateTime]$EndTime - (Get-Date -Millisecond 0)
								[TimeSpan]$NewTimerDuration = [DateTime]$EndTime - (Get-Date)
								$NewSecondsToCount = $NewTimerDuration.TotalSeconds
								[TimeSpan]$NewTimerDurationWhole = New-TimeSpan -Seconds ([math]::Round($NewSecondsToCount,0))
								$TimeLeft = $NewTimerDuration
								
								$FloatSeconds = [math]::Round(( $NewSecondsToCount - ($SecondsToCount - $SecondsCounter) ),1)
								$SecondsCounterRemaining = $SecondsToCount - $SecondsCounter
								
								If ($NewSecondsToCount -lt $SecondsCounterRemaining) {
									$Status = "Re-syncing timer with $EndTimeShort deadline... (done $k times) - Shortening float counter by $([math]::Round(( $SecondsCounterRemaining - $NewSecondsToCount ),1))"
								} ElseIf ($NewSecondsToCount -gt $SecondsCounterRemaining) {
									$Status = "Re-syncing timer with $EndTimeShort deadline... (done $k times) - Lengthening float counter by $([math]::Round(( $NewSecondsToCount - $SecondsCounterRemaining ),1))"
								} ElseIf ($NewSecondsToCount -eq $SecondsCounterRemaining) {
									$Status = "Re-syncing timer with $EndTimeShort deadline... (done $k times) - No adjustment needed!"
								}
								
								$FloatTimeTotal = [math]::Round(( $FloatTimeTotal + $FloatSeconds ),1)
								[TimeSpan]$TimerDuration = [TimeSpan]$NewTimerDuration
								[TimeSpan]$TimerDurationWhole = [TimeSpan]$NewTimerDurationWhole
								
								$FloatTimeWhole = [math]::Round($FloatSeconds,0)
								
								If ($FloatTimeWhole -ge 1 -Or $FloatTimeWhole -le -1) {
									#$SecondsCounterRemaining
									#$SecondsToCount = $SecondsToCount + $FloatTimeWhole
									$SecondsToCount = ( [math]::Round($NewSecondsToCount,0) + $SecondsCounter )
								}
								
							} # End If/Else ($j -lt $TicsBeforeCounterResync)
							
							If ($k -gt 0) {
								$CurrentOp = "$ActionVerb device in $CountdownLabel - $CountUpLabel - $PercentageComplete - Count: $SecondsCounter/$SecondsToCountLabel - Re-sync'd $k time(s), once every $ResyncTimeLabel ($j/$TicsBeforeCounterResync), drift: $FloatSeconds cumulative: $FloatTimeTotal"
							} Else {
								$CurrentOp = "$ActionVerb device in $CountdownLabel - $CountUpLabel - $PercentageComplete - Count: $SecondsCounter/$SecondsToCountLabel - Re-sync every $ResyncTimeLabel ($j/$TicsBeforeCounterResync)"
							}
							
							Write-Progress -Id $ProgressBarId -Activity $ActivityName -PercentComplete (($SecondsCounter / $SecondsToCount)*100) -Status $Status -CurrentOperation $CurrentOp
							
							<#
							Write-Progress
								[-Activity] <String>
								[[-Status] <String>]
								[[-Id] <Int32>]
								[-PercentComplete <Int32>]
								[-SecondsRemaining <Int32>]
								[-CurrentOperation <String>]
								[-ParentId <Int32>]
								[-Completed]
								[-SourceId <Int32>]
								[<CommonParameters>]
							#>
							
							Start-Sleep -Seconds $RefreshRate
							
							#} until ($SecondsCounter -ge ($SecondsToCount - 30) )
						} until ($SecondsCounter -ge $SecondsToCount)
						
						Write-Progress -Id $ProgressBarId -Activity $ActivityName -Completed
						
						Write-Verbose "Progress bar counter completed."
						
					}
					1 {
						Write-Verbose "Set method:"
						
						
					}
					Default {}
				} # End switch ($CounterMetod)
				
				Write-Verbose "$ActionVerb computer . . ."
				
				#PAUSE
				
				Set-PowerState -Action $Action @SetPowerStateParams @CommonParameters @RiskMitigationParameters
				
				#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
				
			}
			1 { # "Using [Stopwatch] object method: (WIP)"
				Write-Verbose "[$FunctionName]: Using [Stopwatch] object method:"
				#https://ephos.github.io/posts/2018-8-20-Timers
				
				#Create a Stopwatch
				$stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
				
				#You can use the $stopWatch variable to see it
				$stopWatch
				
				#Go ahead and check out the methods and properties it has
				$stopWatch | Get-Member
				
			}
			2 { # "Scheduled Task method:"
				Write-Verbose "[$FunctionName]: Scheduled Task method:"
				#-----------------------------------------------------------------------------------------------------------------------
				
				Write-Verbose "[$ScriptName]: Scheduled Task method:"
				
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
				$FilePath = $ScriptPath
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
					###
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
				
				
			}
			Default {
				Write-Error "Incorrectly definfed method: '$Method'"
				Throw "Incorrectly definfed method: '$Method'"
			}
		}
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Completed Process block"
	} # End Process
	End {
		Write-Verbose -Message "[$FunctionName]: Executing End block"
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Ending function"
		Return
	} # End of End block
} # End of Start-SleepTimer function.
Set-Alias -Name 'Set-SleepTimer' -Value 'Start-SleepTimer'
#-----------------------------------------------------------------------------------------------------------------------
#Start-SleepTimer -Minutes 1 -Action 'sleep' -WhatIf
#Return

#-----------------------------------------------------------------------------------------------------------------------
Function Stop-SleepTimer {
	<#
	.SYNOPSIS
	Stops any sleep timer countdown created by Start-SleepTimer function
	.DESCRIPTION
	
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	#>
	[Alias("Reset-SleepTimer", "Disable-SleepTimer")]
	#Requires -Version 3
	#[CmdletBinding()]
	[CmdletBinding(DefaultParameterSetName = 'None')]
	Param(
		[Parameter(
			Mandatory = $True, 
			Position = 0, 
			ValueFromPipeline = $True, 
			ValueFromPipelineByPropertyName = $True, 
			HelpMessage = "Path to ...", 
			ParameterSetName = "Path"
		)]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p')]
		[String]$Path
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of Stop-SleepTimer function.
Set-Alias -Name 'Reset-SleepTimer' -Value 'Stop-SleepTimer'
Set-Alias -Name 'Disable-SleepTimer' -Value 'Stop-SleepTimer'
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
# Define functions:

function Create-DirIfDoesNotExist {
	[CmdletBinding()]
	param (
		[Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
		$InputPath
	)
	If (!(Test-Path -Path $InputPath)) {
		Write-Warning "'$InputPath' does not exist."
		Write-Host "Creating '$InputPath'"
		New-Item -Path $InputPath -ItemType Directory
	}
} # / function Create-DirIfDoesNotExist

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
	$FilePath = $ScriptPath
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

Function Format-FileSize {
	[CmdletBinding()]
	Param (
		$Size
	)
	If ($Size -gt 1TB) {
		[string]::Format("{0:0.00} TB", $Size / 1TB)
	} ElseIf ($Size -gt 1GB) {
		[string]::Format("{0:0.00} GB", $Size / 1GB)
	} ElseIf ($Size -gt 1MB) {
		[string]::Format("{0:0.00} MB", $Size / 1MB)
	} ElseIf ($Size -gt 1KB) {
		[string]::Format("{0:0.00} KB", $Size / 1KB)
	} ElseIf ($Size -ge 0) {
		[string]::Format("{0:0.00} B", $Size)
	}
} # / Function Format-FileSize 

#-----------------------------------------------------------------------------------------------------------------------
Function Get-AllPowerShellColors {
	<#
	.SYNOPSIS
	Returns a list of all available PowerShell colors.
	.DESCRIPTION
	Returns list of every available PowerShell color by default. When used with other switches, this function also produces Foreground and Background examples. 
	
	The -List switch prints output directly to the terminal using Write-Host, and -Grid produces an array object output that can be formatted as a table. 
	
	The -VtColors switch enables use of Virtual Terminal color codes, which greatly expands the range of colors available for use, and allows in-line text coloring. To find out if the type of PowerShell interface in use is compatible with Virtual Terminal colors, use the -ShowHostInfo switch. See also ConvertTo-VtColorString function.
	.PARAMETER List
	Prints a complete list of different ForeGround and BackGround color examples. Useful for choosing multiple fore/back color pairs.
	
	Not compatible with -Grid parameter.
	.PARAMETER AddColorLabels
	Adds non-color-formatted labels to -ColorList output.
	
	For a standard-width PowerShell terminal, this extra string length will overflow each line of printed output, so usually requires a wider than normal terminal width for formatted output.
	.PARAMETER Grid
	Returns an array object with details about color options, and a few color examples.
	
	Not compatible with -ColorList parameter.
	.PARAMETER VtColors
	Show addiitional options for Virtual Terminal colors.
	
	For more info on VT colors:
	https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
	.PARAMETER Alphabetic
	This switch is on by default, so this syntax is required to explicitly turn it off:
	Get-AllPowerShellColors -Alphabetic:$False
	.PARAMETER Quiet
	Returns complete list of color names only. No other Write-Host output is printed to console. Overrides other switches that produce host/terminal output. Pipeline output will still be produced.
	.PARAMETER ShowHostInfo
	Provides a curated list of some details of the host console/terminal executing the PowerShell commands, including default Foreground and Background colors, and if the host supports Virtual Terminal colors. 
	
	See the `Get-Host` command and $PSVersionTable built-in variable for more of this type of info.
	.EXAMPLE
	Get-AllPowerShellColors -ShowHostInfo
	
	Display infor about the current PowerShell terminal, including Virtual Terminal color support. 
	See `(Get-AllPowerShellColors -ShowHostInfo).SupportsVirtualTerminal` for direct value.
	.EXAMPLE
	Get-AllPowerShellColors
	
	Prints list of available PowerShell colors.
	.EXAMPLE
	(Get-AllPowerShellColors -Quiet).Count
	
	Returns number of available PowerShell colors. (Standard is 16)
	.EXAMPLE
	Get-AllPowerShellColors -Alphabetic:$False
	
	Do not produce alphabetic output. This switch is on by default, so this syntax is required to explicitly turn it off.
	
	Another way to explicitly sort output alphabetically, but is not necessary:
	PS\>[string[]](Get-AllPowerShellColors -Quiet) | Sort-Object
	.EXAMPLE
	Get-AllPowerShellColors -List
	
	Returns an example of every color Foreground + Background pair, in a printed output list using Write-Host.
	
	Alias for:
	PS\>Get-AllPowerShellColors -ColorList
	
	Use with the -AddColorLabels switch to include a default-colored tag with each line.
	
	E.g.
	PS\>Get-AllPowerShellColors -List -AddColorLabels
	
	For a standard powershell.exe terminal width (standard 120), each line of this output will end perfectly at the line break point, creating a grid. (When used with standard 16 colors.)
	But when this command is used with the -AddColorLabels switch, each line will additionally print with the color name in the default color scheme, causing overflow. A resized or non-default width powershell interface will change this.
	.EXAMPLE
	Get-AllPowerShellColors -Grid
	
	Prints to console a list of every powershell color applied in every variety of Foreground color and Background color combination. Traditionally, there are 16 available colors, so this switch generates a nice-looking grid on standard-width PowerShell terminal.
	
	Alias for:
	PS\>Get-AllPowerShellColors -ColorGrid
	.EXAMPLE
	Get-AllPowerShellColors -VtColors
	.EXAMPLE
	Get-AllPowerShellColors
	Get-AllPowerShellColors -Quiet
	Get-AllPowerShellColors -List
	Get-AllPowerShellColors -List -AddColorLabels
	Get-AllPowerShellColors -Grid
	Get-AllPowerShellColors -VtColors
	Get-AllPowerShellColors -List -Quiet
	Get-AllPowerShellColors -Grid -Quiet
	Get-AllPowerShellColors -VtColors -Quiet
	Get-AllPowerShellColors -BlackAndWhite
	Get-AllPowerShellColors -BlackAndWhite -Quiet
	Get-AllPowerShellColors -List -BlackAndWhite
	Get-AllPowerShellColors -Grid -BlackAndWhite
	Get-AllPowerShellColors -VtColors -BlackAndWhite
	Get-AllPowerShellColors -List -BlackAndWhite -Quiet
	Get-AllPowerShellColors -Grid -BlackAndWhite -Quiet
	Get-AllPowerShellColors -VtColors -BlackAndWhite -Quiet
	Get-AllPowerShellColors -List -VtColors
	Get-AllPowerShellColors -Grid -VtColors
	Get-AllPowerShellColors -List -VtColors -Quiet
	Get-AllPowerShellColors -Grid -VtColors -Quiet
	Get-AllPowerShellColors -List -VtColors -BlackAndWhite
	Get-AllPowerShellColors -Grid -VtColors -BlackAndWhite
	Get-AllPowerShellColors -List -VtColors -BlackAndWhite -Quiet
	Get-AllPowerShellColors -Grid -VtColors -BlackAndWhite -Quiet
	Get-AllPowerShellColors -ShowHostInfo
	.NOTES
	Version Notes:
	v1.0.0: 2022-01-12
	16 color selection based on PowerShell's defaults. Foreground and background colors supported. -List [-AddColorLabels], -Grid, -VtColors, -BlackAndWhite, and -Quiet parameters supported.
	
	Original repository:
	https://github.com/Kerbalnut/MiniTaskMang-PoSh
	https://github.com/Kerbalnut/MiniTaskMang-PoSh/blob/main/public/SaveLoadSync.ps1
	Copied to:
	https://github.com/Kerbalnut/SleepTimerPoSh
	https://github.com/Kerbalnut/SleepTimerPoSh/blob/main/Start-SleepTimer.ps1
	
	Develepment Notes:
	https://www.delftstack.com/howto/powershell/change-colors-in-powershell/
	
	[System.Enum]::GetValues('ConsoleColor') |
	ForEach-Object { Write-Host $_ -ForegroundColor $_ }
	.LINK
	https://github.com/Kerbalnut/MiniTaskMang-PoSh
	.LINK
	https://stackoverflow.com/questions/20541456/list-of-all-colors-available-for-powershell
	.LINK
	https://www.delftstack.com/howto/powershell/change-colors-in-powershell/
	.LINK
	ConvertTo-VtColorString
	#>
	[Alias("Get-AllColors","Get-Colors","Get-ColorsList")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = "ColorList")]
	Param(
		[Parameter(ParameterSetName = "ColorList")]
		[Alias('ColorList','l','cl')]
		[Switch]$List,
		
		[Parameter(ParameterSetName = "ColorList")]
		[Switch]$AddColorLabels,
		
		[Parameter(ParameterSetName = "ColorGrid")]
		[Alias('ColorGrid','g','cg','ShowExamples','show','examples')]
		[Switch]$Grid,
		
		#[Parameter(ParameterSetName = "ColorCompare")]
		#[Switch]$ConsoleColorComparison,
		
		[Parameter(ParameterSetName = "Default")]
		[Parameter(ParameterSetName = "ColorList")]
		[Parameter(ParameterSetName = "ColorGrid")]
		[Alias('vt')]
		[Switch]$VtColors,
		
		[Parameter(ParameterSetName = "Default")]
		[Parameter(ParameterSetName = "ColorList")]
		[Parameter(ParameterSetName = "ColorGrid")]
		[Alias('bw','bnw','black','white')]
		[Switch]$BlackAndWhite,
		
		[Parameter(ParameterSetName = "Default")]
		[Parameter(ParameterSetName = "ColorList")]
		[Parameter(ParameterSetName = "ColorGrid")]
		[Alias('q')]
		[Switch]$Quiet,
		
		[Parameter(ParameterSetName = "Default")]
		[Parameter(ParameterSetName = "ColorList")]
		[Parameter(ParameterSetName = "ColorGrid")]
		[Switch]$Alphabetic = $True,
		
		[Parameter(ParameterSetName = "ShowHostInfo")]
		[Alias('ShowHostDefaults','Defaults','HostDefaults','ConsoleDefaults','InterfaceDefaults','TerminalDefaults')]
		[Switch]$ShowHostInfo
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($List) {$ColorList = $True}
	If ($Grid) {$ColorGrid = $True}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If (!($Alphabetic)) {
		# Standard output (list of all color names):
		$Colors = [enum]::GetValues([System.ConsoleColor])
	} Else {
		# Alphabetic output:
		$Colors = [string[]]([enum]::GetValues([System.ConsoleColor])) | Sort-Object
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($BlackAndWhite) {
		$PureBlackVtFontColor = ConvertTo-VtColorString -ForeColor "Black" -TerminalType 'powershell.exe'
		$PureWhiteVtFontColor = ConvertTo-VtColorString -ForeColor "White" -TerminalType 'powershell.exe'
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$SupportsVirtualTerminal = (Get-Host).UI.SupportsVirtualTerminal
	If ($VtColors -And (!($SupportsVirtualTerminal)) ) {
		Write-Warning 'This host does not support Virtual Terminal colors. Run `Get-AllPowerShellColors -ShowHostInfo` for more info. Issues may occur when using the -VtColors switch on this host. See `Get-Help Get-AllPowerShellColors -Full` for more info on the -VtColors and -ShowHostInfo switches.'
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$HostInterfaceName = (Get-Host).Name
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# Begin If/Else tree for returning/printing output, based on input switches: ColorList, ColorGrid, ShowHostInfo, VtColors, or none of the above.
	If ($ColorList -And !($Quiet)) {
		# Print list to terminal
		If (!($VtColors)) {
			
			[System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }
			
			ForEach ($BgColor in $Colors) {
				If ($BlackAndWhite) {
					Write-Host "Black|" -ForegroundColor 'Black' -BackgroundColor $BgColor -NoNewLine
					Write-Host "White|" -ForegroundColor 'White' -BackgroundColor $BgColor -NoNewLine
				} Else {
					ForEach ($FgColor in $Colors) {
						Write-Host "$FgColor|" -ForegroundColor $FgColor -BackgroundColor $BgColor -NoNewLine
					} # End ForEach ($FgColor)
				}
				If ($AddColorLabels -Or $BlackAndWhite) {Write-Host " on $BgColor"} Else {Write-Host ""}
			} # End ForEach ($BgColor)
		} Else {
			# TODO: Add $VtColors output
			Write-Warning "WIP."
		}
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# End If ($ColorList)
	} ElseIf ($ColorGrid) { # End If ($ColorList)
		# Build GridObj array
		$GridObj = @()
		If (!($VtColors)) {
			# Just -Grid switch with no -VtColors switch
			ForEach ($color in $Colors) {
				If ($color -eq "DarkMagenta") {
					$ColorError = "(PoSh error: appears as blue powershell terminal background)"
				} ElseIf ($color -eq "DarkYellow") {
					$ColorError = "(PoSh error: appears as a lighter gray than 'Gray', almost white but not quite)"
				} ElseIf ($color -eq "Gray") {
					$ColorError = "(VsCode error: appears exact same as vscode white)"
				} Else {
					$ColorError = ""
				}
				
				$GridObj += [PSCustomObject]@{Color = $color; ColorError = $ColorError}
			} # End ForEach ($color in $Colors)
			# End If (!($VtColors))
		} Else {
			# When -Grid and -VtColors switches are used together:
			ForEach ($color in $Colors) {
				$BackColor = $color
				$BadColor = "Red"
				
				If ($BlackAndWhite) {
					$BadVtFontColor = ConvertTo-VtColorString -ForeColor $BadColor -TerminalType 'powershell.exe'
					
					$DefaultColor = (ConvertTo-VtColorString -BackColor $BackColor -Raw -TerminalType 'default')
					$PoShColor    = (ConvertTo-VtColorString -BackColor $BackColor -Raw -TerminalType 'powershell.exe')
					$VsCodeColor  = (ConvertTo-VtColorString -BackColor $BackColor -Raw -TerminalType 'Code.exe')
				} Else {
					$DefaultColor = (ConvertTo-VtColorString -ForeColor $BadColor -TerminalType 'powershell.exe') + ";" + (ConvertTo-VtColorString -BackColor $BackColor -Raw -TerminalType 'default')
					$PoShColor    = (ConvertTo-VtColorString -ForeColor $BadColor -TerminalType 'powershell.exe') + ";" + (ConvertTo-VtColorString -BackColor $BackColor -Raw -TerminalType 'powershell.exe')
					$VsCodeColor  = (ConvertTo-VtColorString -ForeColor $BadColor -TerminalType 'powershell.exe') + ";" + (ConvertTo-VtColorString -BackColor $BackColor -Raw -TerminalType 'Code.exe')
				}
				
				$BadTextColor = (ConvertTo-VtColorString -ForeColor $BadColor -TerminalType 'powershell.exe') + ";" + (ConvertTo-VtColorString -BackColor 'Black' -Raw -TerminalType 'Code.exe')
				
				If ($color -eq "DarkMagenta") {
					$ColorError = "(PoSh error: appears as blue powershell terminal background)"
					$ColorError = "$e[${BadTextColor}m$("$ColorError")${e}[0m"
				} ElseIf ($color -eq "DarkYellow") {
					$ColorError = "(PoSh error: appears as a lighter gray than 'Gray', almost white but not quite)"
					$ColorError = "$e[${BadTextColor}m$("$ColorError")${e}[0m"
				} ElseIf ($color -eq "Gray") {
					$ColorError = "(VsCode error: appears exact same as vscode white)"
					$ColorError = "$e[${BadTextColor}m$("$ColorError")${e}[0m"
				} Else {
					$ColorError = ""
				}
				
				$GridObj += [PSCustomObject]@{Default = $DefaultColor; PoSh = $PoShColor; VsCode = $VsCodeColor; ColorName = " on $BackColor"; ColorError = $ColorError}
			} # End ForEach ($color in $Colors)
			# End If ($VtColors)
		} # End If/Else ($VtColors)
		
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		# Return GridObj array as table
		If ($Quiet) {
			Return $GridObj
		} Else {
			If (!($VtColors)) {
				# Just -Grid switch with no -VtColors switch
				#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
				
				#Write-PSObject $GridObj -MatchMethod Exact -Column "Color" -Value "Yellow" -ValueForeColor Yellow -ValueBackColor Yellow -RowForeColor White -RowBackColor Blue;
				
				
				$GridObj | Format-Table -Property @{
					Label = "Color"
					Expression = {
						$colorstr = $_.Color
						If ($BlackAndWhite) {
							"$e[${colorstrblack}m$("Black|")${e}[0m${e}[${colorstrwhite}m$("White|")${e}[0m"
							
						} Else {
							Write-Host "       " -ForegroundColor $colorstr -BackgroundColor $colorstr -NoNewline
						}
					}
				}, ColorError
				# End $GridObj | Format-Table
				# End If (!($VtColors))
			} Else {
				# When -Grid and -VtColors switches are used together:
				$GridObj | Format-Table -Property @{
					Label = "Default"
					Expression = {
						$colorstr = $_.Default
						#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
						#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
						# Escape key
						$e = [char]27
						# Magic string: VT escape sequences:
						# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
						#    - 0    Default    Returns all attributes to the default state prior to modification
						#"$e[${colorstr}m$("       ")${e}[0m"
						If ($BlackAndWhite) {
							$colorstrblack = $PureBlackVtFontColor + ";" + $colorstr
							$colorstrwhite = $PureWhiteVtFontColor + ";" + $colorstr
							
							"$e[${colorstrblack}m$("Black|")${e}[0m${e}[${colorstrwhite}m$("White|")${e}[0m"
							
						} Else {
							"$e[${colorstr}m$("       ")${e}[0m"
						}
					}
				}, @{
					Label = "PoSh"
					Expression = {
						$colorstr = $_.PoSh
						#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
						#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
						# Escape key
						$e = [char]27
						# Magic string: VT escape sequences:
						# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
						#    - 0    Default    Returns all attributes to the default state prior to modification
						#"$e[${colorstr}m$("       ")${e}[0m"
						If ($BlackAndWhite) {
							If ($_.ColorName -like " on DarkMagenta*" -Or $_.ColorName -like " on DarkYellow*") {
								$colorstrblack = $BadVtFontColor + ";" + $colorstr
								$colorstrwhite = $BadVtFontColor + ";" + $colorstr
								$colorstrblack = $PureBlackVtFontColor + ";" + $colorstr
								$colorstrwhite = $PureWhiteVtFontColor + ";" + $colorstr
							} Else {
								$colorstrblack = $PureBlackVtFontColor + ";" + $colorstr
								$colorstrwhite = $PureWhiteVtFontColor + ";" + $colorstr
							}
							"$e[${colorstrblack}m$("Black|")${e}[0m${e}[${colorstrwhite}m$("White|")${e}[0m"
						} Else {
							If ($_.ColorName -like " on DarkMagenta*" -Or $_.ColorName -like " on DarkYellow*") {
								"$e[${colorstr}m$("???????")${e}[0m"
							} Else {
								"$e[${colorstr}m$("       ")${e}[0m"
							}
						}
					}
				}, @{
					Label = "VsCode"
					Expression = {
						$colorstr = $_.VsCode
						#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
						#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
						# Escape key
						$e = [char]27
						# Magic string: VT escape sequences:
						# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
						#    - 0    Default    Returns all attributes to the default state prior to modification
						#"$e[${colorstr}m$("       ")${e}[0m"
						If ($BlackAndWhite) {
							If ($_.ColorName -like " on Gray*") {
								$colorstrblack = $BadVtFontColor + ";" + $colorstr
								$colorstrwhite = $BadVtFontColor + ";" + $colorstr
								$colorstrblack = $PureBlackVtFontColor + ";" + $colorstr
								$colorstrwhite = $PureWhiteVtFontColor + ";" + $colorstr
							} Else {
								$colorstrblack = $PureBlackVtFontColor + ";" + $colorstr
								$colorstrwhite = $PureWhiteVtFontColor + ";" + $colorstr
							}
							"$e[${colorstrblack}m$("Black|")${e}[0m${e}[${colorstrwhite}m$("White|")${e}[0m"
						} Else {
							If ($_.ColorName -like " on Gray*") {
								"$e[${colorstr}m$("???????")${e}[0m"
							} Else {
								"$e[${colorstr}m$("       ")${e}[0m"
							}
						}
					}
				}, ColorName, ColorError
				# End $GridObj | Format-Table
			} # End If/Else ($VtColors)
		} # End If/Else ($Quiet)
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# End ElseIf $ColorGrid
	} ElseIf ($ShowHostInfo) { # End ElseIf ($ColorGrid)
		$HostInfo = [PSCustomObject]@{
			Name = (Get-Host).Name
			WindowTitle = (Get-Host).UI.RawUI.WindowTitle
			Version = (Get-Host).Version
			PSVersion = $PSVersionTable.PSVersion
			CurrentCulture = (Get-Host).CurrentCulture
			CurrentUICulture = (Get-Host).CurrentUICulture
			Runspace = (Get-Host).Runspace
			SupportsVirtualTerminal = (Get-Host).UI.SupportsVirtualTerminal
			ForegroundColor = (Get-Host).UI.RawUI.ForegroundColor
			BackgroundColor = (Get-Host).UI.RawUI.BackgroundColor
		}
		Return $HostInfo
	} ElseIf ($VtColors) { # End ElseIf ($ShowHostInfo)
		# No other -List or -Grid param specified, but -VtColors is.
		
		$VtColorCodeArray = @()
		
		ForEach ($color in $Colors) {
			$DefaultForeColor = (ConvertTo-VtColorString -ForeColor $color -Raw -TerminalType 'default')
			$PoShForeColor    = (ConvertTo-VtColorString -ForeColor $color -Raw -TerminalType 'powershell.exe')
			$VsCodeForeColor  = (ConvertTo-VtColorString -ForeColor $color -Raw -TerminalType 'Code.exe')
			
			$DefaultBackColor = (ConvertTo-VtColorString -BackColor $color -Raw -TerminalType 'default')
			$PoShBackColor    = (ConvertTo-VtColorString -BackColor $color -Raw -TerminalType 'powershell.exe')
			$VsCodeBackColor  = (ConvertTo-VtColorString -BackColor $color -Raw -TerminalType 'Code.exe')
			
			$VtColorCodeArray += [PSCustomObject]@{
				ColorName = $color; 
				DefaultForeColor = $DefaultForeColor; 
				DefaultBackColor = $DefaultBackColor; 
				PoShForeColor = $PoShForeColor; 
				PoShBackColor = $PoShBackColor; 
				VsCodeForeColor = $VsCodeForeColor; 
				VsCodeBackColor = $VsCodeBackColor
			}
			
		} # End ForEach
		
		If ($BlackAndWhite) {
			
			$VtColorCodeArray = $VtColorCodeArray | Where-Object {$_.ColorName -match "Black|White"}
			
		} # End If ($BlackAndWhite)
		
		If ($Quiet) {
			Return $VtColorCodeArray
		} Else {
			$VtColorCodeArray | Format-Table -Property ColorName, @{
				Label = "DFC"
				Expression = {
					$colorstr = ConvertTo-VtColorString -Raw -ForeColor $_.ColorName -BackColor $_.ColorName -TerminalType 'Default'
					#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
					#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
					# Escape key
					$e = [char]27
					# Magic string: VT escape sequences:
					# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
					#    - 0    Default    Returns all attributes to the default state prior to modification
					#"$e[${colorstr}m$("       ")${e}[0m"
					"$e[${colorstr}m$("Test")${e}[0m"
				}
			}, DefaultForeColor, DefaultBackColor, @{
				Label = "PFC"
				Expression = {
					$colorstr = ConvertTo-VtColorString -Raw -ForeColor $_.ColorName -BackColor $_.ColorName -TerminalType 'powershell.exe'
					#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
					#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
					# Escape key
					$e = [char]27
					# Magic string: VT escape sequences:
					# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
					#    - 0    Default    Returns all attributes to the default state prior to modification
					#"$e[${colorstr}m$("       ")${e}[0m"
					"$e[${colorstr}m$("Test")${e}[0m"
				}
			}, PoShForeColor, PoShBackColor, @{
				Label = "VFC"
				Expression = {
					$colorstr = ConvertTo-VtColorString -Raw -ForeColor $_.ColorName -BackColor $_.ColorName -TerminalType 'Code.exe'
					#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
					#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
					# Escape key
					$e = [char]27
					# Magic string: VT escape sequences:
					# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
					#    - 0    Default    Returns all attributes to the default state prior to modification
					#"$e[${colorstr}m$("       ")${e}[0m"
					"$e[${colorstr}m$("Test")${e}[0m"
				}
			}, VsCodeForeColor, VsCodeBackColor
		} # End If/Else ($Quiet)
		
	
	} Else { # End ElseIf ($VtColors)
		If ($BlackAndWhite) {
			$Colors = $Colors | Where-Object {$_ -match "Black|White"}
		}
		Return $Colors
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
} # End of Get-AllPowerShellColors function.
Set-Alias -Name 'Get-AllColors' -Value 'Get-AllPowerShellColors'
Set-Alias -Name 'Get-Colors' -Value 'Get-AllPowerShellColors'
Set-Alias -Name 'Get-ColorsList' -Value 'Get-AllPowerShellColors'
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function ConvertTo-VtColorString {
	<#
	.SYNOPSIS
	Converts a color string to an RGB VT color string.
	.DESCRIPTION
	Uses Virtual Terminal color codes, which greatly expands the range of colors available for use, and allows in-line text coloring.
	
	To find out if the type of PowerShell interface in use is compatible with Virtual Terminal colors, use the `(Get-AllPowerShellColors -ShowHostInfo).SupportsVirtualTerminal` command. These commands can also be used to view VT color compatibility: 
	 - `(Get-AllPowerShellColors -ShowHostInfo).SupportsVirtualTerminal`
	 - `Get-AllPowerShellColors -VtColors`
	 - `Get-AllPowerShellColors -List -VtColors`
	 - `Get-AllPowerShellColors -Grid -VtColors`
	
	How-to use:
	
	To activate the color codes, use magic opening and closing strings around the text you want to color. Or use -TextString parameter to add them automatically.
	
	# Magic strings:
	$colorstr = ConvertTo-VtColorString -ForeColor 'Green'
	#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
	#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
	# Escape key
	$e = [char]27
	# Magic string: VT escape sequences:
	# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
	#    - 0    Default    Returns all attributes to the default state prior to modification
	#"$e[${colorstr}m$("              ")${e}[0m"
	#"$e[${colorstr}m$("your text here")${e}[0m"
	
	.PARAMETER ForeColor
	Foreground color string. By default, uses the 16 different PowerShell colors. See `Get-AllPowerShellColors` command to list all colors.
	.PARAMETER BackColor
	Background color string. By default, uses the 16 different PowerShell colors. See `Get-AllPowerShellColors` command to list all colors.
	.PARAMETER TerminalType
	Pick the color set to use based on terminal type.
	
	-TerminalType "default"
	-TerminalType "powershell.exe"
	-TerminalType "Code.exe"
	-TerminalType "VSCodium.exe"
	.PARAMETER TextString
	Text string to return with magic string color code already applied. By default this function only returns the number code used in the magic string.
	.PARAMETER Raw
	For certain colors that seem to produce incorrect output in certain terminals, show that color as measured, instead of correcting it. See `Get-Help Get-AllPowerShellColors -Examples` command for examples of how some colors from different color sets can appear different or incorrect.
	.EXAMPLE
	ConvertTo-VtColorString -ForeColor Green
	ConvertTo-VtColorString -BackColor Green
	
	Demonstrating in-line colored text using magic strings:
	
	$colorstr = ConvertTo-VtColorString -ForeColor 'Green'
	# Escape key
	$e = [char]27
	# Magic string: VT escape sequences:
	# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
	#    - 0    Default    Returns all attributes to the default state prior to modification
	#"$e[${colorstr}m$("              ")${e}[0m"
	#"$e[${colorstr}m$("your text here")${e}[0m"
	"your $e[${colorstr}m$("green text")${e}[0m here"
	.EXAMPLE
	ConvertTo-VtColorString -ForeColor Green -TextString 'green text' -Verbose
	
	Use the -TextString parameter and this function will auto-add the magic strings to the output. This can be used in-line with normal text in several ways.
	
	Here is the function called in-line with other Write-Host test:
	
	    Write-Host "The $(ConvertTo-VtColorString -ForeColor Green -TextString 'green text') can be printed in-line with normal text."
	
	In-line colored text saved as a var and printed later using Write-Host:
	
	    $InlineText = ConvertTo-VtColorString -ForeColor Green -TextString 'green text'
	    Write-Host "Here is some $InlineText printed to the terminal."
	.NOTES
	Version Notes:
	v1.1.0: 2024-08-04
	Added features: -TextString parameter for auto-adding the opening and closing magic strings in output.
	v1.0.0: 2022-01-12
	16 color selection based on PowerShell's defaults. Foreground and background colors supported. 3 different terminal color sets.
	
	Original repository:
	https://github.com/Kerbalnut/MiniTaskMang-PoSh
	https://github.com/Kerbalnut/MiniTaskMang-PoSh/blob/main/public/SaveLoadSync.ps1
	Copied to:
	https://github.com/Kerbalnut/SleepTimerPoSh
	https://github.com/Kerbalnut/SleepTimerPoSh/blob/main/Start-SleepTimer.ps1
	
	Development Notes:
	# Magic strings:
	$colorstr = $_.Default
	#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
	#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
	# Escape key
	$e = [char]27
	# Magic string: VT escape sequences:
	# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
	#    - 0    Default    Returns all attributes to the default state prior to modification
	#"$e[${colorstr}m$("       ")${e}[0m"
	#"$e[${colorstr}m$("       ")${e}[0m"
	.LINK
	https://github.com/Kerbalnut/MiniTaskMang-PoSh
	https://github.com/Kerbalnut/SleepTimerPoSh
	.LINK
	Get-AllPowerShellColors
	.LINK
	https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
	https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Position = 0, Mandatory = $False)]
		[String]$ForeColor,
		[Parameter(Position = 1, Mandatory = $False)]
		[String]$BackColor,
		[Parameter(Position = 2, Mandatory = $False)]
		[ValidateSet("default","powershell.exe","powershell","posh","Code.exe","vscode","VSCodium.exe","vscodium",IgnoreCase = $True)]
		[String]$TerminalType,
		[Parameter(Mandatory = $False)]
		[String]$TextString,
		[switch]$Raw
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Function ConvertTo-DefaultVtColorString($ForeColor,$BackColor) {
		If ($ForeColor -and "$ForeColor" -ne "") {
			switch ($ForeColor) {
				'Black' { $fcolor = "30"; break }
				'Blue' { $fcolor = "34"; break }
				'Cyan' { $fcolor = "36"; break }
				'DarkBlue' { $fcolor = "38;2;0;0;128"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkCyan' { $fcolor = "38;2;0;128;128"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkGray' { $fcolor = "38;2;128;128;128"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkGreen' { $fcolor = "38;2;0;128;0"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkMagenta' { $fcolor = "38;2;188;63;188"; break } # Standard in posh terminal broken: taken from vscode colors
				'DarkRed' { $fcolor = "38;2;128;0;0"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkYellow' { $fcolor = "38;2;229;229;16"; break } # Standard in posh terminal broken: taken from vscode colors
				'Gray' { $fcolor = "38;2;192;192;192"; break } # Standard in vscode console broken: taken from powershell.exe terminal colors
				'Green' { $fcolor = "32"; break }
				'Magenta' { $fcolor = "35"; break }
				'Red' { $fcolor = "31"; break }
				'White' { $fcolor = "37"; break }
				'Yellow' { $fcolor = "33"; break }
				Default {
					Write-Warning "Given -ForeColor parameter '$ForeColor' could not be resolved. Reverting to default."
					#0 	Default 	Returns all attributes to the default state prior to modification
					#39 	Foreground Default 	Applies only the foreground portion of the defaults (see 0)
					#49 	Background Default 	Applies only the background portion of the defaults (see 0)
					$fcolor = "39"
				}
			} # switch
		} # End If ($ForeColor)
		If ($BackColor -and "$BackColor" -ne "") {
			switch ($BackColor) {
				'Black' { $bcolor = "40"; break }
				'Blue' { $bcolor = "44"; break }
				'Cyan' { $bcolor = "46"; break }
				'DarkBlue' { $bcolor = "48;2;0;0;128"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkCyan' { $bcolor = "48;2;0;128;128"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkGray' { $bcolor = "48;2;128;128;128"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkGreen' { $bcolor = "48;2;0;128;0"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkMagenta' { $bcolor = "48;2;188;63;188"; break } # Standard in posh terminal broken: taken from vscode colors
				'DarkRed' { $bcolor = "48;2;128;0;0"; break } # No analog to standardized vt colors: taken from powershell.exe terminal colors
				'DarkYellow' { $bcolor = "48;2;229;229;16"; break } # Standard in posh terminal broken: taken from vscode colors
				'Gray' { $bcolor = "48;2;192;192;192"; break } # Standard in vscode console broken: taken from powershell.exe terminal colors
				'Green' { $bcolor = "42"; break }
				'Magenta' { $bcolor = "45"; break }
				'Red' { $bcolor = "41"; break }
				'White' { $bcolor = "47"; break }
				'Yellow' { $bcolor = "43"; break }
				Default {
					Write-Warning "Given -BackColor parameter '$BackColor' could not be resolved. Reverting to default."
					#0 	Default 	Returns all attributes to the default state prior to modification
					#39 	Foreground Default 	Applies only the foreground portion of the defaults (see 0)
					#49 	Background Default 	Applies only the background portion of the defaults (see 0)
					$bcolor = "49"
				}
			} # switch
		} # End If ($BackColor)
		If ($ForeColor -And $BackColor) {
			$VTColorString = $fcolor + ";" + $bcolor
		} Else {
			If ($ForeColor) {
				$VTColorString = $fcolor
			} ElseIf ($BackColor) {
				$VTColorString = $bcolor
			}
		}
		Return $VTColorString
	} # End Function ConvertTo-DefaultVtColorString
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Function ConvertTo-PoshTerminalVtColorString($ForeColor,$BackColor) {
		If ($ForeColor -and "$ForeColor" -ne "") {
			switch ($ForeColor) {
				'Black' { $fcolor = "38;2;0;0;0"; break }
				'Blue' { $fcolor = "38;2;0;0;255"; break }
				'Cyan' { $fcolor = "38;2;0;255;255"; break }
				'DarkBlue' { $fcolor = "38;2;0;0;128"; break }
				'DarkCyan' { $fcolor = "38;2;0;128;128"; break }
				'DarkGray' { $fcolor = "38;2;128;128;128"; break }
				'DarkGreen' { $fcolor = "38;2;0;128;0"; break }
				'DarkMagenta' {
					If ($Raw) {
						$fcolor = "38;2;1;36;86"; break # Standard, (broken): appears as the same color of standard (blue) powershell terminal background
					} Else {
						$fcolor = "38;2;188;63;188"; break # taken from vscode colors
					}
				}
				'DarkRed' { $fcolor = "38;2;128;0;0"; break }
				'DarkYellow' {
					If ($Raw) {
						$fcolor = "38;2;238;237;240"; break # Standard, (broken): appears as a lighter gray than 'Gray', almost white but not quite
					} Else {
						$fcolor = "38;2;229;229;16"; break # taken from vscode colors
					}
				}
				'Gray' { $fcolor = "38;2;192;192;192"; break }
				'Green' { $fcolor = "38;2;0;255;0"; break }
				'Magenta' { $fcolor = "38;2;255;0;255"; break }
				'Red' { $fcolor = "38;2;255;0;0"; break }
				'White' { $fcolor = "38;2;255;255;255"; break }
				'Yellow' { $fcolor = "38;2;255;255;0"; break }
				Default {
					Write-Warning "Given -ForeColor parameter '$ForeColor' could not be resolved. Reverting to default."
					#0 	Default 	Returns all attributes to the default state prior to modification
					#39 	Foreground Default 	Applies only the foreground portion of the defaults (see 0)
					#49 	Background Default 	Applies only the background portion of the defaults (see 0)
					$fcolor = "39"
				}
			} # switch
		} # End If ($ForeColor)
		If ($BackColor -and "$BackColor" -ne "") {
			switch ($BackColor) {
				'Black' { $bcolor = "48;2;0;0;0"; break }
				'Blue' { $bcolor = "48;2;0;0;255"; break }
				'Cyan' { $bcolor = "48;2;0;255;255"; break }
				'DarkBlue' { $bcolor = "48;2;0;0;128"; break }
				'DarkCyan' { $bcolor = "48;2;0;128;128"; break }
				'DarkGray' { $bcolor = "48;2;128;128;128"; break }
				'DarkGreen' { $bcolor = "48;2;0;128;0"; break }
				'DarkMagenta' {
					If ($Raw) {
						$bcolor = "48;2;1;36;86"; break # Standard, (broken): appears as the same color of standard (blue) powershell terminal background
					} Else {
						$bcolor = "48;2;188;63;188"; break # taken from vscode colors
					}
				}
				'DarkRed' { $bcolor = "48;2;128;0;0"; break }
				'DarkYellow' {
					If ($Raw) {
						$bcolor = "48;2;238;237;240"; break # Standard, (broken): appears as a lighter gray than 'Gray', almost white but not quite
					} Else {
						$bcolor = "48;2;229;229;16"; break # taken from vscode colors
					}
				}
				'Gray' { $bcolor = "48;2;192;192;192"; break }
				'Green' { $bcolor = "48;2;0;255;0"; break }
				'Magenta' { $bcolor = "48;2;255;0;255"; break }
				'Red' { $bcolor = "48;2;255;0;0"; break }
				'White' { $bcolor = "48;2;255;255;255"; break }
				'Yellow' { $bcolor = "48;2;255;255;0"; break }
				Default {
					Write-Warning "Given -BackColor parameter '$BackColor' could not be resolved. Reverting to default."
					#0 	Default 	Returns all attributes to the default state prior to modification
					#39 	Foreground Default 	Applies only the foreground portion of the defaults (see 0)
					#49 	Background Default 	Applies only the background portion of the defaults (see 0)
					$bcolor = "49"
				}
			} # switch
		} # End If ($BackColor)
		If ($ForeColor -And $BackColor) {
			$VTColorString = $fcolor + ";" + $bcolor
		} Else {
			If ($ForeColor) {
				$VTColorString = $fcolor
			} ElseIf ($BackColor) {
				$VTColorString = $bcolor
			}
		}
		Return $VTColorString
	} # End Function ConvertTo-PoshTerminalVtColorString
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Function ConvertTo-VscodeVtColorString($ForeColor,$BackColor) {
		If ($ForeColor -and "$ForeColor" -ne "") {
			switch ($ForeColor) {
				'Black' { $fcolor = "38;2;0;0;0"; break }
				'Blue' { $fcolor = "38;2;59;142;234"; break }
				'Cyan' { $fcolor = "38;2;41;184;219"; break }
				'DarkBlue' { $fcolor = "38;2;0;0;128"; break }
				'DarkCyan' { $fcolor = "38;2;0;128;128"; break }
				'DarkGray' { $fcolor = "38;2;128;128;128"; break }
				'DarkGreen' { $fcolor = "38;2;0;128;0"; break }
				'DarkMagenta' { $fcolor = "38;2;188;63;188"; break }
				'DarkRed' { $fcolor = "38;2;128;0;0"; break }
				'DarkYellow' { $fcolor = "38;2;229;229;16"; break }
				'Gray' {
					If ($Raw) {
						$fcolor = "38;2;229;229;229"; break # Standard, (broken): appears exact same as vscode white
					} Else {
						$fcolor = "38;2;192;192;192"; break # taken from powershell.exe terminal colors
					}
				}
				'Green' { $fcolor = "38;2;35;209;139"; break }
				'Magenta' { $fcolor = "38;2;214;112;214"; break }
				'Red' { $fcolor = "38;2;241;76;76"; break }
				'White' { $fcolor = "38;2;229;229;229"; break }
				'Yellow' { $fcolor = "38;2;245;245;67"; break }
				Default {
					Write-Warning "Given -ForeColor parameter '$ForeColor' could not be resolved. Reverting to default."
					#0 	Default 	Returns all attributes to the default state prior to modification
					#39 	Foreground Default 	Applies only the foreground portion of the defaults (see 0)
					#49 	Background Default 	Applies only the background portion of the defaults (see 0)
					$fcolor = "39"
				}
			} # switch
		} # End If ($ForeColor)
		If ($BackColor -and "$BackColor" -ne "") {
			switch ($BackColor) {
				'Black' { $bcolor = "48;2;30;30;30"; break }
				'Blue' { $bcolor = "48;2;59;142;234"; break }
				'Cyan' { $bcolor = "48;2;41;184;219"; break }
				'DarkBlue' { $bcolor = "48;2;0;0;128"; break }
				'DarkCyan' { $bcolor = "48;2;0;128;128"; break }
				'DarkGray' { $bcolor = "48;2;128;128;128"; break }
				'DarkGreen' { $bcolor = "48;2;0;128;0"; break }
				'DarkMagenta' { $bcolor = "48;2;188;63;188"; break }
				'DarkRed' { $bcolor = "48;2;128;0;0"; break }
				'DarkYellow' { $bcolor = "48;2;229;229;16"; break }
				'Gray' {
					If ($Raw) {
						$bcolor = "48;2;229;229;229"; break # Standard, (broken): appears exact same as vscode white
					} Else {
						$bcolor = "48;2;192;192;192"; break # taken from powershell.exe terminal colors
					}
				}
				'Green' { $bcolor = "48;2;35;209;139"; break }
				'Magenta' { $bcolor = "48;2;214;112;214"; break }
				'Red' { $bcolor = "48;2;241;76;76"; break }
				'White' { $bcolor = "48;2;229;229;229"; break }
				'Yellow' { $bcolor = "48;2;245;245;67"; break }
				Default {
					Write-Warning "Given -BackColor parameter '$BackColor' could not be resolved. Reverting to default."
					#0 	Default 	Returns all attributes to the default state prior to modification
					#39 	Foreground Default 	Applies only the foreground portion of the defaults (see 0)
					#49 	Background Default 	Applies only the background portion of the defaults (see 0)
					$bcolor = "49"
				}
			} # switch
		} # End If ($BackColor)
		If ($ForeColor -And $BackColor) {
			$VTColorString = $fcolor + ";" + $bcolor
		} Else {
			If ($ForeColor) {
				$VTColorString = $fcolor
			} ElseIf ($BackColor) {
				$VTColorString = $bcolor
			}
		}
		Return $VTColorString
	} # End Function ConvertTo-VscodeVtColorString
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$SubFunctionParams = @{}
	If ($ForeColor -and "$ForeColor" -ne "") {
		Write-Verbose "-ForeColor activated: `"$ForeColor`""
		$SubFunctionParams += @{ForeColor = $ForeColor}
	}
	If ($BackColor -and "$BackColor" -ne "") {
		Write-Verbose "-BackColor activated: `"$BackColor`""
		$SubFunctionParams += @{BackColor = $BackColor}
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($TerminalType -ieq "powershell" -Or $TerminalType -ieq "posh") {
		$TerminalType = "powershell.exe"
	}
	If ($TerminalType -ieq "vscode") {
		$TerminalType = "Code.exe"
	}
	If ($TerminalType -ieq "vscodium") {
		$TerminalType = "VSCodium.exe"
	}
	switch ($TerminalType) {
		'default' {
			Write-Verbose "-TerminalType: Default colors chosen. (Explicit)"
			$VTColorString = ConvertTo-DefaultVtColorString @SubFunctionParams
		} # 'default'
		'powershell.exe' {
			Write-Verbose "-TerminalType: powershell.exe terminal colors chosen."
			$VTColorString = ConvertTo-PoshTerminalVtColorString @SubFunctionParams
		} # 'powershell.exe'
		'Code.exe' {
			Write-Verbose "-TerminalType: vscode (Code.exe) console colors chosen."
			$VTColorString = ConvertTo-VscodeVtColorString @SubFunctionParams
		} # 'Code.exe'
		'VSCodium.exe' {
			Write-Verbose "-TerminalType: VSCodium.exe console colors chosen."
			$VTColorString = ConvertTo-VscodeVtColorString @SubFunctionParams
		} # 'VSCodium.exe'
		Default {
			Write-Verbose "-TerminalType: Default colors chosen. (Unspecified, failover to default)"
			$VTColorString = ConvertTo-DefaultVtColorString @SubFunctionParams
		} # Default
	} # switch
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# Magic strings:
	#$colorstr = $_.Default
	#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
	#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
	# Escape key
	#$e = [char]27
	# Magic string: VT escape sequences:
	# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
	#    - 0    Default    Returns all attributes to the default state prior to modification
	#"$e[${colorstr}m$("       ")${e}[0m"
	#"$e[${colorstr}m$("       ")${e}[0m"
	If ($TextString -and "$TextString" -ne "") {
		Write-Verbose "-TextString: Generate magic string for coloring text '$TextString'"
		# Magic strings:
		$colorstr = $VTColorString
		#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
		#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences#text-formatting
		# Escape key
		$e = [char]27
		# Magic string: VT escape sequences:
		# - ESC [ <n> m    Set the format of the screen and text as specified by <n>
		#    - 0    Default    Returns all attributes to the default state prior to modification
		#"$e[${colorstr}m$("       ")${e}[0m"
		#"$e[${colorstr}m$("       ")${e}[0m"
		#Return "$e[${colorstr}m$("$TextString")${e}[0m"
		$VTColorString = "$e[${colorstr}m$("$TextString")${e}[0m"
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return $VTColorString
} # End of ConvertTo-VtColorString function.
#-----------------------------------------------------------------------------------------------------------------------

Write-Verbose -Message "[$ScriptName]: End loading Functions"
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
Write-Verbose -Message "[$ScriptName]: Starting main script logic"

If ($SetPower) {
	Write-Verbose -Message "[$ScriptName]: Activating Power state command"
	$PowerStateParams = @{
		DisableWake = $DisableWake
		Force = $Force
	}
	Set-PowerState -Action $Action @PowerStateParams @CommonParameters @RiskMitigationParameters
}


Write-Verbose -Message "[$ScriptName]: End of script file."
# [/Main]---------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------


