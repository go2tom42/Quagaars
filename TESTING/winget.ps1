  $dl = New-Object net.webclient

    function getNewestLink($match) {
        $uri = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        Write-Verbose "[$((Get-Date).TimeofDay)] Getting information from $uri"
        $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
        Write-Verbose "[$((Get-Date).TimeofDay)] getting latest release"
        $data = $get[0].assets | Where-Object name -Match $match
        return $data.browser_download_url
    }

    $wingetUrl = getNewestLink("msixbundle")
    $wingetLicenseUrl = getNewestLink("License1.xml")

    function section($text) {

        Write-Output "# $text"
    }

    # Add AppxPackage and silently continue on error
    function AAP($pkg) {

        Add-AppxPackage $pkg -ErrorAction SilentlyContinue
    }

    # Download XAML nupkg and extract appx file
    section("Downloading Xaml nupkg file... (19000000ish bytes)")
    $url = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.1"
    $nupkgFolder = "Microsoft.UI.Xaml.2.7.1.nupkg"
    $zipFile = "Microsoft.UI.Xaml.2.7.1.nupkg.zip"
    $dl.Downloadfile($url, $zipFile)
    section("Extracting appx file from nupkg file...")
    Expand-Archive $zipFile

    # Determine architecture
    if ([Environment]::Is64BitOperatingSystem) {
        section("64-bit OS detected")

        # Install x64 VCLibs
        section("Downloading & installing x64 VCLibs... (21000000ish bytes)")
        $VClibsURL = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
        $VClibsPath = "Microsoft.VCLibs.x64.14.00.Desktop.appx"
        $dl.Downloadfile($VClibsURL, $VClibsPath)
        AAP("Microsoft.VCLibs.x64.14.00.Desktop.appx")

        # Install x64 XAML
        section("Installing x64 XAML...")
        AAP("Microsoft.UI.Xaml.2.7.1.nupkg\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx")
    }
    else {
        section("32-bit OS detected")

        # Install x86 VCLibs
        $VClibsURL = "https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx"
        $VClibsPath = "Microsoft.VCLibs.x86.14.00.Desktop.appx"
        $dl.Downloadfile($VClibsURL, $VClibsPath)
        section("Downloading & installing x86 VCLibs... (21000000ish bytes)")
        AAP("Microsoft.VCLibs.x86.14.00.Desktop.appx")

        # Install x86 XAML
        section("Installing x86 XAML...")
        AAP("Microsoft.UI.Xaml.2.7.1.nupkg\tools\AppX\x86\Release\Microsoft.UI.Xaml.2.7.appx")
    }

    # Finally, install winget
    section("Downloading winget... (21000000ish bytes)")
    $wingetPath = "winget.msixbundle"
    $dl.Downloadfile($wingetUrl, $wingetPath)
    $wingetLicensePath = "license1.xml"
    $dl.Downloadfile($wingetLicenseUrl, $wingetLicensePath)
    section("Installing winget...")
    Add-AppxProvisionedPackage -Online -PackagePath $wingetPath -LicensePath $wingetLicensePath -ErrorAction SilentlyContinue

    # Adding WindowsApps directory to PATH variable for current user
    section("Adding WindowsApps directory to PATH variable for current user...")
    $path = [Environment]::GetEnvironmentVariable("PATH", "User")
    $path = $path + ";" + [IO.Path]::Combine([Environment]::GetEnvironmentVariable("LOCALAPPDATA"), "Microsoft", "WindowsApps")
    [Environment]::SetEnvironmentVariable("PATH", $path, "User")

    # Cleanup
    section("Cleaning up...")
    Remove-Item $zipFile
    Remove-Item $nupkgFolder -Recurse
    Remove-Item $wingetPath
    Remove-Item $wingetLicensePath
    Remove-Item $VClibsPath

    # Finished
    section("Installation complete!")
    section("Please restart your computer to complete the installation.")
