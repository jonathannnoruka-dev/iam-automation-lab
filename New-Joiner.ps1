# ============================================
# IAM Lab - Bulk New Joiner Automation v2.0
# Reads from HR CSV feed and provisions all
# new starters automatically
# ============================================

# Step 1: Load the HR feed
$HRFeed = Import-Csv -Path ".\HR-Feed.csv"
$Report = @()
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  IAM BULK PROVISIONING REPORT" -ForegroundColor Cyan
Write-Host "  Generated: $Timestamp" -ForegroundColor Cyan
Write-Host "  Total New Joiners: $($HRFeed.Count)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Step 2: Loop through every employee in the CSV
foreach ($Employee in $HRFeed) {

    # Generate username and email
    $Username = ($Employee.FirstName[0] + $Employee.LastName).ToLower()
    $Email    = "$Username@algorithmia.com"

    # Assign roles based on department
    $Roles = switch ($Employee.Department) {
        "Finance" { @("Finance-Read", "Finance-Write", "Expenses-Portal") }
        "IT"      { @("IT-Admin", "Azure-Portal", "ServiceDesk") }
        "HR"      { @("HR-System", "Recruitment-Portal") }
        default   { @("General-Access") }
    }

    # Display each user's provisioning details
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Gray
    Write-Host "Name       : $($Employee.FirstName) $($Employee.LastName)"
    Write-Host "Username   : $Username"
    Write-Host "Email      : $Email"
    Write-Host "Department : $($Employee.Department)"
    Write-Host "Job Title  : $($Employee.JobTitle)"
    Write-Host "Start Date : $($Employee.StartDate)"
    Write-Host "Manager    : $($Employee.Manager)"
    Write-Host "Roles      : $($Roles -join ', ')" -ForegroundColor Green
    Write-Host "Status     : " -NoNewline
    Write-Host "PROVISIONED" -ForegroundColor Green

    # Build report row
    $Report += [PSCustomObject]@{
        Name       = "$($Employee.FirstName) $($Employee.LastName)"
        Username   = $Username
        Email      = $Email
        Department = $Employee.Department
        Roles      = $Roles -join " | "
        Status     = "Provisioned"
        Date       = $Timestamp
    }
}

# Step 3: Save report to CSV file
$ReportPath = ".\Provisioning-Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  All $($HRFeed.Count) accounts provisioned!" -ForegroundColor Green
Write-Host "  Report saved to: $ReportPath" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan