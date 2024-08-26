
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
