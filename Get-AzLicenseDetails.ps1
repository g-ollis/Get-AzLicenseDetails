Function Get-AzLicenseDetails {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "singleLicense")]
        [string]$friendlyName,
        [Parameter(ParameterSetName = "allLicenses")]
        [bool]$All = $true,
        [Parameter(ParameterSetName = "userPrincipalName")]
        [MailAddress]$userPrincipalName
    )

    begin {

        # all skuid's can be found below:
        # https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference

        $licenseSkus = @(
            [pscustomobject]@{
                name  = "Dynamics 365 Team Members"; 
                sku   = "DYN365_TEAM_MEMBERS"; 
                skuid = "7ac9fe77-66b7-4e5e-9e46-10eed1cff547" 
            },
            [pscustomobject]@{
                name  = "Dynamics 365 Customer Engagement Plan"; 
                sku   = "DYN365_ENTERPRISE_PLAN1"; 
                skuid = "ea126fc5-a19e-42e2-a731-da9d437bffcf" 
            },
            [pscustomobject]@{
                name  = "Dynamics 365 Plan"; 
                sku   = "DYN365_ENTERPRISE_PLAN2"; 
                skuid = "549c4efe-09a2-462b-9393-9b57dfdea76b" 
            }
            [pscustomobject]@{
                name  = "Dynamics 365 Unified Operations Plan"; 
                sku   = "Dynamics_365_for_Operations"; 
                skuid = "ccba3cfe-71ef-423a-bd87-b6df3dce59a9"
            }
            [pscustomobject]@{
                name  = "Dynamics 365 Operations Activity"; 
                sku   = "Dyn365_Operations_Activity"; 
                skuid = "b75074f1-4c54-41bf-970f-c9ac871567f5" 
            }
            [pscustomobject]@{
                name  = "Enterprise Mobility + Security"; 
                sku   = "EMSPREMIUM"; 
                skuid = "b05e124f-c7cc-45a0-a6aa-8cf78c946968" 
            }
            [pscustomobject]@{
                name  = "Office 365 E5"; 
                sku   = "ENTERPRISEPREMIUM"; 
                skuid = "c7df2760-2c81-4ef7-b578-5b5392b571df" 
            }
            [pscustomobject]@{
                name  = "Exchange Online (Plan 1)"
                sku   = "EXCHANGESTANDARD"
                skuid = "4b9405b0-7788-4568-add1-99614e613b69"
            }
            [pscustomobject]@{
                name  = "Project Plan 5"
                sku   = "PROJECTPREMIUM"
                skuid = "09015f9f-377f-4538-bbb5-f75ceb09358a"
            }
            [pscustomobject]@{
                name  = "Project Plan 3"
                sku   = "PROJECTPROFESSIONAL"
                skuid = "53818b1b-4a27-454b-8896-0dba576410e6"
            }
            [pscustomobject]@{
                name  = "Project Online Essentials"
                sku   = "PROJECTESSENTIALS"
                skuid = "776df282-9fc0-4862-99e2-70e561b9909e"
            }
            [pscustomobject]@{
                name  = "Visio Plan 2"
                sku   = "VISIOCLIENT"
                skuid = "c5928f49-12ba-48f7-ada3-0d743a3601d5"
            }
            [pscustomobject]@{
                name  = "Power BI (Free)"
                sku   = "POWER_BI_STANDARD"
                skuid = "a403ebcc-fae0-4ca2-8c8c-7a907fd6c235"
            }
        )
    }

    process {
        if ($PsCmdlet.ParameterSetName -eq "singleLicense") {
            if ($licenseSkus.Name.Contains($friendlyName)) {
                $license = $licenseSkus.Where( { $_.name -eq $friendlyName })
                $assignedUsers = (Get-AzureAdUser -All $true | Where-Object { $_.assignedlicenses.skuid -eq $license.skuid } | 
                    Select-Object userPrincipalName, PhysicalDeliveryOfficeName, Department, userType, accountEnabled, objectID, @{Name = "License"; E = { $license.name } })
                $licenseCount = (Get-AzureADSubscribedSku | Where-Object { $_.skuid -eq $license.skuid })
                $licenseOverview = [PSCustomObject]@{
                    friendlyName      = $license.name
                    sku               = $licensecount.skupartnumber
                    skuid             = $licensecount.skuid
                    allocatedLicenses = $licensecount.consumedunits
                    totalLicenseCount = $licensecount.prepaidunits.enabled
                    usersWithLicense  = $assignedUsers
                }

                return $licenseOverview

            }
            else {
                Write-Error "No license called $($friendlyName), try running Get-AzLicenseDetails -All $true to see all licenses"
            }


        }

        if ($PsCmdlet.ParameterSetName -eq "allLicenses" -and $all -eq $true) {
            $licenseInfo = [System.Collections.ArrayList]@()
            $allUsers = Get-AzureAdUser -All $true
            $enabledLicenses = Get-AzureADSubscribedSku | 
            Select-Object skupartnumber, skuid, consumedunits, @{n = "prepaidunits"; e = { $_.prepaidunits.enabled } }

            foreach ($enabledLicense in $enabledLicenses) {
                foreach ($license in $licenseskuS) {
                    if ($enabledLicense.skuid -eq $license.skuid) {
                        $assignedUsers = ($allUsers | Where-Object { $_.assignedlicenses.skuid -eq $license.skuid } | 
                            Select-Object userPrincipalName, PhysicalDeliveryOfficeName, Department, userType, accountEnabled, objectID, 
                            @{N = "License"; E = { $license.name } }, @{Name = "skuid"; e = { $license.skuid } })
                        $licenseProp = [PSCustomObject][Ordered]@{
                            friendlyName      = $license.Name
                            sku               = $enabledLicense.skupartnumber
                            skuId             = $enabledLicense.skuid
                            allocatedLicenses = $enabledLicense.consumedunits
                            totalLicenseCount = $enabledLicense.prepaidunits
                            usersWithLicense = $assignedUsers
                            objectID          = $assignedUsers.objectid
                        }

                        $licenseInfo.Add($licenseProp) | Out-Null
                    }
                }
            }

            return $licenseInfo 
        }

        if ($PsCmdlet.ParameterSetName -eq "userPrincipalName") {
            $upn = $userPrincipalName.Address
            $azureUser = Get-AzureAdUser -ObjectId $upn
            if ($azureuser.userPrincipalName) {
                    $licenseInfo = [System.Collections.ArrayList]@()
                    foreach ($skuid in $azureuser.assignedlicenses.skuid) {
                        foreach ($license in $licenseSkus) {
                            if ($license.skuid -eq $skuid) {
                                $object = [PSCustomObject]@{
                                    friendlyName = $license.Name
                                    skuid        = $license.skuid
                                }
                                $licenseInfo.Add($object) | Out-Null
                            }
                        }
                    }
                
                    $return = [PSCustomObject]@{
                        userPrincipalName          = $azureUser.userPrincipalName
                        assignedLicenses           = $licenseInfo
                        accountEnabled             = $azureuser.accountEnabled
                        physicalDeliveryOfficeName = $azureuser.PhysicalDeliveryOfficeName
                        Department                 = $azureUser.Department
                        objectID                   = $azureuser.objectid
                    }
    
                    return $return
                  

            }
        }

    }

}