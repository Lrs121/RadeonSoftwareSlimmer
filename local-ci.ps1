﻿# Local version of CI to run before committing changes

# Delete old local-ci folder, if it exists
if (Test-Path -Path .\local-ci)
{
	Remove-Item -Path .\local-ci -Recurse -Force
}

if (Test-Path -Path .\test-results)
{
	Remove-Item -Path .\test-results -Recurse -Force
}

# Install Report Generator
dotnet tool install dotnet-reportgenerator-globaltool --tool-path .\test-results

# Clean
dotnet clean --configuration Debug --framework net6.0-windows
dotnet clean --configuration Debug --framework net48
dotnet clean --configuration Release --framework net6.0-windows
dotnet clean --configuration Release --framework net48

# Test
# dotnet test .\test\RadeonSoftwareSlimmer.Test\RadeonSoftwareSlimmer.Test.csproj
dotnet test .\test\RadeonSoftwareSlimmer.Test\RadeonSoftwareSlimmer.Test.csproj --framework net48
dotnet test .\test\RadeonSoftwareSlimmer.Test\RadeonSoftwareSlimmer.Test.csproj --framework net6.0-windows --settings coverage.runsettings

# Run Report Generator to create coverage reports
.\test-results\reportgenerator "-reports:test-results\*\coverage.cobertura.xml" "-targetdir:test-results\coveragereport" "-reporttypes:Html;TextSummary;Badges"

# Output coverage results to console
Get-Content .\test-results\coveragereport\Summary.txt

# Build and create artifacts
dotnet publish --configuration Release --framework net6.0-windows --self-contained false --force --output .\local-ci\net60 .\src\RadeonSoftwareSlimmer\RadeonSoftwareSlimmer.csproj -p:VersionSuffix=local-ci
dotnet publish --configuration Release  --framework net48 --force --output .\local-ci\net48 .\src\RadeonSoftwareSlimmer\RadeonSoftwareSlimmer.csproj -p:VersionSuffix=local-ci

# Get the version from the published executable
$version = (Get-Item .\local-ci\net60\RadeonSoftwareSlimmer.exe).VersionInfo.ProductVersion

# Archive the artifacts
Compress-Archive -Path .\local-ci\net60\* -DestinationPath ".\local-ci\RadeonSoftwareSlimmer_${version}_net60.zip"
Compress-Archive -Path .\local-ci\net48\* -DestinationPath ".\local-ci\RadeonSoftwareSlimmer_${version}_net48.zip"

# Output the version
Write-Host "Published: $version"

# Wait for keypress so the output can be read
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');