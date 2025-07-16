
#-----------------------------------------------------------------------------------------------------------------------
function Start-SoundToneAlarmJingle {
	<#
	.SYNOPSIS
	Plays a sequence of tones.
	.DESCRIPTION
	Uses console beep commands to create a tone sequence jingle for an alarm or audio notification.
	.PARAMETER Repeat
	How many times to repeat the sound/sequence of tones.
	.PARAMETER Pause
	Time in milliseconds to pause between multiple alarm sounds repeating.
	.PARAMETER Jingle
	Use and integer to choose which type of sound to play.
	
	1 - Alarm Jingle
	2 - Sunshine of your Love
	.EXAMPLE
	Start-SoundToneAlarmJingle -Verbose
	
	Use the verbose switch to see each step of the function:
	
	Start-SoundToneAlarmJingle 3 250 -Verbose
	
	Start-SoundToneAlarmJingle 4 200 2 -Verbose
	
	.NOTES
	How-to create sounds with PowerShell:
	[console]::beep( <tone value> , <duration value> )
	  <tone value> - Microsoft recommendation between 190-8,500
	  <tone value> - PowerShell accepted values between 37-32,767
	For Example:
	[console]::beep(1000,500)
	#>
	[CmdletBinding()]
	param (
		# Number of times to play the tone sequence
		[Parameter(Position = 1, Mandatory = $False)]
		[int]$Repeat = 1,
		
		# The pause in milliseconds to take between sequences when playing multiple
		[Parameter(Position = 2, Mandatory = $False)]
		[int]$Pause = 500,
		
		# Chooses which jingle to play.
		[Parameter(Position = 3, Mandatory = $False)]
		[int]$Jingle = 1
	)
	
	begin {
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# Get this function's path:
		$FunctionPath = $PSCommandPath
		#$FunctionContent = $MyInvocation.MyCommand.Definition
		$FunctionName = $MyInvocation.MyCommand.Name
		#$FunctionName = $MyInvocation.MyCommand
		Write-Verbose -Message "[$FunctionName]: Starting function `"$FunctionPath`"/`"$FunctionName`""
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Executing Begin block"
		
		# PowerShell Beep Notes:
		#[console]::beep( <tone value> , <duration value> )
		#  <tone value> - Microsoft recommendation between 190-8,500
		#  <tone value> - PowerShell accepted values between 37-32,767
		#[console]::beep(1000,500)
		
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		
		Write-Verbose -Message "[$FunctionName]: Sub functions"
		#-----------------------------------------------------------------------------------------------------------------------
		#-----------------------------------------------------------------------------------------------------------------------
		
		function Play-AlarmJingle1 {
			[CmdletBinding()]
			param ()
			
			[console]::beep(1500,250)
			[console]::beep(1900,250)
			[console]::beep(2000,250)
			[console]::beep(1900,250)
			[console]::beep(1900,250)
		} # End / function Play-AlarmJingle1
		
		function Play-SunshineOfYourLove {
			[CmdletBinding()]
			param ()
			
			[console]::beep(800,200)
			[console]::beep(800,200)
			[console]::beep(760,200)
			[console]::beep(800,350)
			Start-Sleep -Milliseconds 100
			
			[console]::beep(600,400)
			Start-Sleep -Milliseconds 70
			[console]::beep(580,400)
			Start-Sleep -Milliseconds 70
			[console]::beep(560,400)
			Start-Sleep -Milliseconds 70
			
			[console]::beep(460,200)
			[console]::beep(540,500)
			[console]::beep(460,300)
		} # End / function Play-SunshineOfYourLove
		
		#-----------------------------------------------------------------------------------------------------------------------
		#-----------------------------------------------------------------------------------------------------------------------
		Write-Verbose -Message "[$FunctionName]: End sub functions"
		
	} # End begin block
	
	process {
		Write-Verbose -Message "[$FunctionName]: Executing Process block"
		
		for ($i = 0; $i -lt $Repeat; $i++) {
			# Track verbose messages
			If ( $Repeat -eq 1 ) {
				Write-Verbose -Message "[$FunctionName]: Playing sound . . . "
			} ElseIf ( $Repeat -gt 1 ) {
				If ( ($Repeat - $i) -gt 1 ) {
					Write-Verbose -Message "[$FunctionName]: Playing sound . . . ($(($Repeat - $i)) more times)"
				} Else {
					Write-Verbose -Message "[$FunctionName]: Playing sound . . . ($(($Repeat - $i)) more time)"
				}
			} Else {
				Write-Warning "It should be impossible for this message to dispaly. You broke it."
				Write-Verbose -Message "[$FunctionName]: Playing sound (impossible) . . . "
			}
			
			# Play tone sequence
			If ($Jingle -eq 1) {
				Play-AlarmJingle1
			} ElseIf ($Jingle -eq 2) {
				Play-SunshineOfYourLove
			} Else {
				Play-AlarmJingle1
			}
			
			# Pause between sequences
			If ( ($Repeat - $i) -gt 1 ) {
				Write-Verbose -Message "[$FunctionName]: Pausing for $Pause milliseconds"
				Start-Sleep -Milliseconds $Pause
			}
		} # End / for ($i = 0; $i -lt $Repeat; $i++) {
		
		Write-Verbose -Message "[$FunctionName]: Completed Process block"
	} # End process block
	
	end {
		# End of function
		Write-Verbose -Message "[$FunctionName]: Executing End block"
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		Write-Verbose -Message "[$FunctionName]: Ending function"
		Return
	}
} # End of Start-SoundToneAlarmJingle function.
#-----------------------------------------------------------------------------------------------------------------------

