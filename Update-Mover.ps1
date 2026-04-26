# ============================================
# IAM Lab - Mover Automation v1.0
# Handles department transfers by revoking
# old roles and assigning new ones
# ============================================

# Step 1: Define movers (simulating an HR transfer feed)
$Movers = @(
    @{
        Name           = "Priya Patel"
        Username       = "ppatel"
        OldDepartment  = "HR"
        NewDepartment  = "Finance"
        NewJobTitle    = "Finance Business Partner"
        NewManager     = "john.smith"
        EffectiveDate  = "2026-05-01"
    },
    @{
        Name           = "Jonathan Nnoruka"
        Username       = "jnnoruka"
        OldDepartment  = "IT"
        NewDepartment  = "HR"
        NewJobTitle    = "IAM Governance Lead"
        NewManager     = "mike.jones"
        EffectiveDate  = "2026-05-01"
    }
)

# Step 2: Role definitions per department
$DepartmentRoles = @{
    "Finance" = @("Finance-Read", "Finance-Write", "Expenses-Portal")
    "IT"      = @("IT-Admin", "Azure-Portal", "ServiceDesk")
    "HR"      = @("HR-System", "Recruitment-Portal")
}

$Report    = @()
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  IAM MOVER / TRANSFER REPORT"               -ForegroundColor Magenta
Write-Host "  Generated  : $Timestamp"                   -ForegroundColor Magenta
Write-Host "  Transfers  : $($Movers.Count)"             -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta

# Step 3: Process each mover
foreach ($Mover in $Movers) {

    $OldRoles = $DepartmentRoles[$Mover.OldDepartment]
    $NewRoles = $DepartmentRoles[$Mover.NewDepartment]

    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Gray
    Write-Host "Employee   : $($Mover.Name)" -ForegroundColor Yellow
    Write-Host "Username   : $($Mover.Username)"
    Write-Host "Transfer   : $($Mover.OldDepartment) --> $($Mover.NewDepartment)" -ForegroundColor Cyan
    Write-Host "New Title  : $($Mover.NewJobTitle)"
    Write-Host "New Manager: $($Mover.NewManager)"
    Write-Host "Effective  : $($Mover.EffectiveDate)"

    # Revoke old roles
    Write-Host ""
    Write-Host "  [1] Revoking OLD roles ($($Mover.OldDepartment))..." -ForegroundColor Yellow
    foreach ($Role in $OldRoles) {
        Write-Host "      - Removing: $Role" -ForegroundColor Red
        Start-Sleep -Milliseconds 300
    }
    Write-Host "      Old roles cleared!" -ForegroundColor Green

    # Assign new roles
    Write-Host "  [2] Assigning NEW roles ($($Mover.NewDepartment))..." -ForegroundColor Yellow
    foreach ($Role in $NewRoles) {
        Write-Host "      + Adding: $Role" -ForegroundColor Green
        Start-Sleep -Milliseconds 300
    }
    Write-Host "      New roles assigned!" -ForegroundColor Green

    # Update profile
    Write-Host "  [3] Updating profile and manager..." -NoNewline
    Start-Sleep -Milliseconds 500
    Write-Host " DONE" -ForegroundColor Green

    # Notify manager
    Write-Host "  [4] Notifying new manager $($Mover.NewManager)..." -NoNewline
    Start-Sleep -Milliseconds 400
    Write-Host " DONE" -ForegroundColor Green

    Write-Host ""
    Write-Host "  Status: " -NoNewline
    Write-Host "TRANSFER COMPLETE" -ForegroundColor Magenta

    # Build audit row
    $Report += [PSCustomObject]@{
        Name          = $Mover.Name
        Username      = $Mover.Username
        OldDepartment = $Mover.OldDepartment
        NewDepartment = $Mover.NewDepartment
        OldRoles      = $OldRoles -join " | "
        NewRoles      = $NewRoles -join " | "
        NewJobTitle   = $Mover.NewJobTitle
        NewManager    = $Mover.NewManager
        EffectiveDate = $Mover.EffectiveDate
        ProcessedBy   = "IAM-Automation"
        Timestamp     = $Timestamp
        Status        = "Transfer Complete"
    }
}

# Step 4: Save audit report
$ReportPath = ".\Mover-Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  $($Movers.Count) transfers completed!"     -ForegroundColor Green
Write-Host "  Audit report saved to: $ReportPath"        -ForegroundColor Yellow
Write-Host "  All changes logged for compliance!"        -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Magenta