param(
[string]$arguments
)

if (($arguments -eq "w10-basic") -or ($arguments -eq "w11-basic")) {
    Set-Location $env:userprofile
    Set-executionpolicy -Force -executionpolicy unrestricted; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -Force;
    Install-Module -Name tom42tools -Force -AllowClobber;
    Import-Module -Name tom42tools -Force;
    Set-Activation
    Install-Choco
    (New-Object System.Net.WebClient).DownloadFile("https://t0m.pw/BasicChoco", "$env:TEMP\packages.config")  
    Choco install "$env:TEMP\packages.config"
    OOSU10 C:\Users\tom42\Desktop\ooshutup10.cfg /quiet

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
