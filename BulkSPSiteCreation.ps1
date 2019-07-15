<#
.SYNOPSIS
   Use this script to create several Teams and Communication Sites in SharePoint Online

.DESCRIPTION
   This script will take input from a CSV file and create each site based on a set of columns:
   url | title | alias | type | description | quota | hub(yes or no) | extshare(yes or no) | hubUrl | owners
   Make sure to change the -Credential, $path, and <tenant> areas

.PARAMETER 
   NONE
   
.EXAMPLE
   NONE

.AUTHOR
   Gabe Fischer

.CHANGELOG
   7/9/19 (GF) - Initial script creation
   7/9/19 (JAG) - Added header, inline comments, and modified cred and connect line slightly
   7/11/19 (GF) - Inserted set-pnpsite lines and connect line for sites
#>

# Please change the path to the csv input file
$path = 'c:\Scripts\siteInput.csv'

# Please change the username credentials
$cred = Get-Credential -Credential <UserName@domain.com>

# Importing the CSV file
$sites = import-csv $path

#Please change the <tenant> url
Connect-PnPOnline https://<tenant>-admin.sharepoint.com -Credentials $cred


foreach ($site in $sites){

    if ($site.hub -eq 'yes'){

    New-PnPSite -Type $site.type -Url $site.url -Title $site.title -Description $site.description

    Register-PnPHubSite -Site $site.url
    }

    else {

    New-PnPSite -Type $site.type -Alias $site.alias -Title $site.title -Description $site.description -Owners $site.owners

    Add-PnPHubSiteAssociation -Site $site.url -HubSite $site.hubUrl
    }
}


foreach ($site in $sites){

    if ($site.type -eq 'CommunicationSite'){

	Connect-PnPOnline $site.url -Credentials $cred
	
	Set-PnPSite -Sharing $site.share -Owners $site.owners -StorageMaximumLevel $site.quota -StorageWarningLevel $site.warn -DisableSharingForNonOwners
    }

    else {

	Connect-PnPOnline $site.url -Credentials $cred
	
	Set-PnPSite -Sharing $site.share -StorageMaximumLevel $site.quota -StorageWarningLevel $site.warn -DisableSharingForNonOwners
    }
}