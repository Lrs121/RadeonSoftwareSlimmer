﻿# Builds the software and creates release artifacts
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$version = $Env:GitVersion_SemVer
Write-Output "Version: ${version}"

Write-Output '***** Publishing solution...'
dotnet publish --configuration Release --framework net8.0-windows --force --output .\publish\net80 .\src\RadeonSoftwareSlimmer\RadeonSoftwareSlimmer.csproj -p:Version=$version
dotnet publish --configuration Release --framework net6.0-windows --force --output .\publish\net60 .\src\RadeonSoftwareSlimmer\RadeonSoftwareSlimmer.csproj -p:Version=$version
dotnet publish --configuration Release  --framework net48 --force --output .\publish\net48 .\src\RadeonSoftwareSlimmer\RadeonSoftwareSlimmer.csproj -p:Version=$version

$productVersion = (Get-Item -Path .\publish\net80\RadeonSoftwareSlimmer.exe).VersionInfo.ProductVersion

Write-Output '***** Archiving artifacts...'
Compress-Archive -Path '.\publish\net80\*' -DestinationPath ".\publish\RadeonSoftwareSlimmer_${version}_net80.zip"
Compress-Archive -Path '.\publish\net60\*' -DestinationPath ".\publish\RadeonSoftwareSlimmer_${version}_net60.zip"
Compress-Archive -Path '.\publish\net48\*' -DestinationPath ".\publish\RadeonSoftwareSlimmer_${version}_net48.zip"

Write-Output "Published: ${productVersion}"