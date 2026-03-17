$ConfigFile = "C:\burp_proxy.conf"
$OldProxyFile = "$env:TEMP\old_proxy.txt"

# If config missing, do nothing
if (!(Test-Path $ConfigFile)) {
    exit
}

$BurpIP, $BurpPort = Get-Content $ConfigFile

# Test Burp
$alive = Test-NetConnection -ComputerName $BurpIP -Port $BurpPort -InformationLevel Quiet

if ($alive -eq $false) {

    # Disable proxy
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" ProxyEnable 0

    # Restore old proxy if it existed
    if (Test-Path $OldProxyFile) {
        $old = Get-Content $OldProxyFile
        if ($old -ne "") {
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" ProxyServer $old
        }
    }

    # Remove Burp CA
    Get-ChildItem Cert:\LocalMachine\Root |
        Where-Object { $_.Subject -like "*PortSwigger*" } |
        Remove-Item -Force

   # Delete configuration and enable script
    Remove-Item "C:\burp_proxy.conf" -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\burp-enable.ps1" -Force -ErrorAction SilentlyContinue
    
    # Delete scheduled task
    schtasks /delete /tn "Burp Watchdog" /f
    
    # Delete watchdog script (last action the script takes)
    Remove-Item "C:\burp-watchdog.ps1" -Force -ErrorAction SilentlyContinue

}

