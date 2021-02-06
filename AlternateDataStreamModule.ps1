function Get-AlternateDataStream{

param(
[ValidateNotNullOrEmpty()]
[string]$Path = "./",
[bool]$ExportToJSON

)

$FileStreams = Get-ChildItem -Path $Path -Recurse | ForEach-Object {Get-Item $_.FullName -Stream * | Where-Object -Property Stream -ne ':$Data'} | Select-Object -Property FileName, Stream

if($ExportToJSON){
ConvertTo-Json -InputObject $FileStreams
}

foreach($File in $FileStreams){
[PSCustomObject]@{
FileName = $File.FileName
Stream = $File.Stream
}
}

return $FileStreams

}




function Get-AlternateDataStreamContent{

param(
[Parameter(Mandatory)]
[string]$File,
[Parameter(Mandatory)]
[string]$Stream
)

Get-Content -Path $File -Stream $Stream
}


function Get-NTFSVolume{

$Volumes = Get-Volume | Where-Object -Property FileSystemType -eq "NTFS" | Where-Object -Property DriveLetter
return $Volumes

}

function New-ADSTestStream{

$FileName = "ADSTestFile.txt"
$AlternateDataStream = "hidden"

New-Item -ItemType File -Name $FileName
Add-Content -Value "This is the test file for alternate data streams" -Path "./$FileName"
Add-Content -Value "If you see this you take a look at the alternate data stream" -Path "./${FileName}:${AlternateDataStream}"

}
