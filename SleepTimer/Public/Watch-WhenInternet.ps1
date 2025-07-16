
#-----------------------------------------------------------------------------------------------------------------------
Function Watch-WhenInternet {
	<#
	.SYNOPSIS
	Watch and wait for a notification when the internet's back up.
	.DESCRIPTION
	Will continuously ping several IP addresses such as 8.8.8.8, 8.8.4.4, 1.1.1.1, etc. until canceled or the internet connection is restored.
	.PARAMETER TestDowntime
	For testing purposes only.
	.NOTES
	#>
	#Requires -Version 4
	[CmdletBinding(DefaultParameterSetName = 'None')]
	Param(
		[Parameter(DontShow)]
		[timespan]$TestDowntime
	)
	
	begin {
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
		Write-Verbose -Message "[$FunctionName]: Starting function '$FunctionName' `"$FunctionPath`""
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Executing Begin block"
		Write-Verbose -Message "[$FunctionName]: Set up params"
		
		$StartTime = Get-Date
		
		Write-Verbose "[$FunctionName]: End of Begin block."
	} # End of Begin block
	
	Process {
		Write-Verbose -Message "[$FunctionName]: Executing Process block"
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		$NoConnection = $True
		while ($NoConnection) {
			
			If ( (Test-NetConnection 8.8.8.8).PingSucceeded ) {
				#"Yes"
				$NoConnection = $False
				Break
			} Else {
				#"No"
				$NoConnection = $True
				If ( (Test-NetConnection 8.8.4.4).PingSucceeded ) {
					#"Yes"
					$NoConnection = $False
					Break
				} Else {
					#"No"
					$NoConnection = $True
					If ( (Test-NetConnection 1.1.1.1).PingSucceeded ) {
						#"Yes"
						$NoConnection = $False
						Break
					} Else {
						#"No"
						$NoConnection = $True
					} # / If ( (Test-NetConnection 1.1.1.1).PingSucceeded ) 
				} # / If ( (Test-NetConnection 8.8.4.4).PingSucceeded ) 
			} # / If ( (Test-NetConnection 8.8.8.8).PingSucceeded ) 
		} # / while ($NoConnection) 
		
		Write-Verbose -Message "[$FunctionName]: End of loop!"
		
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Completed Process block"
	} # End of Process block
	
	End {
		Write-Verbose -Message "[$FunctionName]: Executing End block"
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		# Display connection restored message:
		
		$EndTime = Get-Date
		
		If (($TestDowntime)) { # -or $null -ne $TestDowntime -or $TestDowntime -ne ""
			Write-Verbose -Message "[$FunctionName]: TEST MODE: Using provided downtime `$TestDowntime"
			[timespan]$Downtime = $TestDowntime
		} Else {
			Write-Verbose -Message "[$FunctionName]: Calculating downtime: (Get-Date) - `$StartTime"
			[timespan]$Downtime = (Get-Date) - $StartTime
		}
		
		Write-Host "'                                                      '" -ForegroundColor Black -BackgroundColor Yellow
		Write-Host "'  ---------- INTERNET CONNECTION RESTORED ----------  '" -ForegroundColor Black -BackgroundColor Yellow
		Write-Host "'                                                      '" -ForegroundColor Black -BackgroundColor Yellow
		
		#Write-Host "'    Tracking started: 11/21/2024 10:41:41 PM       '" -ForegroundColor Black -BackgroundColor Yellow
		$StartTimeString = Get-Date -Date $StartTime -Format G
		$WriteString = "'    Tracking started: $StartTimeString"
		$WriteString = $WriteString.PadRight(55) + "'"
		Write-Host -Object $WriteString -ForegroundColor Black -BackgroundColor Yellow
		
		Write-Host "'                                                      '" -ForegroundColor Black -BackgroundColor Yellow
		
		$DowntimeStr = ""
		If ($Downtime.TotalDays -ge 1) {
			$DowntimeStr = $DowntimeStr + ($Downtime.Days) + " day(s) "
		}
		If ($Downtime.TotalDays -ge 1 -or $Downtime.TotalHours -ge 1) {
			$DowntimeStr = $DowntimeStr + ($Downtime.Hours) + " hour(s) "
		}
		$DowntimeStr = $DowntimeStr + ($Downtime.Minutes) + " min(s) " + ($Downtime.Seconds) + "sec"
		$WriteString = "' Downtime tracked: $DowntimeStr"
		$WriteString = $WriteString.PadRight(55) + "'"
		Write-Host -Object $WriteString -ForegroundColor Black -BackgroundColor Yellow
		
		Write-Host "'                                                      '" -ForegroundColor Black -BackgroundColor Yellow
		
		$EndTimeString = Get-Date -Date $EndTime -Format G
		$WriteString = "' Connection restored: $EndTimeString"
		$WriteString = $WriteString.PadRight(55) + "'"
		Write-Host -Object $WriteString -ForegroundColor Black -BackgroundColor Yellow
		
		Write-Host "'                                                      '" -ForegroundColor Black -BackgroundColor Yellow
		Write-Host "'  ---------- INTERNET CONNECTION RESTORED ----------  '" -ForegroundColor Black -BackgroundColor Yellow
		Write-Host "'                                                      '" -ForegroundColor Black -BackgroundColor Yellow
		
		# Play notification sound:
		
		If ($PlayJingle -eq 1) {
			Start-SoundToneAlarmJingle 3 500 @CommonParameters
		} ElseIf ($PlayJingle -eq 2) {
			Start-SoundToneAlarmJingle 4 200 2 @CommonParameters
		} ElseIf ($PlayJingle -eq 'all') {
			Start-SoundToneAlarmJingle 3 500 @CommonParameters
			Start-SoundToneAlarmJingle 4 200 2 @CommonParameters
		} ElseIf (($PlayJingle) -or $null -ne $PlayJingle -or $PlayJingle -ne "") {
			Write-Warning "-PlayJingle parameter supplied but input not recognized. Input should be integer 1-2 or 'all'."
			Start-SoundToneAlarmJingle 4 200 2 @CommonParameters
		} ElseIf ($PlayJingle -eq 'off') {
			Write-Verbose -Message "[$FunctionName]: Jingle sound skipped."
		} Else {
			Start-SoundToneAlarmJingle 3 500 @CommonParameters
		}
		
		# Open website URL:
		
		$OpenUrl = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
		
		
		If ($OpenWebpageWhenInternter) {
			Start-Process $OpenUrl
		}
		
		
		Write-Verbose -Message "[$FunctionName]: Ending function"
		Return
	} # End of End block
} # End of Watch-WhenInternet function.
#-----------------------------------------------------------------------------------------------------------------------

