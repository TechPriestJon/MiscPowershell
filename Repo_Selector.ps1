$internalDrive = 'C:\';
$allDrives = Get-PSDrive;
$externalDriveName = 'BIPRA';

Add-Type -TypeDefinition @"
   public enum RepoDrives
   {
        Internal,
        External
   }
"@;

ForEach ($drive in $allDrives) {
    if($drive.Description.Contains($externalDriveName)){
        $externalDrive = $drive.Root
    }
};

$externalDrive = $externalDrive + 'Repos';

Set-Location -Path $externalDrive;

Function GoToDrive ([Parameter(Mandatory=$false)] [RepoDrives]$targetDrive = "external"){
    Switch($targetDrive){
        "External" { Set-Location -Path $externalDrive }
        "Internal" { Set-Location -Path $internalDrive }
    };
    $currentDrive = $externalDrive;
    $initMessage = "Drive " + $targetDrive +" loaded. Valid Repos: ";
    ForEach ($repoFolder in $repoFolders) {
        $initMessage = $initMessage + $repoFolder.Name + ", "
    };
    Write-Host -ForegroundColor Green $initMessage;
};

$currentDrive = Get-Location;
$currentLocation = $currentDrive.Path;
$repoFolders = dir -Directory;

$repoEnum = "
   Add-Type -TypeDefinition @`" `npublic enum RepoFolders
   {"
    ForEach ($repoFolder in $repoFolders) {
        $repoEnum = $repoEnum + $repoFolder.Name + ","
    }
   $repoEnum = $repoEnum + "All}`n`"@
";

Invoke-Expression $repoEnum;

$goToFunction = "Function GoTo 
    ([Parameter(Mandatory=`$true)] [RepoFolders]`$targetFolder){
        Switch(`$targetFolder){ 
            `"All`" { 
                Set-Location -Path `"" + $currentDrive + "\`";
                `$global:currentLocation = `$currentDrive; 
                `$global:currentProject = `$null; 
            }"
            ForEach ($repoFolder in $repoFolders) {
                $goToFunction = $goToFunction + "`"" + $repoFolder.Name + "`" 
                { 
                    Set-Location -Path `"" + $currentDrive + "\" + $repoFolder.Name + "`" 
                if (Test-Path `"" + $currentDrive + "\" + $repoFolder.Name + "\Powershell\init.psm1`") 
                {   
                    Write-Host -ForegroundColor Green `"Init PSM1 Detected. Loading...`";
                    Import-Module -scope Global " + $currentDrive + "\" + $repoFolder.Name + "\Powershell\init.psm1; 
                } 
                `$global:currentLocation = `"" + $currentDrive + "\" + $repoFolder.Name + "`"; 
                `$global:currentProject = `$targetFolder; }"        
            }
            $goToFunction = $goToFunction + 
            "}    
        }";

Invoke-Expression $goToFunction;

$filesFunction = "Function Files 
    ([Parameter(Mandatory=`$false)] [RepoFolders]`$targetFolder){
        if(`$targetFolder -eq `$null) { 
            Invoke-Item `$currentLocation; 
        } 
        else {
            Switch(`$targetFolder){ 
                `"All`" { 
                    Invoke-Item `"" + $currentDrive + "\`";
                }"
                ForEach ($repoFolder in $repoFolders) {
                    $filesFunction = $filesFunction + "`"" + $repoFolder.Name + "`"
                    { 
                        Invoke-Item `"" + $currentDrive + "\" + $repoFolder.Name + "`";
                    }"        
                }
                $filesFunction = $filesFunction + 
            "} 
        } 
    }";

Invoke-Expression $filesFunction;

$runFunction = "Function Run 
    ([Parameter(Mandatory=`$false)] [RepoFolders]`$targetFolder){
        if(`$targetFolder -eq `$null) { 
            try { 
                Invoke-Expression (`"Invoke-Expression Run`" + `$global:currentProject) 
            } 
            catch { 
                Invoke-Expression `"Write-Host -ForegroundColor Red ```"Project```" `$global:currentProject```" Does Not Have Run Function```" `" 
            } 
        } 
        else {
            Switch(`$targetFolder){ 
                `"All`" { 
                    Write-Host -ForegroundColor Red `"Cannot Run All, Please Select A Project`"; 
                }"
                ForEach ($repoFolder in $repoFolders) {
                    $runFunction = $runFunction + "`"" + $repoFolder.Name + "`" { 
                        try { 
                            Invoke-Expression Run" + $repoFolder.Name + " 
                        } 
                        catch { 
                            Write-Host -ForegroundColor Red `"Project " + $repoFolder.Name + " Does Not Have Run Function`" 
                        } 
                    }"        
                }
                $runFunction = $runFunction + 
            "} 
        } 
    }";

Invoke-Expression $runFunction;

$buildFunction = "Function Build 
    ([Parameter(Mandatory=`$false)] [RepoFolders]`$targetFolder){
        if(`$targetFolder -eq `$null) { 
            try { 
                Invoke-Expression (`"Invoke-Expression Build`" + `$global:currentProject) 
            } 
            catch { 
                Invoke-Expression `"Write-Host -ForegroundColor Red ```"Project```" `$global:currentProject```" Does Not Have Build Function```" `" 
            } 
        } 
        else {
            Switch(`$targetFolder){ 
                `"All`" { 
                    Write-Host -ForegroundColor Red `"Cannot Build All, Please Select A Project`"; 
                }"
                ForEach ($repoFolder in $repoFolders) {
                    $buildFunction = $buildFunction + "`"" + $repoFolder.Name + "`" { 
                        try { 
                            Invoke-Expression Build" + $repoFolder.Name + " 
                        } 
                        catch { 
                            Write-Host -ForegroundColor Red `"Project " + $repoFolder.Name + " Does Not Have Build Function`" 
                        } 
                    }"        
                }
                $buildFunction = $buildFunction + 
            "} 
        } 
    }";

Invoke-Expression $buildFunction;

$testFunction = "Function Test 
    ([Parameter(Mandatory=`$false)] [RepoFolders]`$targetFolder){
        if(`$targetFolder -eq `$null) { 
            try { 
                Invoke-Expression (`"Invoke-Expression Test`" + `$global:currentProject) 
            } 
            catch { 
                Invoke-Expression `"Write-Host -ForegroundColor Red ```"Project```" `$global:currentProject```" Does Not Have Test Function```" `" 
            } 
        } 
        else {
            Switch(`$targetFolder){ 
                `"All`" { 
                    Write-Host -ForegroundColor Red `"Cannot Test All, Please Select A Project`"; 
                }"
                ForEach ($repoFolder in $repoFolders) {
                    $testFunction = $testFunction + "`"" + $repoFolder.Name + "`" { 
                        try { 
                            Invoke-Expression Test" + $repoFolder.Name + " 
                        } 
                        catch { 
                            Write-Host -ForegroundColor Red `"Project " + $repoFolder.Name + " Does Not Have Test Function`" 
                        } 
                    }"        
                }
                $testFunction = $testFunction + 
            "} 
        } 
    }";

Invoke-Expression $testFunction;

$openFunction = "Function Open 
    ([Parameter(Mandatory=`$false)] [RepoFolders]`$targetFolder){
        if(`$targetFolder -eq `$null) { 
            try { 
                Invoke-Expression (`"Invoke-Expression Open`" + `$global:currentProject) 
            } 
            catch { 
                Invoke-Expression `"Write-Host -ForegroundColor Red ```"Project```" `$global:currentProject```" Does Not Have Open Function```" `" 
            } 
        } 
        else {
            Switch(`$targetFolder){ 
                `"All`" { 
                    Write-Host -ForegroundColor Red `"Cannot Open All, Please Select A Project`"; 
                }"
                ForEach ($repoFolder in $repoFolders) {
                    $openFunction = $openFunction + "`"" + $repoFolder.Name + "`" { 
                        try { 
                            Invoke-Expression Open" + $repoFolder.Name + " 
                        } 
                        catch { 
                            Write-Host -ForegroundColor Red `"Project " + $repoFolder.Name + " Does Not Have Open Function`" 
                        } 
                    }"        
                }
                $openFunction = $openFunction + 
            "} 
        } 
    }";

Invoke-Expression $openFunction;

Write-Host -ForegroundColor Green "Powershell Init Complete";

GoToDrive;

