# Normalize files from Radarr and/or Sonarr

<details id="bkmrk-about-%26-requirements"><summary>About &amp; Requirements</summary>

Each of these are running in docker containers

[Webhook](https://github.com/adnanh/webhook/) [Docker container](https://github.com/go2tom42/docker-webhook)  
[Radarr](https://github.com/Radarr/Radarr)  
[Sonarr](https://github.com/Sonarr/Sonarr)  
[Plex](https://hub.docker.com/r/plexinc/pms-docker)

<details id="bkmrk-breakdown-of-what-ha"><summary>Breakdown of what happens</summary>

When one off the ARR apps finishes renaming and moving the file it will send a Webhook  
That Webhook will run a script that will pull data from the payload to get the file's location  
Using the location the script will determine it's Plex Library, launch a docker container on host machine that will normalize file  
Script finally tells plex to refresh library

You will need to gather information on your systems

<details><summary>Needed Information</summary>

You need IP address for: Plex server, Machine that runs you docker containers which also needs access to the file  
Plex Token [instructions on how to get](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/)  
[Plex library key numbers](https://support.plex.tv/articles/201638786-plex-media-server-url-commands/)  
User name and password for docker host machine  
Path into for different libraries, example

```shell
/ALL/Videos/Movies/Live Action/
/ALL/Videos/Movies/Science Fiction/
/ALL/Videos/Movies/4K/
/ALL/Videos/Movies/animated/
/ALL/Videos/Movies/Horror/
/ALL/Videos/Movies/Superhero/
/ALL/Videos/TV/Anime Ended/
/ALL/Videos/TV/Science Fantasy Ended/
/ALL/Videos/TV/Science Fantasy/
/ALL/Videos/TV/Star Trek/
/ALL/Videos/TV/Animation/
/ALL/Videos/TV/Anime/
/ALL/Videos/TV/Continuing/
/ALL/Videos/TV/Ended/
/ALL/Videos/TV/Wrestling/
/ALL/Videos/Documentaries/tmdb/
/ALL/Videos/Documentaries/tv/
```

<div style="color: #d4d4d4; background-color: #1e1e1e; font-family: Consolas, 'Courier New', monospace; font-weight: normal; font-size: 14px; line-height: 19px; white-space: pre;">  
</div></details></details></details><details id="bkmrk-webhook-setup-webhoo"><summary>Webhook Setup</summary>

Webhook has no gui, to add a new webhook on you server edit hooks.json  
  
Add a section

```json
    {
        "id":"normalize",
        "execute-command":"/scripts/normalize.sh",
        "command-working-directory":"/scripts",
        "pass-file-to-command":[
            {
                "source":"raw-request-body",
                "envname":"PFILE"
            }
        ]
    },
```

ID will be your URL, the ID is added to the end of `https://webooks.tom42.pw/hooks/`

execute-command is the script that runs when the URL is triggered.   
Here is the script:

```shell
#!/bin/sh

# check if webhook is from Sonarr
# If so get file path and root folders
if $(cat "$PFILE" | jq 'has ("series")'); then
  XXfileXX=$(cat "$PFILE" |jq .series.path| tr -d '"')/$(cat "$PFILE" |jq .episodeFile.relativePath| tr -d '"')
  choice=$(cat "$PFILE" |jq .series.path| tr -d '"')
fi

#check if webhook is from Radarr
# If so get file path and root folders
if $(cat "$PFILE" | jq 'has ("movie")'); then
 XXfileXX=$(cat "$PFILE" |jq .movie.folderPath| tr -d '"')/$(cat "$PFILE" |jq .movieFile.relativePath| tr -d '"')
  choice=$(cat "$PFILE" |jq .movie.folderPath| tr -d '"')
fi

# determine root folder's Plex library
case $choice in
    *"/ALL/Videos/Movies/Live Action/"* ) library="14";;
    *"/ALL/Videos/Movies/Science Fiction/"* ) library="15";;
    *"/ALL/Videos/Movies/4K/"* ) library="13";;
    *"/ALL/Videos/Movies/animated/"* ) library="16";;
    *"/ALL/Videos/Movies/Horror/"* ) library="17";;
    *"/ALL/Videos/Movies/Superhero/"* ) library="18";;
    *"/ALL/Videos/TV/Anime Ended/"* ) library="19";;
    *"/ALL/Videos/TV/Science Fantasy Ended/"* ) library="5";;
    *"/ALL/Videos/TV/Science Fantasy/"* ) library="4";;
    *"/ALL/Videos/TV/Star Trek/"* ) library="1";;
    *"/ALL/Videos/TV/Animation/"* ) library="8";;
    *"/ALL/Videos/TV/Anime/"* ) library="9";;
    *"/ALL/Videos/TV/Continuing/"* ) library="2";;
    *"/ALL/Videos/TV/Ended/"* ) library="3";;
    *"/ALL/Videos/TV/Wrestling/"* ) library="11";;
    *"/ALL/Videos/Documentaries/tmdb/"* ) library="20";;
    *"/ALL/Videos/Documentaries/tv/"* ) library="20";;
    *) library="all";;
esac

# Normalize file in a docker container on host machine
sshpass -p "1tardis1" ssh -o "StrictHostKeyChecking no" tom42@192.168.1.42 "sudo docker run -v /media/nas/Videos:/ALL/Videos -i --rm ghcr.io/go2tom42/ps-ff-hb-docker:latest pwsh \"/ALL/Videos/normalize.ps1\" \"$XXfileXX\""

# Refresh Plex library
curl http://192.168.1.88:32400/library/sections/$library/refresh?X-Plex-Token=sVbduUbv4-x2DxzydRmx

#delete webhook data
rm "$PFILE"

```

Lines 5-8 check if the payload is from Sonarr   
Lines 12-15 check if the payload is from Sonarr  
Lines 18-37 check the path of the file vs the info collected on Plex Library IDs and their paths

<details id="bkmrk-line-40-runs-docker-"><summary>Line 40 runs Docker container</summary>

`sshpass -p "1tardis1" ssh -o "StrictHostKeyChecking no" tom42@192.168.1.42 "sudo docker run -v /media/nas/Videos:/ALL/Videos -i --rm ghcr.io/go2tom42/ps-ff-hb-docker:latest pwsh \"/ALL/Videos/normalize.ps1\" \"$XXfileXX\""`

***sshpass*** allows you to log in to a machine and run a command  
***-p "1tardis1"*** is the Password  
 ***ssh -o "StrictHostKeyChecking no"*** requires sshpass perimeters  
tom42@192.168.1.42 username @ IP

<details><summary>Command sent to host</summary>

```shell
"sudo docker run -v /media/nas/Videos:/ALL/Videos -i --rm ghcr.io/go2tom42/ps-ff-hb-docker:latest pwsh \"/ALL/Videos/normalize.ps1\" \"$XXfileXX\""
```

The Volume needed to be tied to the server so it mirrors the path the ARR sees  
The image is the one listed in the requirements  
Command sent to docker container `pwsh \"/ALL/Videos/normalize.ps1\" \"$XXfileXX\""`  
I Just keep the PS1 script in the video path, you can create another volume and stick it there if you choose

</details></details><details id="bkmrk-line-43-refesh-plex-"><summary>Line 43 Refesh Plex library</summary>

need to change IP and token

</details>Line 46 removes payload

</details><details id="bkmrk-normalize.ps1-param%28"><summary>normalize.ps1</summary>

```powershell
Param(
    [parameter(Mandatory = $true)]
    [alias("f")]
    $File,
    [parameter(Mandatory = $false)]
    [Alias('c')]
    [String]$codec = "ac3",
    [parameter(Mandatory = $false)]
    [Alias('ext')]
    [String]$audioext = "ac3" ,
    [parameter(Mandatory = $false)]
    [Alias('b')]
    [String]$bitrate = "384k",
    [parameter(Mandatory = $false)]
    [Alias('ar')]
    [String]$freq = "48000",
    [parameter(Mandatory = $false)]
    [Alias('s')]
    [String]$sub2srt = $false    
)

$ffmpegEXE = '/usr/local/bin/ffmpeg'
$mkvmergeEXE = '/usr/bin/mkvmerge'

[string]$mkvSTDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$mkvSTDERROUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$AudioExtJson = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".json")
[string]$STDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
[string]$STDERR_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")


$Extcheck = Get-Childitem -LiteralPath $File -ErrorAction Stop
if ($Extcheck.Extension -eq ".avi") {
    Start-Process -Wait $mkvmergeEXE -ArgumentList ('--output "' + $Extcheck.FullName.Replace('.avi', '.mkv') + '" "' + $File + '"')
    $File = $Extcheck.FullName.Replace('.avi', '.mkv')
}
if ($Extcheck.Extension -eq ".mp4") {
    Start-Process -Wait $mkvmergeEXE -ArgumentList ('--output "' + $Extcheck.FullName.Replace('.mp4', '.mkv') + '" "' + $File + '"')
    $File = $Extcheck.FullName.Replace('.mp4', '.mkv')
}

$successcheck = Get-Childitem -LiteralPath $file -ErrorAction Stop
$successcheck1 = Get-Childitem -LiteralPath $successcheck.fullname -ErrorAction Stop
$successcheck2 = ($successcheck1.FullName.TrimEnd($successcheck1.extension) + '.NORMALIZED.mkv')


$dupcheck = Get-Childitem -LiteralPath $file -ErrorAction Stop
$dupcheck = Get-Childitem -LiteralPath $dupcheck.fullname -ErrorAction Stop
$dupcheck = ($dupcheck.FullName.TrimEnd($dupcheck.extension) + '.NORMALIZED.mkv')

if (Test-Path ($dupcheck)) {
    Write-Warning "File exists"
    exit
}

$dupcheck = Get-Childitem -LiteralPath $file -ErrorAction Stop
$dupcheck = Get-Childitem -LiteralPath $dupcheck.fullname -ErrorAction Stop
$dupcheck = ($dupcheck.FullName.TrimEnd($dupcheck.extension) + '.AUDIO.mkv')

if (Test-Path ($dupcheck)) {
    Write-Warning "File exists"
    exit
}


function Get-DefaultAudio($file) {

    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $file = Get-Childitem -LiteralPath $file.fullname -ErrorAction Stop
    $video = &$mkvmergeEXE -J $file | ConvertFrom-Json
    $audio_ck = $video.tracks | Where-Object { $_.type -eq "audio" }
    $audio_ck2 = $audio_ck.properties | Where-Object { $_.default_track -eq "True" }

    if ($audio_ck2) {
        $default_track = $audio_ck2[0].number - 1
        $def_language = $audio_ck2[0].language
    }
    else {
        $default_track = $audio_ck[0].properties.number - 1
        $def_language = $audio_ck[0].properties.language
    }
    
    $AudioMid = Join-Path ([IO.Path]::GetTempPath()) ($file.BaseName + '.AUDIO.mkv')

    $json = "--output" , "$AudioMid"
    $json = $json += "--audio-tracks"
    $json = $json += "$default_track"
    $json = $json += "--no-video", "--no-subtitles", "--no-chapters", "--language"
    $json = $json += "$default_track" + ":" + "$def_language"
    $json = $json += "--default-track"
    $json = $json += "$default_track" + ":yes"
    $json = $json += "(", $file.FullName , ")"
    $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath $AudioExtJson
    
    
    $nid = (Get-Process mkvmerge -ErrorAction SilentlyContinue).id 
    if ($nid) {
        Write-Output "Waiting for MKVMERGE to finish"
        Wait-Process -Id $nid
        Start-Sleep 5
        Clear-Host
    }
        
    $mkvmergePROS = Start-Process -FilePath $mkvmergeEXE -ArgumentList ('"' + "@$AudioExtJson" + '"') -RedirectStandardError $mkvSTDERROUT_FILE -RedirectStandardOutput $mkvSTDOUT_FILE -PassThru -NoNewWindow
    Start-Sleep -m 1
    Do {        
        Start-Sleep -m 1
        $MKVProgress = (Get-content $mkvSTDOUT_FILE | Select-Object -Last 1) | Where-Object { $_ -like "Progress*" }
        If ($MKVProgress) {
            $MKVPercent = $MKVProgress -replace '\D+'
            write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete $MKVPercent -Status ("Extracting audio file {0:n2}% completed..." -f $MKVPercent)
        
        }

    }Until ($mkvmergePROS.HasExited)
    
    $script:def_language = $def_language

    write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete 100 -Status ("Extracting audio file {0:n2}% completed..." -f 100)
    
    Remove-Item -Path $mkvSTDOUT_FILE
    Remove-Item -Path $mkvSTDERROUT_FILE
    Remove-Item -LiteralPath $AudioExtJson
}

function Normalize($file) {
    [string]$OutputFileExt = "." + $audioext
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $Source_Path = $file.FullName.TrimEnd($file.extension) + '.mkv' 
    
    $script:PASS2_FILE = $file.FullName.TrimEnd($file.extension) + $OutputFileExt

    $ArgumentList = "-progress - -nostats -nostdin -y -i  ""$file"" -af loudnorm=i=-23.0:lra=7.0:tp=-2.0:offset=0.0:print_format=json -hide_banner -f null -"    

    $totalTime = ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $file
    $ffmpeg = Start-Process -FilePath $ffmpegEXE -ArgumentList $ArgumentList -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE -PassThru -NoNewWindow
    Start-Sleep 1
    Do {
        Start-Sleep 1
        $ffmpegProgress = [regex]::split((Get-content $STDOUT_FILE | Select-Object -Last 9), '(,|\s+)') | Where-Object { $_ -like "out_time=*" }
        If ($ffmpegProgress) {
            $gettimevalue = [TimeSpan]::Parse(($ffmpegProgress.Split("=")[1]))
            $starttime = $gettimevalue.ToString("hh\:mm\:ss\,fff") 
            $a = [datetime]::ParseExact($starttime, "HH:mm:ss,fff", $null)
            $ffmpegTimelapse = (New-TimeSpan -Start (Get-Date).Date -End $a).TotalSeconds
            $ffmpegPercent = $ffmpegTimelapse / $totalTime * 100
            write-progress -parentId 1 -Activity "2 pass loudnorm" -PercentComplete $ffmpegPercent -Status ("Pass 1 of 2 is {0:n2}% completed..." -f $ffmpegPercent)
            
        }

    }Until ($ffmpeg.HasExited)

    $input_i = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_i*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_tp = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_tp*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_lra = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_lra*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $input_thresh = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*input_thresh*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")
    $target_offset = (((Get-Content -LiteralPath $STDERR_FILE | Where-Object { $_ -Like '*target_offset*' }).Split(" "))[2]).Replace('"', "").Replace(',', "")

    Remove-Item -Path $STDOUT_FILE
    Remove-Item -Path $STDERR_FILE

    $ArgumentList = "-progress - -nostats -nostdin -y -i ""$Source_Path"" -threads 0 -hide_banner -filter_complex `"[0:0]loudnorm=I=-23:TP=-2.0:LRA=7:measured_I=""$input_i"":measured_LRA=""$input_lra"":measured_TP=""$input_tp"":measured_thresh=""$input_thresh"":offset=""$target_offset"":linear=true:print_format=json[norm0]`" -map_metadata 0 -map_metadata:s:a:0 0:s:a:0 -map_chapters 0 -c:v copy -map [norm0] -c:a $codec -b:a $bitrate -ar $freq -c:s copy -ac 2 ""$PASS2_FILE"""
    write-progress -id 1 -activity "Normalizing audio" -status "Stage 3/4" -PercentComplete 46
    $ffmpeg = Start-Process -FilePath $ffmpegEXE -ArgumentList $ArgumentList -RedirectStandardError $STDERR_FILE -RedirectStandardOutput $STDOUT_FILE -PassThru -NoNewWindow
    Start-Sleep 1
    Do {
        Start-Sleep 1
        $ffmpegProgress = [regex]::split((Get-content $STDOUT_FILE | Select-Object -Last 9), '(,|\s+)') | Where-Object { $_ -like "out_time=*" }
        If ($ffmpegProgress) {
            $gettimevalue = [TimeSpan]::Parse(($ffmpegProgress.Split("=")[1]))
            $starttime = $gettimevalue.ToString("hh\:mm\:ss\,fff") 
            $a = [datetime]::ParseExact($starttime, "HH:mm:ss,fff", $null)
            $ffmpegTimelapse = (New-TimeSpan -Start (Get-Date).Date -End $a).TotalSeconds
            $ffmpegPercent = $ffmpegTimelapse / $totalTime * 100
            write-progress -parentId 1 -Activity "2 pass loudnorm" -PercentComplete $ffmpegPercent -Status ("Pass 2 of 2 is {0:n2}% completed..." -f $ffmpegPercent)
            
        }

    }Until ($ffmpeg.HasExited)
    Remove-Item -Path $STDERR_FILE
    Remove-Item -Path $STDOUT_FILE
    Remove-Item -Path $file
}

function Start-Remux($file) {
    $file = Get-Childitem -LiteralPath $file -ErrorAction Stop
    $video = &$mkvmergeEXE -J $file | ConvertFrom-Json
    $json = ''
    $json = "--output" , ($file.FullName.TrimEnd($file.extension) + '.NORMALIZED.mkv')
    
    foreach ($obj in $video.tracks) {
        if ($obj.type -eq "video") {
            $json = $json += "--language" , "$($obj.id):und" , "--default-track" , "$($obj.id):yes"
        }
        
        if ($obj.type -eq "audio") {
            $json = $json += "--language", "$($obj.id):$($obj.properties.language)"
            if ($obj.properties.track_name) {
                $json = $json += "--track-name", "$($obj.id):$($obj.properties.track_name)"
            }
        }
    
        if ($obj.type -eq "subtitles") {
            $json = $json += "--language" , "$($obj.id):$($obj.properties.language)"
            if ($obj.properties.track_name) {
                $json = $json += "--track-name" , "$($obj.id):$($obj.properties.track_name)"
            }
        }
    }
    
    $json = $json += "(" , $file.FullName , ")" # Source file
    $json = $json += "--language", "0:$def_language", "--track-name", "0:Normalized", "--default-track", "0:yes" , "("

    $json = $json += $PASS2_FILE # normalized audio file
    
    $main_tracks = $video.tracks.count - 1
    $track_order = ''
    for ($i = 1; $i -le $main_tracks; $i++) {
        $track_order = $track_order + ",0:$i"
    }
    $json = $json += ")", "--track-order", "0:0,1:0$track_order"
    
    $json | ConvertTo-Json -depth 100 | Out-File -LiteralPath $AudioExtJson
    

    $nid = (Get-Process mkvmerge -ErrorAction SilentlyContinue).id 
    if ($nid) {
        Write-Output "Waiting for MKVMERGE to finish"
        Wait-Process -Id $nid
        Start-Sleep 3
        Clear-Host
    }

    [string]$mkvSTDOUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
    [string]$mkvSTDERROUT_FILE = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName().Split('.')[0] + ".txt")
    
    $mkvmergePROS = Start-Process -FilePath $mkvmergeEXE -ArgumentList ('"' + "@$AudioExtJson" + '"') -RedirectStandardError $mkvSTDERROUT_FILE -RedirectStandardOutput $mkvSTDOUT_FILE -PassThru -NoNewWindow
    
    Start-Sleep -m 1
    Do {
        Start-Sleep -m 1
        $MKVProgress = (Get-content $mkvSTDOUT_FILE | Select-Object -Last 1) | Where-Object { $_ -like "Progress*" }
        If ($MKVProgress) {
            $MKVPercent = $MKVProgress -replace '\D+'
            write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete $MKVPercent -Status ("Muxing video file {0:n2}% completed..." -f $MKVPercent)
            
        }
    
    }Until ($mkvmergePROS.HasExited)
    
    write-progress -parentId 1 -Activity "MKVmerge" -PercentComplete 100 -Status ("Muxing video file {0:n2}% completed..." -f 100)
    Remove-Item -Path $mkvSTDERROUT_FILE
    Remove-Item -Path $mkvSTDOUT_FILE
    Remove-Item -Path $PASS2_FILE
    Remove-Item -LiteralPath $AudioExtJson
}

Clear-Host



$Host.PrivateData.ProgressBackgroundColor = 'Green'
$Host.PrivateData.ProgressForegroundColor = 'Black'

$totalTime = &ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file"

write-progress -id 1 -activity "Normalizing audio" -status "Stage 1/4" -PercentComplete 0
write-progress -parentId 1 -Activity "Mkvmerge"

Get-DefaultAudio($file)

$file = Get-Childitem -LiteralPath $file -ErrorAction Stop
$file = Get-Childitem -LiteralPath $file.fullname -ErrorAction Stop
write-progress -id 1 -activity "Normalizing audio" -status "Stage 2/4" -PercentComplete 1
write-progress -parentId 1 -Activity "2 pass loudnorm" -Status "Pass 1 of 2"

Normalize (Join-Path ([IO.Path]::GetTempPath()) ($file.BaseName + '.AUDIO.mkv'))


write-progress -id 1 -activity "Normalizing audio" -status "Stage 4/4" -PercentComplete 96
write-progress -parentId 1 -Activity "Mkvmerge"

Start-Remux($file)

Start-Sleep -Seconds 10

if (Test-Path ($successcheck2)) {
    rm $successcheck1
}

```

</details><details id="bkmrk-sonarr-%2F-radarr-setu"><summary>Sonarr / Radarr setup</summary>

[![sonarr.png](https://bookstack.tom42.pw/uploads/images/gallery/2023-03/scaled-1680-/sonarr.png)](https://bookstack.tom42.pw/uploads/images/gallery/2023-03/sonarr.png)

</details><details id="bkmrk-extra-info-plex-dock"><summary>EXTRA info</summary>

<details id="bkmrk-plex-docker-compose-"><summary>Plex docker-compose</summary>

```json
version: '3.3'
services:
  plex:
    image: plexinc/pms-docker:latest
    privileged: true
    container_name: plex
    ports:
      - 32469:32469/udp
      - 9:9/udp
      - 9:9/tcp
      - 7:7/udp
      - 7:7/tcp
      - 32400:32400/tcp          
      - 33400:33400/tcp
      - 3005:3005/tcp
      - 8324:8324/tcp
      - 32469:32469/tcp
      - 1900:1900/udp
      - 65001:65001/tcp
      - 65001:65001/udp
      - 32410:32410/udp
      - 32412:32412/udp
      - 32413:32413/udp
      - 32414:32414/udp
    environment:
      - VERSION=latest
      - PLEX_CLAIM=claim-X_npvhNw8sKDiSaedsKz
      - ADVERTISE_IP=http://192.168.1.88:32400/
      - LD_LIBRARY_PATH=/usr/lib/plexmediaserver
    volumes:
      - /home/tom42/docker/configs/plex:/config
      - /dev/shm:/transcode
      - /media/nas:/data/ALL
      - /media/plex:/data/USB
    devices:
      - /dev/dri:/dev/dri
    restart: always

```

</details><details id="bkmrk-radarr-docker-compos"><summary>Radarr docker-compose</summary>

```json
  radarr:
    image: linuxserver/radarr:nightly
    container_name: radarr
    volumes:
      - /home/tom42/docker/configs/radarr:/config
      - /media/HDD/Downloads/completed/Movies:/downloads
      - /media/nas:/ALL
      - /etc/localtime:/etc/localtime:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7878"]
      interval: 30s
      timeout: 10s
      retries: 5
    env_file: uidgid.env
    environment:
      - NETWORK_ACCESS=internal
    networks:
      - caddy
    labels:
      caddy: radarr.tom42.pw
      caddy.reverse_proxy: "{{upstreams 7878}}"
      caddy.authorize: with admin_policy
    restart: unless-stopped
```

</details><details id="bkmrk-sonarr-sonarr%3A-image"><summary>Sonarr docker-compose</summary>

```json
  sonarr:
    image: linuxserver/sonarr
    container_name: sonarr
    volumes:
      - /home/tom42/docker/configs/sonarr3:/config
#      - /etc/localtime:/etc/localtime:ro
      - /media/HDD/Downloads/completed/tv:/downloads
      - /media/nas/Videos:/ALL/Videos
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8989"]
      interval: 30s
      timeout: 10s
      retries: 5
    env_file: uidgid.env
    environment:
      - NETWORK_ACCESS=internal
    networks:
      - caddy
    labels:
      caddy: sonarr.tom42.pw
      caddy.reverse_proxy: "{{upstreams 8989}}"
      #caddy.basicauth.tom42: "JDJhJDE0JG43SkVFSlB5N2tqdEhUMWUwZjN4TmVERUYvcVExSnN6QUdlQ1k5RjQ3QW1JTFgxT3h4TDBh"
      caddy.authorize: with admin_policy
    restart: unless-stopped
```

</details><details id="bkmrk-webhook-webhooks%3A-co"><summary>Webhook docker-compose</summary>

```json
  webhooks:
    container_name: webhooks
    image: ghcr.io/go2tom42/docker-webhook:latest
    user: root
    labels:
      caddy: webooks.tom42.pw
      caddy.reverse_proxy: "{{upstreams 9000}}"
    command: ["-verbose", "-hooks=/etc/webhook/hooks.json","-hotreload"]
    environment:
      - TZ=EST
    networks:
      - caddy
    volumes:
      - /home/tom42/docker/configs/webooks/scripts:/scripts
      - /etc/localtime:/etc/localtime:ro
      - /home/tom42/docker/configs/madness/_posts:/posts
      - /home/tom42/docker/configs/madness/assets/images:/assets
      - /home/tom42/docker/configs/webooks:/etc/webhook
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```

</details></details>