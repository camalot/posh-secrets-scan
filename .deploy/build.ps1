#!/usr/bin/env pwsh

param(
	[Parameter(Mandatory = $true)]
	[String]
	$ProjectName
)

"Running $ProjectName Build..." | Write-Host;
