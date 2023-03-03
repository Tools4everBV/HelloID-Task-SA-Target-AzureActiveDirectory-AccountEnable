# HelloID-Task-SA-Target-AzureActiveDirectory-AccountEnable
###########################################################
# Form mapping
$formObject = @{
    id                = $form.id
    userPrincipalName = $form.UserPrincipalName
    accountEnabled    = $true
}

try {
    Write-Information "Executing AzureActiveDirectory action: [EnableAccount] for: [$($formObject.UserPrincipalName)]"
    Write-Information "Retrieving Microsoft Graph AccessToken for tenant: [$AADTenantID]"
    $splatTokenParams = @{
        Uri         = "https://login.microsoftonline.com/$AADTenantID/oauth2/token"
        ContentType = 'application/x-www-form-urlencoded'
        Method      = 'POST'
        Verbose     = $false
        Body = @{
            grant_type    = 'client_credentials'
            client_id     = $AADAppID
            client_secret = $AADAppSecret
            resource      = 'https://graph.microsoft.com'
        }
    }
    $accessToken = (Invoke-RestMethod @splatTokenParams).access_token
    $splatCreateUserParams = @{
        Uri     = "https://graph.microsoft.com/v1.0/users/$($formObject.userPrincipalName)"
        Method  = 'PATCH'
        Body    = $formObject | ConvertTo-Json -Depth 10
        Verbose = $false
        Headers = @{
            Authorization  = "Bearer $accessToken"
            Accept         = 'application/json'
            'Content-Type' = 'application/json'
        }
    }
    $null = Invoke-RestMethod @splatCreateUserParams
    $auditLog = @{
        Action            = 'EnableAccount'
        System            = 'AzureActiveDirectory'
        TargetIdentifier  = $formObject.id
        TargetDisplayName = $formObject.userPrincipalName
        Message           = "AzureActiveDirectory action: [EnableAccount] for: [$($formObject.UserPrincipalName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags 'Audit' -MessageData $auditLog
    Write-Information "AzureActiveDirectory action: [EnableAccount] for: [$($formObject.UserPrincipalName)] executed successfully"
} catch {
    $ex = $_
    $auditLog = @{
        Action            = 'EnableAccount'
        System            = 'AzureActiveDirectory'
        TargetIdentifier  = ''
        TargetDisplayName = $formObject.userPrincipalName
        Message           = "Could not execute AzureActiveDirectory action: [EnableAccount] for: [$($formObject.UserPrincipalName)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq 'Microsoft.PowerShell.Commands.HttpResponseException')){
        $auditLog.Message = "Could not execute AzureActiveDirectory action: [EnableAccount] for: [$($formObject.UserPrincipalName)]"
        Write-Error "Could not execute AzureActiveDirectory action: [EnableAccount] for: [$($formObject.UserPrincipalName)], error: $($ex.ErrorDetails)"
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute AzureActiveDirectory action: [EnableAccount] for: [$($formObject.UserPrincipalName)], error: $($ex.Exception.Message)"
}
###########################################################
