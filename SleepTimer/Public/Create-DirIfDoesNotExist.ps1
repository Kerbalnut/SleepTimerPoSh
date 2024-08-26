
function Create-DirIfDoesNotExist {
	[CmdletBinding(
		DefaultParameterSetName = 'StringName',
		SupportsShouldProcess = $True
	)]
	param (
		[Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
		$InputPath
	)
	
	begin {
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
		#$FunctionPath = $PSCommandPath
		$FunctionPath = $MyInvocation.MyCommand.Definition
		$FunctionName = $MyInvocation.MyCommand.Name
		Write-Verbose -Message "[$FunctionName]: Starting function `"$FunctionPath`""
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	} # /begin
	
	process {
		Write-Verbose -Message "[$FunctionName]: Processing function"
		If (!(Test-Path -Path $InputPath)) {
			Write-Warning "'$InputPath' does not exist."
			Write-Host "Creating '$InputPath'"
			New-Item -Path $InputPath -ItemType Directory
		}
	} # /process
	
	end {
		Write-Verbose -Message "[$FunctionName]: End function."
	} # /end
} # / function Create-DirIfDoesNotExist
