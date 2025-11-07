# Scenario : Action if a PL don't have an Entra ID Tenant fo use CornerStone



## Description

Document explain a workaround for use CornerStone when a PL don't have an Entra ID Tenant.


## Definition

Microsoft Entra ID (formerly Azure Active Directory) is a cloud-based identity and access management service that enables employees, partners, and customers to securely access resources.

A “tenant” represents a dedicated instance of Entra ID associated with an organization. Each tenant contains users, groups, applications, and can be linked to Azure subscriptions or Microsoft 365 services.

## Getting Started

### Dependencies

* Select correct Entra ID solution 
    * Azure Portal ( for used with Azure Resource deployment - VM..)
    * M 365  ( Use with all M365 option : Teams...)
    * Stand Alone Entra ID tenant (only for authentication) First Choose

### Scenario based on Stand-alone Entra Id

* Standalone 
	* Use PowerShell or Graph API to create and configure tenants
	* Suitable for organizations without existing M365 or Azure subscriptions


#### PowerShell Scripts

##### Prerequisite : Install the AzureAD or Microsoft.Graph module

* Install module

Install-Module -Name Microsoft.Graph -Scope CurrentUser

* Connect to Entra ID

Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All"

* Add B2B guest user

Invite-MgUser -InvitedUserEmailAddress "guest@example.com" -InviteRedirectUrl "https://myapps.microsoft.com" -SendInvitationMessage $true

### Key Considerations 

•	Always assign Global Administrator carefully
•	Enable Multi-Factor Authentication
•	For B2B: verify guest user external collaboration settings


#### Next Step

* Execute Guest Onboarding based on Script develop by M365 Iris Team 

## Help

 See if pb with the Team

## Authors

Contributors names and contact info


## Version History


* 0.1
    * Initial Release


