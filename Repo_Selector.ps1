$internalDrive = 'C:\'
$allDrives = Get-PSDrive
$externalDriveName = 'BIPRA'

Add-Type -TypeDefinition @"
   public enum RepoDrives
   {
        Internal,
        External
   }
"@

ForEach ($drive in $allDrives) {
    if($drive.Description.Contains($externalDriveName)){
        $externalDrive = $drive.Root
    }
}

$externalDrive = $externalDrive + 'Repos'

Set-Location -Path $externalDrive

Function GoToDrive ([Parameter(Mandatory=$false)] [RepoDrives]$targetDrive = "external"){
    Switch($targetDrive){
        "External" { Set-Location -Path $externalDrive }
        "Internal" { Set-Location -Path $internalDrive }
    }
    $initMessage = "Drive " + $targetDrive +" loaded. Valid Repos: "
    ForEach ($repoFolder in $repoFolders) {
        $initMessage = $initMessage + $repoFolder.Name + ", "
    }
    Write-Host -ForegroundColor Green $initMessage    
}

$currentLocation = Get-Location
$repoFolders = dir -Directory

$repoEnum = "
   Add-Type -TypeDefinition @`" `npublic enum RepoFolders
   {"
    ForEach ($repoFolder in $repoFolders) {
        $repoEnum = $repoEnum + $repoFolder.Name + ","
    }
   $repoEnum = $repoEnum + "All}`n`"@
"

Invoke-Expression $repoEnum

$goToFunction = "Function GoTo ([Parameter(Mandatory=`$true)] [RepoFolders]`$targetFolder){
    Switch(`$targetFolder){ `"All`" { Set-Location -Path `"" + $currentLocation + "\`"}"
    ForEach ($repoFolder in $repoFolders) {
        $goToFunction = $goToFunction + "`"" + $repoFolder.Name + "`" { Set-Location -Path `"" + $currentLocation + "\" + $repoFolder.Name + "`" 
        if (Test-Path `"" + $currentLocation + "\" + $repoFolder.Name + "\Powershell\init.ps1`") 
        { Import-Module `"" + $currentLocation + "\" + $repoFolder.Name + "\Powershell\init.ps1`" } }"
        
    }
    $goToFunction = $goToFunction + "}    
}"

Invoke-Expression $goToFunction

Write-Host -ForegroundColor Green "Powershell Init Complete"

GoToDrive