# AlternateDataStreamModule

Alternate Data Streams are a feature of NTFS (Filesystem). They can be used to hide data in a file. This PowerShell module provides some functions to get the Alternate Data Streams and their content.

***This PowerShell module only works on Windows systems. This is caused by lacking implementation of key features on built-in Cmdlets on other platforms which would be used in this module to work properly.***

## Usage

To use the functions provided by this module, you need to import the module first. After downloading/cloning this repository of course. Import the module with the following command, if you are in the directory where you downloaded it:

```` PowerShell
Import-Module ./AlternateDataStreamModule
````

Now you are able to use the functions provided by this module. On Windows the following functions are available: `Get-AlternateDataStream`, `Get-AlternateDataStreamContent`, `Get-NTFSVolume`, `New-AlternateDataStreamFile`
