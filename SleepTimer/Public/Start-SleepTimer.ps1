
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
