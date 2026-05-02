# ============================================
# IAM Lab - Bulk New Joiner Automation v3.0
# Reads from HR CSV feed and provisions all
# new starters into real Microsoft Entra ID
# via Microsoft Graph API
# ============================================

# Step 1: Load the HR feed and filter Joiners only
$HRFeed  = Import-Csv -Path ".\data\HR-Feed.csv"
$Joiners = $HRFeed | Where-Object { $_.Action -eq "Joiner" }
$Report  = @()
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  IAM BULK PROVISIONING REPORT" -ForegroundColor Cyan
Write-Host "  Generated: $Timestamp" -ForegroundColor Cyan
Write-Host "  Total New Joiners: $($Joiners.Count)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

foreach ($Employee in $Joiners) {

    $Username = ($Employee.FirstName[0] + $Employee.LastName).ToLower()
    $UPN      = "$Username@jonathannnorukaoutlook.onmicrosoft.com"

    $Roles = switch ($Employee.Department) {
        "Finance" { @("Finance-Read", "Finance-Write", "Expenses-Portal") }
        "IT"      { @("IT-Admin", "Azure-Portal", "ServiceDesk") }
        "HR"      { @("HR-System", "Recruitment-Portal") }
        default   { @("General-Access") }
    }

    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Gray
    Write-Host "Name       : $($Employee.FirstName) $($Employee.LastName)"
    Write-Host "Username   : $Username"
    Write-Host "UPN        : $UPN"
    Write-Host "Department : $($Employee.Department)"
    Write-Host "Job Title  : $($Employee.JobTitle)"
    Write-Host "Start Date : $($Employee.StartDate)"
    Write-Host "Manager    : $($Employee.Manager)"
    Write-Host "Roles      : $($Roles -join ', ')" -ForegroundColor Green

    try {
        $PasswordProfile = @{
            Password                      = "TempPass@2024!"
            ForceChangePasswordNextSignIn = $true
        }

        New-MgUser `
            -DisplayName "$($Employee.FirstName) $($Employee.LastName)" `
            -UserPrincipalName $UPN `
            -MailNickname $Username `
            -AccountEnabled `
            -PasswordProfile $PasswordProfile `
            -JobTitle $Employee.JobTitle `
            -Department $Employee.Department

        Write-Host "Status     : " -NoNewline
        Write-Host "PROVISIONED IN ENTRA ID" -ForegroundColor Green
        $Status = "Provisioned"

    } catch {
        Write-Host "Status     : " -NoNewline
        Write-Host "FAILED - $($_.Exception.Message)" -ForegroundColor Red
        $Status = "Failed"
    }

    $Report += [PSCustomObject]@{
        Name       = "$($Employee.FirstName) $($Employee.LastName)"
        Username   = $Username
        UPN        = $UPN
        Department = $Employee.Department
        JobTitle   = $Employee.JobTitle
        Roles      = $Roles -join " | "
        Status     = $Status
        Date       = $Timestamp
    }
}

$ReportPath = ".\reports\Provisioning-Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Processing complete!" -ForegroundColor Green
Write-Host "  Report saved to: $ReportPath" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
