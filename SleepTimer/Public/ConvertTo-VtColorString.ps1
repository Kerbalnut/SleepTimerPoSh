
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
	
	To activate the color codes, use opening and closing magic strings around the text you want to color. Or use -TextString parameter to add them automatically.
	
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
