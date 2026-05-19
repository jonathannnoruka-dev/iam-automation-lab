# ============================================
# IAM Lab - Bulk New Joiner Automation v4.0
# Reads from HR CSV feed, provisions users
# into real Entra ID AND assigns them to
# the correct department security group
# ============================================

# Step 1: Load HR feed and filter Joiners only
$HRFeed  = Import-Csv -Path ".\data\HR-Feed.csv"
$Joiners = $HRFeed | Where-Object { $_.Action -eq "Joiner" }
$Report  = @()
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

# Step 2: Department to Group ID mapping
$GroupMap = @{
    "Finance" = "c1d8f270-d7b6-458f-863a-89fb47751647"
    "IT"      = "135f1be2-b2c5-4574-a24e-48487ccbd3eb"
    "HR"      = "e1bb8110-5296-4dd5-9edd-676338ab45a8"
}

# Step 3: Role definitions per department
$DepartmentRoles = @{
    "Finance" = @("Finance-Read", "Finance-Write", "Expenses-Portal")
    "IT"      = @("IT-Admin", "Azure-Portal", "ServiceDesk")
    "HR"      = @("HR-System", "Recruitment-Portal")
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  IAM BULK PROVISIONING REPORT" -ForegroundColor Cyan
Write-Host "  Generated: $Timestamp" -ForegroundColor Cyan
Write-Host "  Total New Joiners: $($Joiners.Count)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Step 4: Loop through Joiners only
foreach ($Employee in $Joiners) {

    $Username = ($Employee.FirstName[0] + $Employee.LastName).ToLower()
    $UPN      = "$Username@jonathannnorukaoutlook.onmicrosoft.com"
    $Roles    = $DepartmentRoles[$Employee.Department]
    $GroupId  = $GroupMap[$Employee.Department]

    Write-Host ""
    Write-Host "--------------------------------------------" -ForegroundColor Gray
    Write-Host "Name       : $($Employee.FirstName) $($Employee.LastName)"
    Write-Host "UPN        : $UPN"
    Write-Host "Department : $($Employee.Department)"
    Write-Host "Job Title  : $($Employee.JobTitle)"
    Write-Host "Start Date : $($Employee.StartDate)"
    Write-Host "Manager    : $($Employee.Manager)"
    Write-Host "Roles      : $($Roles -join ', ')" -ForegroundColor Green

    # Step 5: Create user in Entra ID
    try {
        $PasswordProfile = @{
            Password                      = "TempPass@2024!"
            ForceChangePasswordNextSignIn = $true
        }

        $NewUser = New-MgUser `
            -DisplayName "$($Employee.FirstName) $($Employee.LastName)" `
            -UserPrincipalName $UPN `
            -MailNickname $Username `
            -AccountEnabled `
            -PasswordProfile $PasswordProfile `
            -JobTitle $Employee.JobTitle `
            -Department $Employee.Department

        Write-Host "Status     : PROVISIONED IN ENTRA ID" -ForegroundColor Green

        # Step 6: Add user to correct department group
        if ($GroupId) {
            New-MgGroupMember -GroupId $GroupId -DirectoryObjectId $NewUser.Id
            Write-Host "Group      : Added to $($Employee.Department) group" -ForegroundColor Cyan
        }

        $Status = "Provisioned + Group Assigned"

    } catch {
        Write-Host "Status     : FAILED - $($_.Exception.Message)" -ForegroundColor Red
        $Status = "Failed"
    }

    # Build report row
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

# Step 7: Save report
$ReportPath = ".\reports\Provisioning-Report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Processing complete!" -ForegroundColor Green
Write-Host "  Report saved to: $ReportPath" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
