Import-Module ThreadJob -ErrorAction Stop

#handle PS2
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}
$ModuleRoot = $PSScriptRoot

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Types = @( Get-ChildItem -Path $PSScriptRoot\Types\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private + $Types)) {
    Try {
        Write-Verbose -Message "Importing $($import.fullname)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import $($import.fullname): $_"
    }
}

foreach ($verb in @('Read', 'Stop', 'Get', 'Receive', 'Wait', 'Remove')) {
    $alias_name = "$verb-KafkaConsumer"
    $aliases += @($alias_name)
	New-Alias -Name $alias_name -Value "$verb-Job" -Force
}

Export-ModuleMember -Function ($Public | Select-Object -ExpandProperty BaseName) -Alias $aliases
