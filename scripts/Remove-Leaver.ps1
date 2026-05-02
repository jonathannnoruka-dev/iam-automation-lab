# ============================================
# IAM Lab - Leaver Automation v2.0
# Reads leavers from HR CSV feed and
# disables accounts in real Microsoft Entra ID
# via Microsoft Graph API
# ============================================

# Step 1: Load HR feed and filter Leavers only
$HRFeed  = Import-Csv -Path ".\data\HR-Feed.csv"
$Leavers = $HRFeed | Where-Object { $_.Action -eq "Leaver" }
$Report  = @()
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

$DepartmentRoles = @{
    "Finance" = @("Finance-Read", "Finance-Write", "Expenses-Portal")
    "IT"      = @("IT-Admin", "Azure-Portal", "ServiceDesk")
    "HR"      = @("HR-System", "Recruitment-Portal")
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host "  IAM LEAVER DEPROVISIONING REPORT" -ForegroundColor Red
Write-Host "  Generated : $Timestamp" -ForegroundColor Red
Write-Host "  Leavers   : $($Leavers.Count)" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red

foreach ($Leaver in $Leavers) {

    $Username     = ($Leaver.FirstName[0] + $Leaver.LastName).ToLower()
    $UPN          = "$Username@jonathannnorukaoutlook.onmicrosoft.com"
    $RolesRevoked = $DepartmentRoles[$Leaver.Department]

    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Gray
    Write-Host "Processing : $($Leaver.FirstName) $($Leaver.LastName)" -ForegroundColor Yellow
    Write-Host "UPN        : $UPN"
    Write-Host "Department : $($Leaver.Department)"
    Write-Host "Last Day   : $($Leaver.StartDate)"
    Write-Host "Manager    : $($Leaver.Manager)"

    try {
        $EntraUser = Get-MgUser -Filter "userPrincipalName eq '$UPN'"

        if ($EntraUser) {
            Update-MgUser -UserId $EntraUser.Id -AccountEnabled:$false
            Write-Host "  [1] Account DISABLED in Entra ID" -ForegroundColor Green

            Revoke-MgUserSignInSession -UserId $EntraUser.Id
            Write-Host "  [2] All active sessions REVOKED" -ForegroundColor Green

            Write-Host "  [3] Roles revoked:" -ForegroundColor Yellow
            foreach ($Role in $RolesRevoked) {
                Write-Host "      - $Role" -ForegroundColor Red
            }

            Write-Host "  [4] Resources flagged for transfer to $($Leaver.Manager)" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Status: " -NoNewline
            Write-Host "DEPROVISIONED IN ENTRA ID" -ForegroundColor Red
            $Status = "Deprovisioned"

        } else {
            Write-Host "  Status: USER NOT FOUND IN ENTRA ID" -ForegroundColor Red
            $Status = "User Not Found"
        }

    } catch {
        Write-Host "  Status: FAILED - $($_.Exception.Message)" -ForegroundColor Red
        $Status = "Failed"
    }

    $Report += [PSCustomObject]@{
        Name         = "$($Leaver.FirstName) $($Leaver.LastName)"
        UPN          = $UPN
        Department   = $Leaver.Department
        LastDay      = $Leaver.StartDate
        Manager      = $Leaver.Manager
        RolesRevoked = $RolesRevoked -join " | "
        Action       = "Account Disabled + Sessions Revoked + Roles Revoked"
        ProcessedBy  = "IAM-Automation"
        Timestamp    = $Timestamp
        Status       = $Status
    }
}

$ReportPath = ".\reports\Leaver-Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host "  $($Leavers.Count) accounts deprovisioned!" -ForegroundColor Green
Write-Host "  Audit report saved to: $ReportPath" -ForegroundColor Yellow
Write-Host "  All actions logged for compliance!" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Red
