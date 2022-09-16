[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $True)] [string] $dotSourceFilePath,
    [Parameter(Mandatory = $False)] [string] $gitHubToken
)

if (-not (Get-Module Posh-SSH -ListAvailable)) { Install-Module -Name Posh-SSH -Force }

function Get-GitHubRepositoryFileContent {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)] [string] $path,
        [Parameter(Mandatory = $False)] [string] $gitHubToken
    )
    $uri = "https://api.github.com/repos/go2tom42/Quagaars/contents/$path/variables.ps1`?ref=master" # Need to escape the ? that indicates an http query
    $uri = [uri]::EscapeUriString($uri)
    if ($PSBoundParameters.ContainsKey('gitHubtoken')) {
        $base64Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($gitHubToken)"))
        $headers = @{'Authorization' = "Basic $base64Token" }
        $splat = @{
            Method      = 'Get'
            Uri         = $uri
            Headers     = $headers
            ContentType = 'application/json'
        }
    }
    else {
        $splat = @{
            Method      = 'Get'
            Uri         = $uri
            ContentType = 'application/json'
        }
    } 
    
    try {
        Invoke-RestMethod @splat
    }
    catch {
        Write-Warning "Unable to get file content."   
        $ErrorMessage = $_.Exception.Message
        Write-Warning "$ErrorMessage"
        break
    }
}

if ($PSBoundParameters.ContainsKey('gitHubToken')) {
    $splat = @{
        gitHubToken      = $gitHubToken
        gitHubRepository = 'go2tom42/Quagaars'
        path             = $dotSourceFilePath
        branch           = 'master'
    }
}
else {
    $splat = @{
        gitHubRepository = 'go2tom42/Quagaars'
        path             = "$dotSourceFilePath/variables.ps1"
        branch           = 'master'
    }
}

$dotSourceFileData = Get-GitHubRepositoryFileContent $dotSourceFilePath
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($dotSourceFileData.content)) | Out-File -FilePath $dotSourceFileData.Path.Split('/')[-1] -Force
$dotSourceFile = Get-Item -Path $dotSourceFileData.path.Split('/')[-1]
if (Test-Path -Path $dotSourceFileData.path.Split('/')[-1]) {
    try {
        . $dotSourceFile.FullName
        Remove-Item -Path $dotSourceFileData.path.Split('/')[-1] -Recurse -Force
    }
    catch {
        Write-Warning "Unable to dot source file: $dotSourceFilePath."
        $ErrorMessage = $_.Exception.Message
        Write-Warning "$ErrorMessage"
        break
    }
}
else {
    Write-Warning "Could not find path to file: $dotSourceFilePath."
    $ErrorMessage = $_.Exception.Message
    Write-Warning "$ErrorMessage"
    break
}

# restore dump
[securestring]$secStringPassword = ConvertTo-SecureString $BitnamiPW -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($BitnamiName, $secStringPassword)
$dumpsession = (New-SFTPSession -ComputerName 192.168.1.18 -Credential $credObject -Verbose).SessionId
Set-SFTPItem -SessionId $dumpsession -Destination "/wikidump" -Path "Z:\wikidumps\$base-$date-wikidump.7z" -Force
$ssh18 = (New-SSHSession -Computer 192.168.1.18 -AcceptKey -Credential $credObject).SessionId
Invoke-SSHCommand -Command "wget -O - https://raw.githubusercontent.com/go2tom42/Quagaars/master/start.sh | bash -s $base $date" -SessionId $ssh18 -ShowStandardOutputStream -ShowErrorOutputStream -Timeout 3600

# set css and main_page
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/go2tom42/Quagaars/master/$base/$base.ps1"))

# run browsertrix-crawler
[securestring]$secStringPassword2 = ConvertTo-SecureString $Workhorse2PW -AsPlainText -Force
[pscredential]$credObject2 = New-Object System.Management.Automation.PSCredential ($Workhorse2Name, $secStringPassword2)
$ssh42 = (New-SSHSession -Computer 192.168.1.42 -AcceptKey -Credential $credObject2).SessionId
Invoke-SSHCommand -Command "wget -O /wikidump/crawl-config.yaml https://raw.githubusercontent.com/go2tom42/Quagaars/master/$base/$base.yaml" -SessionId $ssh42 -ShowStandardOutputStream -ShowErrorOutputStream -Timeout 3600
Invoke-SSHCommand -Command "sudo docker run -p 9037:9037 -v /wikidump/crawl-config.yaml:/app/crawl-config.yaml -v /output:/crawls/ webrecorder/browsertrix-crawler crawl --config /app/crawl-config.yaml" -SessionId $ssh42 -ShowStandardOutputStream -ShowErrorOutputStream -Timeout 3600

# move warc.gz to main pc
[securestring]$secStringPassword2 = ConvertTo-SecureString $Workhorse2PW -AsPlainText -Force
[pscredential]$credObject2 = New-Object System.Management.Automation.PSCredential ($Workhorse2Name, $secStringPassword2)
$warcgz = (New-SFTPSession -ComputerName 192.168.1.42 -Credential $credObject2 -Verbose).SessionId
Get-SFTPItem -SessionId $warcgz -Path "/output/site/collections/$title-off-line-site/$title-off-line-site_0.warc.gz" -Destination "c:\WORK\WIKIDUMPS" -Verbose

#  move warc.gz from main PC to VM
[securestring]$secStringPassword3 = ConvertTo-SecureString $VMPW -AsPlainText -Force
[pscredential]$credObject3 = New-Object System.Management.Automation.PSCredential ($VMName, $secStringPassword3)
$warcgz2 = (New-SFTPSession -ComputerName 192.168.1.169 -Credential $credObject3 -Verbose).SessionId
Set-SFTPItem -SessionId $warcgz2 -Destination "/home/tom42/Desktop/Wikidump" -Path "c:\WORK\WIKIDUMPS\$title-off-line-site_0.warc.gz" -Force

# filter and convert .warc.gz to .wacz to .warc to .zim
$ssh169 = (New-SSHSession -Computer 192.168.1.169 -AcceptKey -Credential $credObject3).SessionId
Invoke-SSHCommand -Command "wget -O /home/tom42/Desktop/Wikidump/$title.css https://raw.githubusercontent.com/go2tom42/Quagaars/master/$base/$base.css" -SessionId $ssh169 -ShowStandardOutputStream -ShowErrorOutputStream -Timeout 3600
Invoke-SSHCommand -Command "warcfilter -U $safetitle.off-line.site /home/tom42/Desktop/Wikidump/$safetitle-off-line-site_0.warc.gz > /home/tom42/Desktop/Wikidump/$safetitle-off-line-site.wacz" -SessionId $ssh169 -ShowStandardOutputStream -ShowErrorOutputStream -Timeout 3600
Invoke-SSHCommand -Command "warc2warc -Z /home/tom42/Desktop/Wikidump/$title-off-line-site.wacz > /home/tom42/Desktop/Wikidump/$safetitle-off-line-site.warc" -SessionId $ssh169 -ShowStandardOutputStream -ShowErrorOutputStream -Timeout 3600
Invoke-SSHCommand -Command "warc2zim /home/tom42/Desktop/Wikidump/$safetitle-off-line-site.warc --custom-css /home/tom42/Desktop/Wikidump/$title.css --name $zimname -i off-line.site -u $zimurl --favicon https://github.com/go2tom42/Quagaars/raw/master/$base/zimlogo.png --output /home/tom42/Desktop/Wikidump --description $description --publisher 'atari-guy' --creator 'atari-guy'" -SessionId $ssh169 -ShowStandardOutputStream -ShowErrorOutputStream -Timeout 3600

# .zim file to main PC
$zimname=$zimname.Trim('"')
Get-SFTPItem -SessionId $warcgz2 -Path ('/home/tom42/Desktop/Wikidump/' + $zimname + '_2022-09.zim') -Destination c:\WORK\WIKIDUMPS -Verbose
