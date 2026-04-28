# ============================================
# IAM Lab - Master JML Engine v1.0
# Reads HR feed and automatically processes
# Joiners, Movers and Leavers in one run
# ============================================

# Step 1: Load HR feed
$HRFeed    = Import-Csv -Path ".\HR-Feed.csv"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$Report    = @()

# Step 2: Role definitions
$DepartmentRoles = @{
    "Finance" = @("Finance-Read", "Finance-Write", "Expenses-Portal")
    "IT"      = @("IT-Admin", "Azure-Portal", "ServiceDesk")
    "HR"      = @("HR-System", "Recruitment-Portal")
}

# Step 3: Count each action type
$Joiners = $HRFeed | Where-Object { $_.Action -eq "Joiner" }
$Movers  = $HRFeed | Where-Object { $_.Action -eq "Mover" }
$Leavers = $HRFeed | Where-Object { $_.Action -eq "Leaver" }

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  IAM MASTER JML ENGINE v1.0"                -ForegroundColor Cyan
Write-Host "  Generated : $Timestamp"                    -ForegroundColor Cyan
Write-Host "  Total     : $($HRFeed.Count) records"      -ForegroundColor Cyan
Write-Host "  Joiners   : $($Joiners.Count)"             -ForegroundColor Green
Write-Host "  Movers    : $($Movers.Count)"              -ForegroundColor Magenta
Write-Host "  Leavers   : $($Leavers.Count)"             -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Cyan

# ============================================
# PROCESS JOINERS
# ============================================
if ($Joiners.Count -gt 0) {
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Green
    Write-Host "  PROCESSING JOINERS"                         -ForegroundColor Green
    Write-Host "--------------------------------------------" -ForegroundColor Green

    foreach ($Person in $Joiners) {
        $Username = ($Person.FirstName[0] + $Person.LastName).ToLower()
        $Email    = "$Username@algorithmia.com"
        $Roles    = $DepartmentRoles[$Person.Department]

        Write-Host ""
        Write-Host "  + Joiner: $($Person.FirstName) $($Person.LastName)" -ForegroundColor Green
        Write-Host "    Username : $Username"
        Write-Host "    Email    : $Email"
        Write-Host "    Roles    : $($Roles -join ', ')" -ForegroundColor Green

        Start-Sleep -Milliseconds 400

        Write-Host "    Status   : " -NoNewline
        Write-Host "PROVISIONED" -ForegroundColor Green

        $Report += [PSCustomObject]@{
            Name      = "$($Person.FirstName) $($Person.LastName)"
            Username  = $Username
            Action    = "Joiner"
            OldRoles  = ""
            NewRoles  = $Roles -join " | "
            Status    = "Provisioned"
            Timestamp = $Timestamp
        }
    }
}

# ============================================
# PROCESS MOVERS
# ============================================
if ($Movers.Count -gt 0) {
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Magenta
    Write-Host "  PROCESSING MOVERS"                          -ForegroundColor Magenta
    Write-Host "--------------------------------------------" -ForegroundColor Magenta

    foreach ($Person in $Movers) {
        $Username = ($Person.FirstName[0] + $Person.LastName).ToLower()
        $OldRoles = $DepartmentRoles[$Person.Department]
        $NewRoles = $DepartmentRoles[$Person.NewDepartment]

        Write-Host ""
        Write-Host "  > Mover: $($Person.FirstName) $($Person.LastName)" -ForegroundColor Magenta
        Write-Host "    Username : $Username"
        Write-Host "    Transfer : $($Person.Department) --> $($Person.NewDepartment)" -ForegroundColor Cyan
        Write-Host "    Removing : $($OldRoles -join ', ')" -ForegroundColor Red
        Write-Host "    Adding   : $($NewRoles -join ', ')" -ForegroundColor Green

        Start-Sleep -Milliseconds 400

        Write-Host "    Status   : " -NoNewline
        Write-Host "TRANSFER COMPLETE" -ForegroundColor Magenta

        $Report += [PSCustomObject]@{
            Name      = "$($Person.FirstName) $($Person.LastName)"
            Username  = $Username
            Action    = "Mover"
            OldRoles  = $OldRoles -join " | "
            NewRoles  = $NewRoles -join " | "
            Status    = "Transfer Complete"
            Timestamp = $Timestamp
        }
    }
}

# ============================================
# PROCESS LEAVERS
# ============================================
if ($Leavers.Count -gt 0) {
    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Red
    Write-Host "  PROCESSING LEAVERS"                         -ForegroundColor Red
    Write-Host "--------------------------------------------" -ForegroundColor Red

    foreach ($Person in $Leavers) {
        $Username     = ($Person.FirstName[0] + $Person.LastName).ToLower()
        $RolesRevoked = $DepartmentRoles[$Person.Department]

        Write-Host ""
        Write-Host "  - Leaver: $($Person.FirstName) $($Person.LastName)" -ForegroundColor Red
        Write-Host "    Username : $Username"
        Write-Host "    Revoking : $($RolesRevoked -join ', ')" -ForegroundColor Red

        Start-Sleep -Milliseconds 400

        Write-Host "    Status   : " -NoNewline
        Write-Host "DEPROVISIONED" -ForegroundColor Red

        $Report += [PSCustomObject]@{
            Name      = "$($Person.FirstName) $($Person.LastName)"
            Username  = $Username
            Action    = "Leaver"
            OldRoles  = $RolesRevoked -join " | "
            NewRoles  = ""
            Status    = "Deprovisioned"
            Timestamp = $Timestamp
        }
    }
}

# ============================================
# SAVE MASTER AUDIT REPORT
# ============================================
$ReportPath = ".\JML-Master-Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  JML ENGINE COMPLETE!"                      -ForegroundColor Green
Write-Host "  Joiners processed  : $($Joiners.Count)"   -ForegroundColor Green
Write-Host "  Movers processed   : $($Movers.Count)"    -ForegroundColor Magenta
Write-Host "  Leavers processed  : $($Leavers.Count)"   -ForegroundColor Red
Write-Host "  Master report saved: $ReportPath"         -ForegroundColor Yellow
Write-Host "  All actions logged for compliance!"        -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan