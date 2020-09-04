# New-AzBackupJob

## DESCRIPTION
- Use this script as an Azure Automation Runbook to execute more than 1 VM backup to Azure Recovery Services.
- Based on script found here: https://www.ntweekly.com/2020/03/28/backup-azure-virtual-machines-with-azure-automation/
- Requires at least the following Az submodules:
    - Az.Accounts
    - Az.Automation
    - Az.RecoveryServices
    - Az.Resources
    - Az.Subscription
### PARAMETER SubscriptionId
- Specify the subscription ID if there is more than 1 subscription in the tenant. 
### PARAMETER ResourceGrp
- Specify the resource group the recovery services vault is located in.
### PARAMETER BackupVault
- Specify the backup vault you want to target.
### PARAMETER VmName
- Specify the VM name as it appears in the recovery services vault.
### NOTES
    Version:        0.2
    Last updated:   09/04/2020
    Modified by:    Zachary Choate
    URL:            https://github.com/KSMC-TS/new-azbackupjob