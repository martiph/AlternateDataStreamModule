function Get-AlternateDataStream {
    <#
        .SYNOPSIS
        Get a list of files with alternate data streams on NTFS drives. This works only on Windows systems.

        .DESCRIPTION
        Get a list of files with alternate data streams. Every file has the data stream :$Data. This command only yields files with additional alternate data streams.

        .PARAMETER Path
        Specifies the path where to search for alternate data streams.

        .PARAMETER Recurse
        Search directories recursively.

        .PARAMETER ExportToJson
        A switch to export the results to a JSON-file.

        .PARAMETER OutputFile
        Specifies a filename for the JSON-file. This parameter is only used when the switch ExportToJson is set. Default is "AlternateDataStreams.json". If a file with this name already exists, nothing happens.

        .INPUTS
        None.

        .OUTPUTS
        Returns a list of files with alternate data streams.

        .EXAMPLE
        PS> Get-AlternateDataStream -Path <path-to-directory>
        a list with all files in this directory containing alternate data streams.

        .EXAMPLE
        PS> Get-AlternateDataStream -Recurse
        A list with all files in the current directory and sub-directories containing alternate data streams.

        .EXAMPLE
        PS> Get-AlternateDataStream -ExportToJson -OutputFile "./ads.json"
        A list with all files in the current directory displayed on STDOUT, the same list is exported as JSON-file to ./ads.json.
    #>
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Path = "./",
        [switch]$Recurse,
        [switch]$ExportToJson,
        [string]$OutputFile = "./AlternateDataStreams.json"
    )
    if (Test-Path $Path) {
        $FileStreams = Get-ChildItem -Path $Path -Recurse:$Recurse | ForEach-Object { Get-Item $_.FullName -Stream * | Where-Object -Property Stream -ne ':$Data' } | Select-Object -Property FileName, Stream
    }
    if ($ExportToJSON -and -not $(Test-Path($OutputFile))) {
        ConvertTo-Json -InputObject $FileStreams | Out-File -FilePath $OutputFile
    } elseif ($ExportToJSON -and $(Test-Path $OutputFile)) {
        Write-Error "The file already exists, please specify a new name or rename the existing file and run the Cmdlet again."
    }

    return $FileStreams
}

function Get-AlternateDataStreamContent {
    <#
        .SYNOPSIS
        Get the content of a Alternate Data Stream on a NTFS system. This works only on Windows systems.

        .DESCRIPTION
        Get the content of a Alternate Data Stream on a NTFS system.

        .PARAMETER File
        Specifies the file name.

        .PARAMETER Stream
        Specifies the name of alternate data stream.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> Get-AlternateDataStreamContent -File <path to the file> -Stream <name of the alternate data stream>
        Content of the alternate data stream
    #>

    param(
        [Parameter(Mandatory)]
        [string]$File,
        [Parameter(Mandatory)]
        [string]$Stream
    )

    $FileContent = Get-Content -Path $File -Stream $Stream
    return $FileContent
}


function Get-NTFSVolume {
    <#
        .SYNOPSIS
        Returns a list with all volumes formatted with NTFS.

        .DESCRIPTION
        Returns a list with all volumes formatted with NTFS.

        .OUTPUTS
        A list with all volumes formatted with NTFS.

        .EXAMPLE
        PS> Get-NTFSVolume
        DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining      Size
        ----------- ------------ -------------- --------- ------------ ----------------- -------------      ----
        C                        NTFS           Fixed     Healthy      OK                <size remaining>   <total size>
    #>
    try {
        $Volumes = Get-Volume | Where-Object -Property FileSystemType -eq "NTFS" | Where-Object -Property DriveLetter
    }
    catch [CommandNotFoundException] {
        $Volumes = $null
        Write-Error "This function does not work on your system since the Cmdlet `Get-Volume` doesn't exist."
    }
    return $Volumes
}

function New-ADSTestStream {
    <#
        .SYNOPSIS
        Creates a txt-file with an alternate data stream. This file is usually just used to test this PowerShell module.

        .DESCRIPTION
        Creates a txt-file with an alternate data stream.
        The file is by default called "ADSTestFile.txt" with an alternate data stream by default called "hidden".
        The file is created in your current working directory. If a file with the same name already exists, a GUID will be prepended to the filename.

        .PARAMETER FileName
        Specifies the file name. Default is "ADSTestFile.txt".

        .PARAMETER AlternateDataStream
        Specifies the name of the alternate data stream. Default is "hidden".

        .INPUTS
        None.

        .OUTPUTS
        A file with an alternate data stream.

        .EXAMPLE
        PS> New-ADSTestStream
        Directory: C:\Users\<username>\Desktop

        Mode                 LastWriteTime         Length Name
        ----                 -------------         ------ ----
        -a----               <date, time>               0 ADSTestFile.txt

        .EXAMPLE
        PS> New-ADSTestStream -FileName <filename> -AlternateDataStream <alternate data stream>
    #>

    $FileName = "ADSTestFile.txt"
    $AlternateDataStream = "hidden"
    if (Test-Path $FileName) {
        $FileName = [guid]::NewGuid().Guid + "-" + $FileName
    }
    New-Item -ItemType File -Name $FileName
    Add-Content -Value "This is the test file for alternate data streams" -Path "$FileName"
    Add-Content -Value "If you see this you take a look at the alternate data stream" -Path "${FileName}:${AlternateDataStream}"
}

# Export the functions provided by this module
if ($IsWindows -or $null -eq $IsWindows) {
    Export-ModuleMember -Function "Get-NTFSVolume", "Get-AlternateDataStreamContent", "Get-AlternateDataStream"
}
else {
    Export-ModuleMember
}