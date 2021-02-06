function Get-AlternateDataStream {
    <#
        .SYNOPSIS
        Adds a file name extension to a supplied name.

        .DESCRIPTION
        Adds a file name extension to a supplied name.
        Takes any strings for the file name or extension.

        .PARAMETER Name
        Specifies the file name.

        .PARAMETER Extension
        Specifies the extension. "Txt" is the default.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> extension -name "File"
        File.txt

        .EXAMPLE
        PS> extension -name "File" -extension "doc"
        File.doc

        .EXAMPLE
        PS> extension "File" "doc"
        File.doc

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>
    param(
        [ValidateNotNullOrEmpty()]
        [string]$Path = "./",
        [bool]$ExportToJSON = $true,
        [string]$OutputFile = "./AlternateDataStreams.json"
    )

    $FileStreams = Get-ChildItem -Path $Path -Recurse | ForEach-Object { Get-Item $_.FullName -Stream * | Where-Object -Property Stream -ne ':$Data' } | Select-Object -Property FileName, Stream

    if ($ExportToJSON) {
        ConvertTo-Json -InputObject $FileStreams | Out-File -FilePath $OutputFile
    }

    foreach ($File in $FileStreams) {
        [PSCustomObject]@{
            FileName = $File.FileName
            Stream   = $File.Stream
        }
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
