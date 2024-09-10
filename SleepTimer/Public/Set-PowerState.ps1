
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
#Set-PowerState -Action Sleep @CommonParameters -WhatIf #@RiskMitigationParameters
#Set-PowerState -Action Hibernate @CommonParameters #-WhatIf #@RiskMitigationParameters
#return
