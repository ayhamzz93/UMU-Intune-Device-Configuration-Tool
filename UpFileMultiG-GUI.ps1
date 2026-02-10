# Intune Device Configuration Tool - Modern GUI Version
# Requires Windows PowerShell and .NET Framework
# GitHub Remote Execution Ready

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges. Attempting to restart as Administrator..."
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm 'https://raw.githubusercontent.com/ayhamzz93/UMU-Intune-Device-Configuration-Tool/refs/heads/main/UpFileMultiG-GUI.ps1')`""
    exit
}

# Set execution policy for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Load required assemblies with error handling
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
}
catch {
    Write-Error "Failed to load required .NET assemblies. Please ensure .NET Framework is properly installed."
    Read-Host "Press Enter to exit"
    exit 1
}

# Global variables
$global:Action = ""
$global:assignedUser = $null                     
$global:GroupTag = $null
$global:ComputerName = $null

# Script metadata for GitHub hosting
$global:ScriptVersion = "2.0"
$global:ScriptTitle = "Intune Device Configuration Tool - GUI"

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Intune Device Configuration"
$form.Size = New-Object System.Drawing.Size(500, 650)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Logo PictureBox
$logoPictureBox = New-Object System.Windows.Forms.PictureBox
$logoPictureBox.Size = New-Object System.Drawing.Size(80, 80)
$logoPictureBox.Location = New-Object System.Drawing.Point(25, 15)
$logoPictureBox.SizeMode = "StretchImage"
$logoPictureBox.BackColor = [System.Drawing.Color]::Transparent

# Try to load logo image from GitHub or create placeholder
$logoUrl = "https://raw.githubusercontent.com/ayhamzz93/UMU-Intune-Device-Configuration-Tool/main/UMU.png"  # GitHub raw URL for logo
try {
    # Try to download logo from GitHub
    $webClient = New-Object System.Net.WebClient
    $logoBytes = $webClient.DownloadData($logoUrl)
    $logoStream = New-Object System.IO.MemoryStream($logoBytes, 0, $logoBytes.Length)
    $logoPictureBox.Image = [System.Drawing.Image]::FromStream($logoStream)
}
catch {
    # If logo fails to load from GitHub, create a professional placeholder
    $logoPictureBox.BackColor = [System.Drawing.Color]::FromArgb(0, 102, 153)  # Professional Blue #006699
    $logoLabel = New-Object System.Windows.Forms.Label
    $logoLabel.Text = "UMU"
    $logoLabel.ForeColor = [System.Drawing.Color]::White
    $logoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
    $logoLabel.TextAlign = "MiddleCenter"
    $logoLabel.Dock = "Fill"
    $logoPictureBox.Controls.Add($logoLabel)
}
$form.Controls.Add($logoPictureBox)

# Title Label (moved to accommodate logo)
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Intune Device Configuration-UMU"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 102, 153)  # Professional Blue #006699
$titleLabel.Size = New-Object System.Drawing.Size(350, 40)
$titleLabel.Location = New-Object System.Drawing.Point(120, 30)
$titleLabel.TextAlign = "MiddleLeft"
$form.Controls.Add($titleLabel)

# Subtitle Label
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Configure devices for Microsoft Intune - v$global:ScriptVersion"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$subtitleLabel.ForeColor = [System.Drawing.Color]::Gray
$subtitleLabel.Size = New-Object System.Drawing.Size(350, 20)
$subtitleLabel.Location = New-Object System.Drawing.Point(120, 70)
$subtitleLabel.TextAlign = "MiddleLeft"
$form.Controls.Add($subtitleLabel)

# Separator line
$separator1 = New-Object System.Windows.Forms.Panel
$separator1.BackColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$separator1.Size = New-Object System.Drawing.Size(450, 1)
$separator1.Location = New-Object System.Drawing.Point(25, 105)
$form.Controls.Add($separator1)

# Action Selection Group
$actionGroupBox = New-Object System.Windows.Forms.GroupBox
$actionGroupBox.Text = "Select Action"
$actionGroupBox.Size = New-Object System.Drawing.Size(450, 80)
$actionGroupBox.Location = New-Object System.Drawing.Point(25, 120)
$actionGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($actionGroupBox)

$addRadio = New-Object System.Windows.Forms.RadioButton
$addRadio.Text = "Add New Device"
$addRadio.Location = New-Object System.Drawing.Point(20, 25)
$addRadio.Size = New-Object System.Drawing.Size(150, 20)
$addRadio.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$addRadio.Checked = $true
$actionGroupBox.Controls.Add($addRadio)

$editRadio = New-Object System.Windows.Forms.RadioButton
$editRadio.Text = "Edit Existing Device"
$editRadio.Location = New-Object System.Drawing.Point(20, 50)
$editRadio.Size = New-Object System.Drawing.Size(150, 20)
$editRadio.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$actionGroupBox.Controls.Add($editRadio)

# Configuration Options Group
$configGroupBox = New-Object System.Windows.Forms.GroupBox
$configGroupBox.Text = "Configuration Options"
$configGroupBox.Size = New-Object System.Drawing.Size(450, 200)
$configGroupBox.Location = New-Object System.Drawing.Point(25, 215)
$configGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($configGroupBox)

# User Assignment Section
$userCheckBox = New-Object System.Windows.Forms.CheckBox
$userCheckBox.Text = "Assign User"
$userCheckBox.Location = New-Object System.Drawing.Point(20, 30)
$userCheckBox.Size = New-Object System.Drawing.Size(100, 20)
$userCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$configGroupBox.Controls.Add($userCheckBox)

$userTextBox = New-Object System.Windows.Forms.TextBox
$userTextBox.Location = New-Object System.Drawing.Point(130, 28)
$userTextBox.Size = New-Object System.Drawing.Size(200, 20)
$userTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$userTextBox.Enabled = $false
$configGroupBox.Controls.Add($userTextBox)

$userLabel = New-Object System.Windows.Forms.Label
$userLabel.Text = "Enter username followed by @ad.umu.se"
$userLabel.Location = New-Object System.Drawing.Point(130, 52)
$userLabel.Size = New-Object System.Drawing.Size(250, 15)
$userLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$userLabel.ForeColor = [System.Drawing.Color]::Gray
$configGroupBox.Controls.Add($userLabel)

# Group Tag Section
$groupTagCheckBox = New-Object System.Windows.Forms.CheckBox
$groupTagCheckBox.Text = "Group Tag"
$groupTagCheckBox.Location = New-Object System.Drawing.Point(20, 80)
$groupTagCheckBox.Size = New-Object System.Drawing.Size(100, 20)
$groupTagCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$configGroupBox.Controls.Add($groupTagCheckBox)

$groupTagTextBox = New-Object System.Windows.Forms.TextBox
$groupTagTextBox.Location = New-Object System.Drawing.Point(130, 78)
$groupTagTextBox.Size = New-Object System.Drawing.Size(200, 20)
$groupTagTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$groupTagTextBox.Enabled = $false
$configGroupBox.Controls.Add($groupTagTextBox)

$groupTagLabel = New-Object System.Windows.Forms.Label
$groupTagLabel.Text = "Enter profile name provided by ITS"
$groupTagLabel.Location = New-Object System.Drawing.Point(130, 102)
$groupTagLabel.Size = New-Object System.Drawing.Size(250, 15)
$groupTagLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$groupTagLabel.ForeColor = [System.Drawing.Color]::Gray
$configGroupBox.Controls.Add($groupTagLabel)

# Computer Name Section (only visible for Edit mode)
$computerNameCheckBox = New-Object System.Windows.Forms.CheckBox
$computerNameCheckBox.Text = "Computer Name"
$computerNameCheckBox.Location = New-Object System.Drawing.Point(20, 130)
$computerNameCheckBox.Size = New-Object System.Drawing.Size(120, 20)
$computerNameCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$computerNameCheckBox.Visible = $false
$configGroupBox.Controls.Add($computerNameCheckBox)

$computerNameTextBox = New-Object System.Windows.Forms.TextBox
$computerNameTextBox.Location = New-Object System.Drawing.Point(130, 128)
$computerNameTextBox.Size = New-Object System.Drawing.Size(200, 20)
$computerNameTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$computerNameTextBox.Enabled = $false
$computerNameTextBox.Visible = $false
$configGroupBox.Controls.Add($computerNameTextBox)

$computerNameLabel = New-Object System.Windows.Forms.Label
$computerNameLabel.Text = "Enter computer name"
$computerNameLabel.Location = New-Object System.Drawing.Point(130, 152)
$computerNameLabel.Size = New-Object System.Drawing.Size(250, 15)
$computerNameLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$computerNameLabel.ForeColor = [System.Drawing.Color]::Gray
$computerNameLabel.Visible = $false
$configGroupBox.Controls.Add($computerNameLabel)

# Progress Section
$progressGroupBox = New-Object System.Windows.Forms.GroupBox
$progressGroupBox.Text = "Progress"
$progressGroupBox.Size = New-Object System.Drawing.Size(450, 100)
$progressGroupBox.Location = New-Object System.Drawing.Point(25, 430)
$progressGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($progressGroupBox)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 25)
$progressBar.Size = New-Object System.Drawing.Size(410, 20)
$progressBar.Style = "Continuous"
$progressGroupBox.Controls.Add($progressBar)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready to start..."
$statusLabel.Location = New-Object System.Drawing.Point(20, 50)
$statusLabel.Size = New-Object System.Drawing.Size(410, 20)
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 102, 153)  # Professional Blue #006699
$progressGroupBox.Controls.Add($statusLabel)

$jobIdLabel = New-Object System.Windows.Forms.Label
$jobIdLabel.Text = ""
$jobIdLabel.Location = New-Object System.Drawing.Point(20, 70)
$jobIdLabel.Size = New-Object System.Drawing.Size(410, 20)
$jobIdLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$jobIdLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 140, 0)
$progressGroupBox.Controls.Add($jobIdLabel)

# Buttons
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Text = "Execute Configuration"
$executeButton.Size = New-Object System.Drawing.Size(130, 35)
$executeButton.Location = New-Object System.Drawing.Point(70, 545)
$executeButton.BackColor = [System.Drawing.Color]::FromArgb(0, 102, 153)  # Professional Blue #006699
$executeButton.ForeColor = [System.Drawing.Color]::White
$executeButton.FlatStyle = "Flat"
$executeButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($executeButton)

$shutdownButton = New-Object System.Windows.Forms.Button
$shutdownButton.Text = "Shutdown Computer"
$shutdownButton.Size = New-Object System.Drawing.Size(130, 35)
$shutdownButton.Location = New-Object System.Drawing.Point(210, 545)
$shutdownButton.BackColor = [System.Drawing.Color]::FromArgb(180, 50, 50)
$shutdownButton.ForeColor = [System.Drawing.Color]::White
$shutdownButton.FlatStyle = "Flat"
$shutdownButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($shutdownButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Close"
$cancelButton.Size = New-Object System.Drawing.Size(80, 35)
$cancelButton.Location = New-Object System.Drawing.Point(350, 545)
$cancelButton.BackColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
$cancelButton.ForeColor = [System.Drawing.Color]::Black
$cancelButton.FlatStyle = "Flat"
$cancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Controls.Add($cancelButton)

# Event Handlers
$userCheckBox.Add_CheckedChanged({
    $userTextBox.Enabled = $userCheckBox.Checked
    if (-not $userCheckBox.Checked) {
        $userTextBox.Text = ""
    }
})

$groupTagCheckBox.Add_CheckedChanged({
    $groupTagTextBox.Enabled = $groupTagCheckBox.Checked
    if (-not $groupTagCheckBox.Checked) {
        $groupTagTextBox.Text = ""
    }
})

$computerNameCheckBox.Add_CheckedChanged({
    $computerNameTextBox.Enabled = $computerNameCheckBox.Checked
    if (-not $computerNameCheckBox.Checked) {
        $computerNameTextBox.Text = ""
    }
})

$addRadio.Add_CheckedChanged({
    if ($addRadio.Checked) {
        $computerNameCheckBox.Visible = $false
        $computerNameTextBox.Visible = $false
        $computerNameLabel.Visible = $false
        $computerNameCheckBox.Checked = $false
        $computerNameTextBox.Text = ""
        $groupTagLabel.Text = "Enter profile name provided by ITS"
    }
})

$editRadio.Add_CheckedChanged({
    if ($editRadio.Checked) {
        $computerNameCheckBox.Visible = $true
        $computerNameTextBox.Visible = $true
        $computerNameLabel.Visible = $true
        $groupTagLabel.Text = "Enter group tag provided by ITS"
    }
})

$cancelButton.Add_Click({
    $form.Close()
})

$shutdownButton.Add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to shutdown this computer?", "Shutdown Confirmation", "YesNo", "Warning")
    if ($result -eq "Yes") {
        [System.Windows.Forms.MessageBox]::Show("Computer will shutdown in 10 seconds. Save your work now!", "Shutdown Warning", "OK", "Warning")
        Start-Process "shutdown" -ArgumentList "/s /t 10" -WindowStyle Hidden
        $form.Close()
    }
})

$executeButton.Add_Click({
    # Validate inputs
    if ($userCheckBox.Checked -and [string]::IsNullOrWhiteSpace($userTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a username or uncheck the 'Assign User' option.", "Input Error", "OK", "Warning")
        return
    }
    
    if ($groupTagCheckBox.Checked -and [string]::IsNullOrWhiteSpace($groupTagTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a group tag or uncheck the 'Group Tag' option.", "Input Error", "OK", "Warning")
        return
    }
    
    if ($editRadio.Checked -and $computerNameCheckBox.Checked -and [string]::IsNullOrWhiteSpace($computerNameTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a computer name or uncheck the 'Computer Name' option.", "Input Error", "OK", "Warning")
        return
    }

    # Set global variables based on form inputs
    $global:Action = if ($addRadio.Checked) { "Add" } else { "Edit" }
    $global:assignedUser = if ($userCheckBox.Checked) { $userTextBox.Text } else { $null }
    $global:GroupTag = if ($groupTagCheckBox.Checked) { $groupTagTextBox.Text } else { $null }
    $global:ComputerName = if ($computerNameCheckBox.Checked) { $computerNameTextBox.Text } else { $null }

    # Disable the execute button and show progress
    $executeButton.Enabled = $false
    $progressBar.Value = 0
    $statusLabel.Text = "Starting configuration process..."
    $form.Refresh()

    try {
        # Execute the main script logic
        ExecuteMainScript
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", "OK", "Error")
        $statusLabel.Text = "Error occurred during execution"
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
    }
    finally {
        $executeButton.Enabled = $true
    }
})

# Main script execution function
function ExecuteMainScript {
    $statusLabel.Text = "Creating hash directory..."
    $progressBar.Value = 10
    $form.Refresh()

    # Sets Hash Directory and Generates HardwareHash file
    # Use temp directory for remote execution compatibility
    $tempPath = [System.IO.Path]::GetTempPath()
    $CSVPath = New-Item -Path $tempPath -Name "IntuneDeviceHash" -ItemType Directory -Force
    $serialnumber = Get-WmiObject win32_bios | Select-Object Serialnumber

    $statusLabel.Text = "Installing required packages..."
    $progressBar.Value = 20
    $form.Refresh()

    Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.201 -Force | Out-Null
    Install-Script -Name Get-WindowsAutoPilotInfo -Force
    Set-ExecutionPolicy bypass -Force

    $statusLabel.Text = "Generating hardware hash..."
    $progressBar.Value = 40
    $form.Refresh()

    Get-WindowsAutoPilotInfo -Outputfile $CSVPath\$($serialnumber.SerialNumber)-Hash.csv

    $statusLabel.Text = "Processing hash file..."
    $progressBar.Value = 60
    $form.Refresh()

    # Hash File processing
    $file = Get-ChildItem -Path $CSVPath | Where-Object -Property Name -Like "*.csv"
    $file = $file.FullName

    $file = Import-Csv -Path $file
    $serialNumber = $file.'Device Serial Number'
    $Hash = $file.'Hardware Hash'

    # Fix txt file
    $serialNumber + "+" + $Hash | Out-File $CSVPath\$serialNumber.txt
    $file = Get-ChildItem -Path $CSVPath | Where-Object -Property Name -Like "*.txt"
    $file = $file.FullName
    $file = Get-Content -Path $file

    $pos = $file.IndexOf("+")
    $leftPart = $file.Substring(0, $pos)
    $rightPart = $file.Substring($pos+1)

    $statusLabel.Text = "Preparing device information..."
    $progressBar.Value = 70
    $form.Refresh()

    # Set Device info
    $deviceInfo1 = @{
        serialNumber = $leftPart
        hardwareIdentifier = $rightPart
        GroupTag = $global:GroupTag
        Action = $global:Action
        User = $global:assignedUser
        ComputerName = $global:ComputerName
    }
    $deviceInfo = $deviceInfo1 | ConvertTo-Json

    $statusLabel.Text = "Triggering webhook..."
    $progressBar.Value = 80
    $form.Refresh()

    # Trigger Webhook
    $uri = 'https://c12c6805-7e33-44ea-a095-2105f519a048.webhook.sec.azure-automation.net/webhooks?token=dAAYVzr2uP1xj7ZhxjZV0njrT%2bPmEK60vJRKEnWUveE%'
    $body = $deviceInfo
    $header = @{"Content-Type" = "application/json"}
    $response = Invoke-WebRequest -Method Post -Uri $uri -Body $body -Headers $header -UseBasicParsing
    $jobid = (ConvertFrom-Json ($response.Content)).jobids[0]

    $progressBar.Value = 100
    $statusLabel.Text = "Task completed successfully!"
    $statusLabel.ForeColor = [System.Drawing.Color]::Green
    $jobIdLabel.Text = "Job ID: $jobid"
    $form.Refresh()

    [System.Windows.Forms.MessageBox]::Show("Configuration completed successfully!`nJob ID: $jobid", "Success", "OK", "Information")
}

# Show the form
$form.ShowDialog()

