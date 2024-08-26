
BeforeAll {
    $here = Split-Path -Parent $PSCommandPath
    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'
    . "$here\$sut"
}

Describe "'Get-AllPowerShellColors' Function Functional Tests" {

    Context "Accepting input data" {
        BeforeAll {
            #region Arrange
            $inputData = 10
            #endregion
        }

        #region Act&Assert
        It "should accept input from the parameter" {
            $guids = Get-AllPowerShellColors -Number $inputData
            $guids | Should -HaveCount $inputData
        }

        It "should accept input from the pipeline" {
            $guids = $inputData | Get-AllPowerShellColors
            $guids | Should -HaveCount $inputData
        }
        #endregion
    }
}
