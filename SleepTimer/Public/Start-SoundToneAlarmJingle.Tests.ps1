
BeforeAll {
    $here = Split-Path -Parent $PSCommandPath
    $sut = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'
    . "$here\$sut"
}

Describe "'Start-SoundToneAlarmJingle' Function Functional Tests" {

    Context "Accepting input data" {
        BeforeAll {
            #region Arrange
            $inputData = 10
            #endregion
        }

        #region Act&Assert
        It "should accept input from the parameter" {
            $guids = Start-SoundToneAlarmJingle -Number $inputData
            $guids | Should -HaveCount $inputData
        }

        It "should accept input from the pipeline" {
            $guids = $inputData | Start-SoundToneAlarmJingle
            $guids | Should -HaveCount $inputData
        }
        #endregion
    }
}
