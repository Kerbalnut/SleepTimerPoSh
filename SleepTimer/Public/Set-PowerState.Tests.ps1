
BeforeAll {
    $here = Split-Path -Parent $PSCommandPath
    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'
    . "$here\$sut"
}

Describe "'Set-PowerState' Function Functional Tests" {

    Context "Accepting input data" {
        BeforeAll {
            #region Arrange
            $inputData = 10
            #endregion
        }

        #region Act&Assert
        It "should accept input from the parameter" {
            $guids = Set-PowerState -Number $inputData
            $guids | Should -HaveCount $inputData
        }

        It "should accept input from the pipeline" {
            $guids = $inputData | Set-PowerState
            $guids | Should -HaveCount $inputData
        }
        #endregion
    }
	
	
	
	[ValidateSet('Sleep','Suspend','Standby','Hibernate','Lock','Reboot','Restart','Shutdown','Stop','LogOut','SignOut','LogOff','SignOff')]
		[Alias('PowerAction')]
		[String]$Action = 'Sleep',
		
		#[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'PowerState')]
		#[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Suspend,
		
		[Switch]$DisableWake,
		[Switch]$Force
	
	
	
    Context "Accepting input data" {
        BeforeAll {
            #region Arrange
            $inputData = 10
            #endregion
        }

        #region Act&Assert
        It "should accept input from the parameter" {
            $guids = Set-PowerState -Number $inputData
            $guids | Should -HaveCount $inputData
        }

        It "should accept input from the pipeline" {
            $guids = $inputData | Set-PowerState
            $guids | Should -HaveCount $inputData
        }
        #endregion
    }
	
}
