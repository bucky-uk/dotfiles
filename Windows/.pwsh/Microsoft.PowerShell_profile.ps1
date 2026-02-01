
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Local scripts
Unblock-File -Path $env:OneDrive\Apps\PowerShell\
# . $env:OneDrive\Apps\PowerShell\Modules\WOL\Send-WakeOnLan.ps1

#$WakeOnLanScript = "$env:OneDrive\Apps\PowerShell\Modules\WOL\Send-WakeOnLan.ps1"
#if (Test-Path($WakeOnLanScript)) {
#  . "$WakeOnLanScript"
#}

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\dracula.omp.json" | Invoke-Expression

# Custom functions
function Get-Tools {
    Install-Module -Name VirtualDesktop -Scope CurrentUser
    Install-Module -Name WakeOnLan -Scope CurrentUser
}

# EVE Online helpers
function Get-EveClient([string]$toon) {
    (Get-Process | Where-Object ProcessName -eq exefile | Select-Object * | Where-Object { $_.mainwindowtitle -match $toon })[0]
}

function Move-EveClient([string]$toon) {
    Get-Desktop $toon | Move-Window (Get-EveClient $toon).MainWindowHandle
}

function Close-EveClient([string]$toon) {
    Get-EveClient $toon | Stop-Process
}

function Move-AllEveClients() {
    Move-EveClient Bucky | Move-EveClient Steve | Move-EveClient Kaito | Move-EveClient Jerome
}

function Close-AllEveClients() {
    Stop-Process -Name exefile
}

function Close-Process([string]$processName) {
    Get-Process | Where-Object ProcessName -eq $processName | Stop-Process
}


function Edit-Profile {
    code $profile
}

Set-Alias terminate Close-Process
Set-Alias fwh Find-WindowHandle

Set-Alias gec Get-EveClient
Set-Alias mec Move-EveClient
Set-Alias cec Close-EveClient
Set-Alias maec Move-AllEveClients
Set-Alias caec Close-AllEveClients

Set-Alias ep Edit-Profile
Set-Alias sd Switch-Desktop
Set-Alias gd Get-Desktop
Set-Alias gcd Get-CurrentDesktop
Set-Alias gdc Get-DesktopCount
Set-Alias mw Move-Window
Set-Alias maw Move-ActiveWindow