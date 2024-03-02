param(
[string]$arguments
)

if (($arguments -eq "w10-basic") -or ($arguments -eq "w11-basic")) {
    Set-Location $env:userprofile
    Set-executionpolicy -Force -executionpolicy unrestricted; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -Force;
    Install-Module -Name tom42tools -Force -AllowClobber;
    Import-Module -Name tom42tools -Force;
    if (((Get-ComputerInfo | Select-Object -expand OsName) -match 11)) { Set-w11basic }
    if (((Get-ComputerInfo | Select-Object -expand OsName) -match 10)) { Set-w10basic }
    Restart-Computer -Force
} else {
    Set-Location $env:userprofile
    Set-executionpolicy -Force -executionpolicy unrestricted; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -Force;
    New-PSDrive -Name "Z" -PSProvider "FileSystem" -Root "\\192.168.1.75\share" -Persist -Scope Global
    Install-Module -Name tom42tools -Force -AllowClobber;
    Import-Module -Name tom42tools -Force;
    Set-Activation
    Install-Choco
    choco install boxstarter
    Restore-backup $arguments
}
