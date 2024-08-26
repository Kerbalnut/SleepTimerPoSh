
Function Format-FileSize {
	[CmdletBinding()]
	Param (
		$Size
	)
	If ($Size -gt 1TB) {
		[string]::Format("{0:0.00} TB", $Size / 1TB)
	} ElseIf ($Size -gt 1GB) {
		[string]::Format("{0:0.00} GB", $Size / 1GB)
	} ElseIf ($Size -gt 1MB) {
		[string]::Format("{0:0.00} MB", $Size / 1MB)
	} ElseIf ($Size -gt 1KB) {
		[string]::Format("{0:0.00} KB", $Size / 1KB)
	} ElseIf ($Size -ge 0) {
		[string]::Format("{0:0.00} B", $Size)
	}
} # / Function Format-FileSize 
