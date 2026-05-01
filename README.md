# iam-automation-lab
PowerShell IAM automation scripts for JML lifecycle management - Joiner, Mover, Leaver
# IAM Automation Lab

PowerShell IAM automation scripts for JML lifecycle management - Joiner, Mover, Leaver

## About
A hands-on IAM engineering lab built to demonstrate real identity lifecycle automation using PowerShell and Microsoft Graph API.

## Session 1 & 2 — JML Automation Framework ✅
- Built Joiner, Mover, Leaver automation scripts
- HR CSV feed integration for bulk provisioning
- Master JML engine (Invoke-JML.ps1) to process all lifecycle events
- Automated audit reports generated for every action

## Session 3 — Connecting to Real Entra ID ✅
- Connected PowerShell to real Microsoft Entra ID tenant via Microsoft Graph API
- Authenticated using Connect-MgGraph with delegated permissions
- Queried live users using Get-MgUser
- Created real cloud user (Alice Johnson) using New-MgUser
- Verified user existence in Azure portal

## Tech Stack
- PowerShell 7
- Microsoft Graph API
- Microsoft Entra ID (Azure AD)

## Author
Jonathan Nnoruka | IAM Engineer in Training | SC-300 Candidate
