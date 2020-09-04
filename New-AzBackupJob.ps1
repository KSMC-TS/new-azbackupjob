<#
.DESCRIPTION
- Use this script as an Azure Automation Runbook to execute more than 1 VM backup to Azure Recovery Services.
- Based on script found here: https://www.ntweekly.com/2020/03/28/backup-azure-virtual-machines-with-azure-automation/
- Requires at least the following Az submodules:
    - Az.Accounts
    - Az.Automation
    - Az.RecoveryServices
    - Az.Resources
    - Az.Subscription
.PARAMETER SubscriptionId
- Specify the subscription ID if there is more than 1 subscription in the tenant. 
.PARAMETER ResourceGrp
- Specify the resource group the recovery services vault is located in.
.PARAMETER BackupVault
- Specify the backup vault you want to target.
.PARAMETER VmName
- Specify the VM name as it appears in the recovery services vault.
.NOTES
    Version:        0.2
    Last updated:   09/04/2020
    Modified by:    Zachary Choate
    URL:            https://github.com/KSMC-TS/new-azbackupjob
#>
param(
    [string]$subscriptionId,
    [string]$resourceGrp,
    [string]$backupVault,
    [string]$vmName
)

If(-not $resourceGrp) {$resourceGrp = Get-AutomationVariable -Name 'ResourceGrp'}
If(-not $backupVault) {$backupVault = Get-AutomationVariable -Name 'BackupVault'}
If(-not $vmName) {$vmName = Get-AutomationVariable -Name 'VmName'}

Disable-AzContextAutosave –Scope Process
$connection = Get-AutomationConnection -Name AzureRunAsConnection
# Wrap authentication in retry logic for transient network failures
$logonAttempt = 0
while(!($connectionResult) -And ($logonAttempt -le 10))
{
    $LogonAttempt++
    # Logging in to Azure...
    $connectionResult =    Connect-AzAccount `
                               -ServicePrincipal `
                               -Tenant $connection.TenantID `
                               -ApplicationId $connection.ApplicationID `
                               -CertificateThumbprint $connection.CertificateThumbprint

    Start-Sleep -Seconds 1
}

# See if there's multiple subscriptions
$enabledSubscriptions = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}
If($enabledSubscriptions.Count -gt 1) {
    If(-not $subscriptionId) {$subscriptionId = Get-AutomationVariable -Name 'SubscriptionId'}
    If(-not $subscriptionId) {
        Write-Error -Message "There is more than 1 Azure subscription in the tenant, please specify the SubscriptionId as a parameter or store it as a variable. Subscriptions include: $($enabledSubscriptions.Name) with IDs of $($enabledSubscriptions.Id) respectively."
    }
} else {
    $subscriptionId = $enabledSubscriptions.Id
}
Set-AzContext -SubscriptionId $subscriptionId
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $resourceGrp -Name $backupVault
$NamedContainer = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -FriendlyName $vmName -VaultId $vault.ID
$Item = Get-AzRecoveryServicesBackupItem -Container $NamedContainer -WorkloadType AzureVM -VaultId $vault.ID
$Job = Backup-AzRecoveryServicesBackupItem -Item $Item -VaultId $vault.ID