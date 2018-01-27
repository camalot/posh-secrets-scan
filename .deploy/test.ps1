#!/usr/bin/env pwsh

if ($PSCommandPath -eq $null) {
	$CommandRootPath = (Split-Path -Parent $MyInvocation.MyCommand.Path);
}
else {
	$CommandRootPath = (Split-Path -Parent $PSCommandPath);
}

$PathSeparator = [IO.Path]::DirectorySeparatorChar;

$isCI = $ENV:CI -cmatch '[Tt]rue';

if (-not (Get-Module -ListAvailable -Name "pester")) {
	Install-Module -Name "pester" -Scope CurrentUser -Force -AcceptLicense;
}

Import-Module "pester" -Verbose -Force;
$cdir = $PWD;


$testsDir = (Join-Path -Path "$CommandRootPath" -ChildPath "..${PathSeparator}tests" -Resolve);
$scriptDir = (Join-Path -Path "$CommandRootPath" -ChildPath "..${PathSeparator}" -Resolve);

$outDir = (Join-Path -Path "$CommandRootPath" -ChildPath "..${PathSeparator}bin${PathSeparator}");

if ( !(Test-Path -Path $outDir) ) {
	New-Item -ItemType "directory" -Path $outDir | Out-Null;
}

Set-Location -Path $testsDir | Out-Null;

$psModuleFiles = "$scriptDir${PathSeparator}*.ps*1";

$tests = (Get-ChildItem -Path "$testsDir${PathSeparator}*.Tests.ps1" | % { $_.FullName });
$coverageFiles = (Get-ChildItem -Path "$psModuleFiles") | where { $_.Name -inotmatch "${PathSeparator}.tests${PathSeparator}.ps1$" `
        -and $_.Name -inotmatch "${PathSeparator}.psd1$" } | % { $_.FullName };
$resultsOutput = (Join-Path -Path $outDir -ChildPath "secrets-scan.results.xml");

Invoke-Pester -Script $tests -OutputFormat NUnitXml -OutputFile $resultsOutput -CodeCoverage $coverageFiles -Strict -EnableExit:$isCI;

Set-Location -Path $cdir | Out-Null;
