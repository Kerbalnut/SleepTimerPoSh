
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
