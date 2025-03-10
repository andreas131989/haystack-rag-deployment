# Important: Run this script as Administrator
# Check if running as admin
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    Write-Error "Please run this script as Administrator."
    exit
}

# Install Chocolatey if not present
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install Docker Desktop
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Docker Desktop..."
    choco install docker-desktop -y
    Write-Output "Docker Desktop installed. You may need to reboot and launch Docker Desktop manually."
}
else {
    Write-Output "Docker already installed."
}

# Install make
if (!(Get-Command make -ErrorAction SilentlyContinue)) {
    Write-Output "Installing make..."
    choco install make -y
}
else {
    Write-Output "make already installed."
}

# Modify hosts file
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$hostEntry = "127.0.0.1 rag.local"
if (-Not (Select-String -Path $hostsPath -Pattern $hostEntry -Quiet)) {
    Add-Content -Path $hostsPath -Value $hostEntry
    Write-Output "Hosts file updated."
}
else {
    Write-Output "Hosts entry already exists."
}

Write-Output "✅ All tasks completed."
