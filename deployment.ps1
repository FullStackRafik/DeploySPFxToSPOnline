
##############################################################
#  Script     : Deployement of SPFx solutions package to SharePoint online
#  Author     : Rafik Elaakil
#  Date       : 09/20/2018
#  Last Edited: 09/20/2018
##############################################################
$url='https://rafikPortal.sharepoint.com/';#the URL fo the Sharepoint online portal
$assestsLib ='SiteAssets/';# the document library for Assets
#######
# End #
#######
Write-Host ***************************************** -ForegroundColor Yellow
Write-Host *Generating the bundle files* -ForegroundColor Yellow
Write-Host ***************************************** -ForegroundColor Yellow

gulp bundle --ship

Write-Host ***************************************** -ForegroundColor Yellow
Write-Host *Generating the solution package sppkg* -ForegroundColor Yellow
Write-Host ***************************************** -ForegroundColor Yellow

gulp package-solution --ship
Import-Module -Name Microsoft.Online.SharePoint.PowerShell
Write-Host ***************************************** -ForegroundColor Yellow
Write-Host * Uploading the package on the AppCatalog * -ForegroundColor Yellow
Write-Host ***************************************** -ForegroundColor Yellow
$currentLocation = Get-Location | Select-Object -ExpandProperty Path
Write-Host ($currentLocation + "\config\package-solution.json")
$packageConfig = Get-Content -Raw -Path ($currentLocation + "\config\package-solution.json") | ConvertFrom-Json
$packagePath = Join-Path ($currentLocation + "\sharepoint\") $packageConfig.paths.zippedPackage -Resolve #Join-Path "sharepoint/" $packageConfig.paths.zippedPackage -Resolve
Write-Host "packagePath: $packagePath"
$skipFeatureDeployment = $packageConfig.solution.skipFeatureDeployment

# # Connect-PnPOnline $catalogSite -Credentials (Get-Credential)
# # Connect-PnPOnline –Url $url –Credentials (Get-Credential)
Connect-PnPOnline -Url  $url
# Adding and publishing the App package
If ($skipFeatureDeployment -ne $true) {
  Write-Host 'skipFeatureDeployment = false'
  Add-PnPApp -Path $packagePath -Publish -Overwrite
  Write-Host *************************************************** -ForegroundColor Yellow
  Write-Host * The SPFx solution has been succesfully uploaded and published to the AppCatalog * -ForegroundColor Yellow
  Write-Host *************************************************** -ForegroundColor Yellow
}
Else {
    Write-Host 'skipFeatureDeployment = true'
  Add-PnPApp -Path $packagePath -SkipFeatureDeployment -Publish -Overwrite
  Write-Host *************************************************** -ForegroundColor Yellow
  Write-Host * The SPFx solution has been succesfully uploaded and published to the AppCatalog * -ForegroundColor Yellow
  Write-Host *************************************************** -ForegroundColor Yellow
}

Write-Host ************************************************************************************** -ForegroundColor Yellow
Write-Host * Reading the cdnBasePath from write-manifests.json and collectiong the bundle files * -ForegroundColor Yellow
Write-Host ************************************************************************************** -ForegroundColor Yellow
$cdnConfig = Get-Content -Raw -Path .\config\copy-assets.json | ConvertFrom-Json
$bundlePath = Convert-Path $cdnConfig.deployCdnPath
$files = Get-ChildItem $bundlePath.
Write-Host **************************************** -ForegroundColor Yellow
Write-Host Uploading the bundle on Sharepoint online Assts library * -ForegroundColor Yellow
Write-Host **************************************** -ForegroundColor Yellow
foreach ($file in $files) {

    $fullPath = $file.DirectoryName + '\' + $file.Name
    Write-Host  $fullPath ;
    Add-PnPFile -Path $fullPath -Folder $assestsLib
}