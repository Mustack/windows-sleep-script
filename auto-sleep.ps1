Add-Type -AssemblyName PresentationFramework

$buttonPressed = $null
$timeoutMinutes = 15
$timeLeft = [TimeSpan]::FromMinutes($timeoutMinutes)

# Window Setup
$window = New-Object System.Windows.Window
$window.Title = "Scheduled Sleep"
$window.Width = 420
$window.Height = 320
$window.WindowStartupLocation = "CenterScreen"
$window.Topmost = $true

$stack = New-Object System.Windows.Controls.StackPanel
$stack.Margin = "20"

# Countdown label
$countdown = New-Object System.Windows.Controls.TextBlock
$countdown.FontSize = 18
$countdown.Margin = "0,0,0,20"
$countdown.TextAlignment = "Center"
$countdown.Text = "Time until shutdown: $($timeLeft.ToString())"
$stack.Children.Add($countdown)

# Info text
$text = New-Object System.Windows.Controls.TextBlock
$text.Text = "Your PC is scheduled to sleep.\n\nIf you do nothing for $timeoutMinutes minutes, it will automatically SHUT DOWN."
$text.TextWrapping = "Wrap"
$text.Margin = "0,0,0,20"
$stack.Children.Add($text)

### BUTTONS ###

$btnSleep = New-Object System.Windows.Controls.Button
$btnSleep.Content = "Sleep Now"
$btnSleep.Margin = "0,0,0,10"
$btnSleep.Add_Click({
    $global:buttonPressed = "sleep"
    $window.Close()
})
$stack.Children.Add($btnSleep)

$btnSnooze1 = New-Object System.Windows.Controls.Button
$btnSnooze1.Content = "Snooze 1 Hour"
$btnSnooze1.Margin = "0,0,0,10"
$btnSnooze1.Add_Click({
    $global:buttonPressed = "snooze1"
    $window.Close()
})
$stack.Children.Add($btnSnooze1)

$btnSnooze2 = New-Object System.Windows.Controls.Button
$btnSnooze2.Content = "Snooze 2 Hours"
$btnSnooze2.Margin = "0,0,0,10"
$btnSnooze2.Add_Click({
    $global:buttonPressed = "snooze2"
    $window.Close()
})
$stack.Children.Add($btnSnooze2)

$btnCancel = New-Object System.Windows.Controls.Button
$btnCancel.Content = "Cancel"
$btnCancel.Add_Click({
    $global:buttonPressed = "cancel"
    $window.Close()
})
$stack.Children.Add($btnCancel)

$window.Content = $stack

### TIMERS ###

# 1-second countdown timer
$countdownTimer = New-Object System.Windows.Threading.DispatcherTimer
$countdownTimer.Interval = [TimeSpan]::FromSeconds(1)
$countdownTimer.Add_Tick({
    $timeLeft = $timeLeft - [TimeSpan]::FromSeconds(1)
    $countdown.Text = "Time until shutdown: $($timeLeft.ToString())"

    if ($timeLeft.TotalSeconds -le 0) {
        $global:buttonPressed = "timeout"
        $window.Close()
    }
})
$countdownTimer.Start()

# Auto-shutdown failsafe (15 min)
$autoShutdownTimer = New-Object System.Windows.Threading.DispatcherTimer
$autoShutdownTimer.Interval = [TimeSpan]::FromMinutes($timeoutMinutes)
$autoShutdownTimer.Add_Tick({
    $global:buttonPressed = "timeout"
    $window.Close()
})
$autoShutdownTimer.Start()

# Show UI
$null = $window.ShowDialog()

### OUTCOME ###

switch ($global:buttonPressed) {
    "sleep" {
        rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    }
    "snooze1" {
        Start-Sleep -Seconds (60 * 60)
        rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    }
    "snooze2" {
        Start-Sleep -Seconds (60 * 60 * 2)
        rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    }
    "timeout" {
        shutdown /s /t 0
    }
    default {
        # Cancel → do nothing
    }
}
