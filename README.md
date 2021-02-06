# Get-AzLicenseDetails

- PowerShell function for gathering license information for single users or all users, provides license names in friendly format without using a skuid.
- Good way to find disabled users that may still have licenses or guest users within your Azure Active Directory tenant.

# Get-AzLicenseDetails -userPrincipalName 

userPrincipalName parameter will provide license information for one user. 

````
Get-AzLicenseDetails -userPrincipalName "Joe.Bloggs@microsoft.com"

userPrincipalName          : Joe.Bloggs@microsoft.com
assignedLicenses           : {@{friendlyName=Dynamics 365 Operations Activity; skuid=b75074f1-4c54-41bf-970f-c9ac871567f5}, @{friendlyName=Enterprise Mobility + Security;
                             skuid=b05e124f-c7cc-45a0-a6aa-8cf78c946968}, @{friendlyName=POWER BI (FREE); skuid=a403ebcc-fae0-4ca2-8c8c-7a907fd6c235}
accountEnabled             : True
physicalDeliveryOfficeName : Test
Department                 : Test
objectID                   : 04114d9c-9145-4b6f-8d47-c7a8d2d05930

````

# Get-AzLicenseDetails -all $true

Provides you with all license information.

Objects returned:

- friendlyName
- sku
- skuID
- usersWithLicense
- allocatedLicenses 
- totalLicenseCount


````
Get-AzLicenseDetails -All $true

friendlyName                   sku               skuId                                allocatedLicenses totalLicenseCount usersWithLicenses
------------                   ---               -----                                ----------------- ----------------- -----------------
Visio Plan 2                   VISIOCLIENT       c5928f49-12ba-48f7-ada3-0d743a3601d5              2              1 {@{UserPrincipalName=Test@microsoft.com;}
Enterprise Mobility + Security EMSPREMIUM        b05e124f-c7cc-45a0-a6aa-8cf78c946968              2              5 {@{UserPrincipalName=Test1@microsoft.com;}
Office 365 E5                  ENTERPRISEPREMIUM c7df2760-2c81-4ef7-b578-5b5392b571df              10             23 {@{UserPrincipalName=Test2@microsoft.com;}

````
- Getting list of users with License

````
$allLicenses = Get-AzLicenseDetails -All $true
$allLicenses.UsersWithLicense | FT

UserPrincipalName              PhysicalDeliveryOfficeName          Department             UserType AccountEnabled ObjectId                             License      skuid
-----------------              --------------------------          ----------             -------- -------------- --------                             -------      -----
Graham@microsoft.com        Test Office                         Test Department        Member             True d584575f-0e1f-4e65-bda7-610212ade418 Visio Plan 2 c5928f49-124a-48f7-ada3-0d743a2601d5
Nathan@microsoft.com        Test Office                         Test Department        Member             True 04114d9c-9145-4b6f-8d47-c7ac35d05930 Visio Plan 2 c5928f49-12ba-48f7-ada3-0d743a3601d5
George@microsoft.com.com    Test Office                         Test Department        Member             True 36692492-1a7e-4995-8bda-53df55b13506 Visio Plan 2 c5928f49-12ba-48f7-ada3-0d743a3601d5
Simon@microsoft.com         Test Office                         Test Department        Member             True 798b208a-141e-42ba-b7df-2ca72b8aed60 Visio Plan 2 c5928f49-12ba-48f7-ada3-0d743a3601d5
Jason@microsoft.com         Test Office                         Test Department        Member             True 5f400c5d-7a5f-49d2-b6cb-28ec84a4bfad Visio Plan 2 c5928f49-12ba-48f7-ada3-0d743a3601d5

````

# Get-AzLicenseDetails -friendlyName

Specify a friendly license name like "Office 365 E5" and details about that license will be returned

Objects returned:

- friendlyName
- sku
- skuID
- usersWithLicense
- allocatedLicenses 
- totalLicenseCount

````
Get-AzLicenseDetails -friendlyName "Office 365 E5"

friendlyName      : Office 365 E5
sku               : ENTERPRISEPREMIUM
skuid             : c7df2760-2c81-4ef7-b578-5b5392b571df
allocatedLicenses : 23
totalLicenseCount : 50
usersWithLicense  : {@{UserPrincipalName=Joe.Bloggs@Microsoft.com;}

````

