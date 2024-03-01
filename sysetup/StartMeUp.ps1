param(
[string]$arguments
)

if (($arguments -eq "w10-basic") -or ($arguments -eq "w11-basic")) {
    Set-Location $env:userprofile
    Set-executionpolicy -Force -executionpolicy unrestricted; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    Install-PackageProvider -Name NuGet -Force;
    Install-Module -Name tom42tools -Force -AllowClobber;
    Import-Module -Name tom42tools -Force;
    function Set-w11basic {
        Set-Activation
        Install-Choco
        (New-Object System.Net.WebClient).DownloadFile("https://t0m.pw/BasicChoco", "$env:TEMP\packages.config")  
        Choco install "$env:TEMP\packages.config"
        (New-Object System.Net.WebClient).DownloadFile("https://t0m.pw/shutup10", "$env:TEMP\ooshutup10.cfg")  
        OOSU10 "$env:TEMP\ooshutup10.cfg" /quiet
        (New-Object System.Net.WebClient).DownloadFile("https://t0m.pw/ExplorerPatcher", "$env:TEMP\ExplorerPatcher.reg")
        (New-Object System.Net.WebClient).DownloadFile("https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe", "$env:TEMP\ep_setup.exe")
        Start-Process -FilePath "$env:TEMP\ep_setup.exe" -Wait
        Start-Sleep -Seconds 5
        reg import "$env:TEMP\ExplorerPatcher.reg"
        Start-Process -FilePath "C:\Windows\Resources\Themes\themeA.theme" -Wait
        Copy-Item -Path "$env:TEMP\ExplorerPatcher.reg" -Destination "$env:USERPROFILE\Desktop\ImportMeIntoExplorerPatcher.reg"
        if (Test-Path "$env:ProgramFiles\Notepad++\notepad++.exe") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\Notepad++\notepad++.exe" }
        if (Test-Path "$env:ProgramFiles\totalcmd\TOTALCMD64.EXE") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\totalcmd\TOTALCMD64.EXE" }
        if (Test-Path "$env:ProgramFiles\Mozilla Firefox\firefox.exe") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\Mozilla Firefox\firefox.exe" }
        if (Test-Path "$env:ProgramFiles\Google\Chrome\Application\chrome.exe") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"}
        Restart-Computer -Force
    
    }
    function Set-w10basic {
        Set-Activation
        Install-Choco
        (New-Object System.Net.WebClient).DownloadFile("https://t0m.pw/BasicChoco", "$env:TEMP\packages.config")  
        Choco install "$env:TEMP\packages.config"
        (New-Object System.Net.WebClient).DownloadFile("https://t0m.pw/shutup10", "$env:TEMP\ooshutup10.cfg")  
        OOSU10 "$env:TEMP\ooshutup10.cfg" /quiet
        if (Test-Path "$env:ProgramFiles\Notepad++\notepad++.exe") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\Notepad++\notepad++.exe" }
        if (Test-Path "$env:ProgramFiles\totalcmd\TOTALCMD64.EXE") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\totalcmd\TOTALCMD64.EXE" }
        if (Test-Path "$env:ProgramFiles\Mozilla Firefox\firefox.exe") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\Mozilla Firefox\firefox.exe" }
        if (Test-Path "$env:ProgramFiles\Google\Chrome\Application\chrome.exe") { &"C:\Program Files\WindowsPowerShell\Modules\tom42tools\2024.2.15\tom42-syspin.exe" "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"}
    }
    if (((Get-ComputerInfo | Select-Object -expand OsName) -match 11)) { Set-w11basic }
    if (((Get-ComputerInfo | Select-Object -expand OsName) -match 10)) { Set-w10basic }
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
