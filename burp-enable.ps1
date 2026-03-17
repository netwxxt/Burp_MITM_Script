$ConfigFile = "C:\burp_proxy.conf"
$OldProxyFile = "$env:TEMP\old_proxy.txt"

# If config doesn't exist, ask for it
if (!(Test-Path $ConfigFile)) {
    Write-Host "Burp config not found. Please enter it."

    $BurpIP = Read-Host "Enter Burp IP"
    $BurpPort = Read-Host "Enter Burp Port (usually 8080)"

    "$BurpIP`n$BurpPort" | Out-File $ConfigFile -Encoding ASCII
    Write-Host "Saved to $ConfigFile"
}
else {
    $lines = Get-Content $ConfigFile
    $BurpIP = $lines[0].Trim()
    $BurpPort = $lines[1].Trim()
    Write-Host "Using saved Burp config: $BurpIP:$BurpPort"
}

$BurpURL = "http://$BurpIP`:$BurpPort"
$CertURL = "$BurpURL/cert"
$CertPath = "$env:TEMP\burp_ca.der"

# Save existing proxy
$OldProxy = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").ProxyServer
Set-Content $OldProxyFile $OldProxy

# Enable proxy
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" ProxyEnable 1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" ProxyServer "${BurpIP}:${BurpPort}"

# Open Burp page
Start-Process $BurpURL

# Download cert (retry loop in case Burp isn't ready)
$retries = 5
for ($i = 0; $i -lt $retries; $i++) {
    try {
        Invoke-WebRequest -Uri $CertURL -OutFile $CertPath -ErrorAction Stop
        break
    } catch {
        Write-Host "Waiting for Burp... ($($i+1)/$retries)"
        Start-Sleep -Seconds 3
    }
}

# Exits if cert download fails
if (!(Test-Path $CertPath)) {
    Write-Host "Failed to download Burp cert. Is Burp running?"
    exit 1
}

# Install cert
Import-Certificate -FilePath $CertPath -CertStoreLocation Cert:\LocalMachine\Root

Write-Host ""
Write-Host "Burp proxy + CA enabled"

# Creates a task to run burp-watchdog.ps1 every minute
schtasks /create /sc minute /mo 1 /tn "Burp Watchdog" /tr "powershell -ExecutionPolicy Bypass -File C:\burp-watchdog.ps1" /ru SYSTEM /f