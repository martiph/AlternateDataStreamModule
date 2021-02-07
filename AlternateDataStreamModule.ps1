function Get-AlternateDataStream {
    <#
        .SYNOPSIS
        Get a list of files with alternate data streams on NTFS drives.

        .DESCRIPTION
        Get a list of files with alternate data streams. Every file has the data stream :$Data. This command only yields files with additional alternate data streams.

        .PARAMETER Path
        Specifies the path where to search for alternate data streams.

        .PARAMETER Recurse
        Search directories recursively.

        .PARAMETER ExportToJson
        A switch to export the results to a JSON-file.

        .PARAMETER OutputFile
        Specifies a filename for the JSON-file. This parameter is only used when the switch ExportToJson is set. Default is "AlternateDataStreams.json".

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

    $FileStreams = Get-ChildItem -Path $Path -Recurse:$Recurse | ForEach-Object { Get-Item $_.FullName -Stream * | Where-Object -Property Stream -ne ':$Data' } | Select-Object -Property FileName, Stream

    if ($ExportToJSON) {
        ConvertTo-Json -InputObject $FileStreams | Out-File -FilePath $OutputFile
    }

    return $FileStreams
}

function Get-AlternateDataStreamContent {
    <#
        .SYNOPSIS
        Get the content of a Alternate Data Stream on a NTFS system.

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
    $Volumes = Get-Volume | Where-Object -Property FileSystemType -eq "NTFS" | Where-Object -Property DriveLetter
    return $Volumes

}

function New-ADSTestStream {
    <#
        .SYNOPSIS
        Creates a txt-file with an alternate data stream. This file is usually just used to test this PowerShell module.

        .DESCRIPTION
        Creates a txt-file with an alternate data stream. The file is by default called "ADSTestFile.txt" with an alternate data stream by default called "hidden".

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

    New-Item -ItemType File -Name $FileName
    Add-Content -Value "This is the test file for alternate data streams" -Path "./$FileName"
    Add-Content -Value "If you see this you take a look at the alternate data stream" -Path "./${FileName}:${AlternateDataStream}"
}
