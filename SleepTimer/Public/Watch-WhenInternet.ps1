
#-----------------------------------------------------------------------------------------------------------------------
Function Watch-WhenInternet {
	<#
	.SYNOPSIS
	Watch and wait for a notification when the internet's back up.
	.DESCRIPTION
	.NOTES
	#>
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = 'None')]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "Path")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p')]
		[String]$Path
		
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
		Write-Verbose -Message "[$FunctionName]: Starting function `"$FunctionPath`""
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Executing Begin block"
		Write-Verbose -Message "[$FunctionName]: Set up params"
		
		$StartTime = Get-Date
		
		#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 1)
		#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 5)
		#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Hours 2 -Minutes 30)
		
		#
		# First test if connection is active:
		If ( (Test-NetConnection 8.8.8.8).PingSucceeded ) {
			"Yes"
			$IntenetConn = $True
		} Else {
			# "No"
			If ( (Test-NetConnection 8.8.4.4).PingSucceeded ) {
				"Yes"
				$IntenetConn = $True
			} Else {
				# "No"
				If ( (Test-NetConnection 1.1.1.1).PingSucceeded ) {
					"Yes"
					$IntenetConn = $True
				} Else {
					"No connection"
					$IntenetConn = $False
				} # End / If ( (Test-NetConnection 1.1.1.1).PingSucceeded ) 
			} # End / If ( (Test-NetConnection 8.8.4.4).PingSucceeded ) 
		} # End / If ( (Test-NetConnection 8.8.8.8).PingSucceeded ) 
		#>
		
		Write-Verbose "[$FunctionName]: End of Begin block."
	} # End of Begin block
	
	Process {
		Write-Verbose -Message "[$FunctionName]: Executing Process block"
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		If ($IntenetConn -eq $False) {
			$NoConnection = $True
			Write-Host "No internet connection detected. Pinging IP addresses:"
			while ($NoConnection) {
				
				If ( (Test-NetConnection 8.8.8.8).PingSucceeded ) {
					#"Yes"
					$NoConnection = $False
				} Else {
					#"No"
					$NoConnection = $True
					If ( (Test-NetConnection 8.8.4.4).PingSucceeded ) {
						#"Yes"
						$NoConnection = $False
					} Else {
						#"No"
						$NoConnection = $True
						If ( (Test-NetConnection 1.1.1.1).PingSucceeded ) {
							#"Yes"
							$NoConnection = $False
						} Else {
							#"No"
							$NoConnection = $True
						} # / If ( (Test-NetConnection 1.1.1.1).PingSucceeded ) 
					} # / If ( (Test-NetConnection 8.8.4.4).PingSucceeded ) 
				} # / If ( (Test-NetConnection 8.8.8.8).PingSucceeded ) 
			} # / while ($NoConnection) 
			
			Write-Host "End of loop!"
			
		} # / If ($IntenetConn -eq $False) 
		
		
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Completed Process block"
	} # End of Process block
	End {
		Write-Verbose -Message "[$FunctionName]: Executing End block"
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		
		
		
		Write-Host "                                                      " -ForegroundColor Black -BackgroundColor Green
		Write-Host "             INTERNET CONNECTION RESTORED             " -ForegroundColor Black -BackgroundColor Green
		Write-Host "                                                      " -ForegroundColor Black -BackgroundColor Green
		
		Write-Verbose -Message "[$FunctionName]: Ending function"
		Return
	} # End of End block
} # End of Watch-WhenInternet function.
#-----------------------------------------------------------------------------------------------------------------------

