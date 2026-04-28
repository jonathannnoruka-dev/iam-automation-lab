# ============================================
# IAM Lab - Leaver Automation v1.0
# Reads a leaver list and deprovisioned all
# accounts securely with full audit trail
# ============================================

# Step 1: Define leavers (simulating an HR termination feed)
$Leavers = @(
    @{ Name = "Sarah Johnson"; Username = "sjohnson"; Department = "Finance"; Manager = "john.smith"; LastDay = "2026-04-26" },
    @{ Name = "James Okafor";  Username = "jokafor";  Department = "IT";      Manager = "jane.doe";   LastDay = "2026-04-26" }
)

# Step 2: Define what roles each department owns
# (In a real system this would be pulled from your IAM platform)
$DepartmentRoles = @{
    "Finance" = @("Finance-Read", "Finance-Write", "Expenses-Portal")
    "IT"      = @("IT-Admin", "Azure-Portal", "ServiceDesk")
    "HR"      = @("HR-System", "Recruitment-Portal")
}

$Report   = @()
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host "  IAM LEAVER DEPROVISIONING REPORT"         -ForegroundColor Red
Write-Host "  Generated : $Timestamp"                   -ForegroundColor Red
Write-Host "  Leavers   : $($Leavers.Count)"            -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red

# Step 3: Process each leaver
foreach ($Leaver in $Leavers) {

    $RolesRevoked = $DepartmentRoles[$Leaver.Department]

    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Gray
    Write-Host "Processing : $($Leaver.Name)" -ForegroundColor Yellow
    Write-Host "Username   : $($Leaver.Username)"
    Write-Host "Department : $($Leaver.Department)"
    Write-Host "Last Day   : $($Leaver.LastDay)"
    Write-Host "Manager    : $($Leaver.Manager)"

    # Simulate account disable
    Write-Host ""
    Write-Host "  [1] Disabling account..." -NoNewline
    Start-Sleep -Milliseconds 500
    Write-Host " DONE" -ForegroundColor Green

    # Simulate revoking roles
    Write-Host "  [2] Revoking roles..." -ForegroundColor Yellow
    foreach ($Role in $RolesRevoked) {
        Write-Host "      - Removing: $Role" -ForegroundColor Red
        Start-Sleep -Milliseconds 300
    }
    Write-Host "      All roles revoked!" -ForegroundColor Green

    # Simulate resource transfer
    Write-Host "  [3] Transferring resources to $($Leaver.Manager)..." -NoNewline
    Start-Sleep -Milliseconds 500
    Write-Host " DONE" -ForegroundColor Green

    # Simulate session termination
    Write-Host "  [4] Terminating active sessions..." -NoNewline
    Start-Sleep -Milliseconds 400
    Write-Host " DONE" -ForegroundColor Green

    Write-Host ""
    Write-Host "  Status: " -NoNewline
    Write-Host "DEPROVISIONED" -ForegroundColor Red

    # Build audit report row
    $Report += [PSCustomObject]@{
        Name          = $Leaver.Name
        Username      = $Leaver.Username
        Department    = $Leaver.Department
        LastDay       = $Leaver.LastDay
        Manager       = $Leaver.Manager
        RolesRevoked  = $RolesRevoked -join " | "
        Action        = "Account Disabled + Roles Revoked + Sessions Terminated"
        ProcessedBy   = "IAM-Automation"
        Timestamp     = $Timestamp
        Status        = "Deprovisioned"
    }
}

# Step 4: Save audit report
$ReportPath = ".\Leaver-Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host "  $($Leavers.Count) accounts deprovisioned!" -ForegroundColor Green
Write-Host "  Audit report saved to: $ReportPath"        -ForegroundColor Yellow
Write-Host "  All actions logged for compliance!"        -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Red