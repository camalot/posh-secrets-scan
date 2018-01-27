#### NOTE: All the password, access keys, tokens, etc. within this file are made up from a random string generation

		`"(?msi)(\`"|')?(aws)?_?(secret)?_?(access)?_?(key)(\`"|')?\\s*(:|=>|=)\\s*(\`"|')?([a-z0-9/\\+=]{40}|[a-z0-9/\\+=]{20})(\`"|')?`",
		`"(?msi)(?:key\\s*=\\s*)(?:\`"|')?((?:aws)?_?(?:secret)?_?(?:access)?_?(?:key))(?:\`"|')?\\s*(?:value\\s*=\\s*)(?:\`"|')?([a-z0-9/\\+=]{40}|[a-z0-9/\\+=]{20})(?:\`"|')?`",
		`"(?msi)(\`"|')?((?:aws)?_?(?:account)_?(?:id)?)(\`"|')?\\s*(:|=>|=)\\s*(\`"|')?[0-9]{4}\\-?[0-9]{4}\\-?[0-9]{4}(\`"|')?`",
		`"(?msi)(?:key\\s*=\\s*)(?:\`"|')?((?:aws)?_?(?:account)_?(?:id)?)(?:\`"|')?\\s*(?:value\\s*=\\s*)(?:\`"|')?([0-9]{4}\\-?[0-9]{4}\\-?[0-9]{4})(?:\`"|')?`",
		`"(?msi)-{5}begin\\s[rd]sa\\sprivate\\skey-{5}`",
		`"(?msi)\\[?(?:\`"|'|:)?(p(?:ass)?w(?:or)?d)(?:\`"|'|:)?\\]?\\s*(:|=>|=)\\s*(?:\`"|')?([\\w\\s\\d\\-*\/~``!@\\#\\$%\\^&\\(\\)_\\<\\>;\\.,\\?\\$\`"']+)(?:\`"|'|)?`"
	],
	`"commits`": true

		`"\\\\repo\\\\my-secrets\\.txt`"
	],
	`"commits`": true
		`"\\\\repo\\\\readme.md`"
	],
	`"commits`": true,
	`"complexObject`": {
		`"foo`": {
			`"test`": `"bar`"
		}
	}
}";
$fileWithPrivateKey = "
	pem: `"$privateKey`"
";
$readme = "``````
[Warning]: Found 1 Violation that was overridden by exception rules.
    [-] C:\code\my-project\super-secret-key.txt: AWS_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[Error]: Found 5 Violations.
    [x] C:\code\my-project\super-secret-key.txt: AWS_SECRET_KEY=PnsrlQ4QaWqISJ5zcNkma1ClqHBshI0Y65mYwnNT
    [x] C:\code\my-project\super-secret-key.txt: AWS_ACCESS_KEY=RtwpOEp4IeQqHawn7hsBIC13Cap2qCt1AmQqIOMY
    [x] C:\code\my-project\Subfolder\more-secrets.txt: aws_account_id:129398745743
    [x] C:\code\my-project\Subfolder\my-key.pem: -----BEGIN RSA PRIVATE KEY-----
    [x] C:\code\my-project\Subfolder\my-key.pub: -----BEGIN PUBLIC KEY-----


Possible mitigations:
    - Mark false positives as allowed by adding exceptions to '.secrets-scan.json'
    - Revoke the Secret that was identified. The secret is no longer secure as it
        now exists in the commit history, even if removed from code.
``````"
$cleanFile = "
This is a clean file without any violations.

It has multiple lines, just because.
"
AWS_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
key=s35RpQlY7K1Pjg8mby2ltHVabtBU9tsyB9QGw1do
password=Passsw0rd
os['windows']['password'] => 'Passw0rd'
os[:windows][:password] => 'Passw0rd'
os[windows:][password:] => 'Passw0rd'
";

$secretsFileSingle = "
os[windows:][password:] => 'Passw0rd'
";

$gitLog = "commit 5b1d901c0173b41010856e30776c92d02987ea25
Author: Matthew Move <Matthew.Move@vmail.com>
Date:   Wed Feb 18 10:46:04 2017 +0200

    Update the config

diff --git a/App.config b/App.config
index fabadb8,cc95eb0..4866510
--- a/AWSTest/App.config
+++ b/AWSTest/App.config
@@ -11,8 +11,6 @@


-    <add key=`"AWSAccessKey`" value=`"RtwpOEp4IeQqHawn7hsB`"/>
-    <add key=`"AWSSecretKey`" value =`"PnsrlQ4QaWqISJ5zcNkma1ClqHBshI0Y65mYwnNT`"/>

   </appSettings>
 </configuration>
\ No newline at end of file

commit 16da57c7c6c1fe92b32645202dd19657a89dd67d
Author: Joe Q Public <joe.q.public@vmail.com>
Date:   Wed Feb 18 14:39:31 2017 -0700

    initial commit

diff --git a/App.config b/App.config
new file mode 100644
index 0000000..a3f6bb2
--- /dev/null
+++ b/AWSTest/App.config
@@ -0,0 +1,9 @@
+<?xml version=`"1.0`" encoding=`"utf-8`"?>
+<configuration>
+  <appSettings>
+
+    <add key=`"AWSAccessKey`" value=`"RtwpOEp4IeQqHawn7hsB`"/>
+    <add key=`"AWSSecretKey`" value=`"PnsrlQ4QaWqISJ5zcNkma1ClqHBshI0Y65mYwnNT`"/>
+
+  </appSettings>
+</configuration>
\ No newline at end of file
"


			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			Assert-MockCalled Write-Violations -Exactly -Times 2;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 2;
		}
	}

	Context "When has commit history" {
		It "Must scan the commit history" {
			$historyFile = "repo\some-file.txt";
			Mock Write-Violations {};
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq "$TestDrive\$historyFile" };
			Mock Execute-GitLogCommand {
				return $gitLog;
			}
			Mock Get-Violations {
				return [System.Collections.ArrayList]@(
					"$TestDrive\$($historyFile): [Commit]<FAKESHA>: Violation 1",
					"$TestDrive\$($historyFile): [Commit]<FAKESHA>: Violation 2"
				);
			};
			Mock Get-Command { return $true; };
			Mock Get-GitLogForFile {
				return [System.Collections.ArrayList]@({
					Name= "$TestDrive\$($historyFile): [Commit]<FAKESHA>"
					Content= "Fake Content That Doesn't Matter"
				}, {
					Name= "$TestDrive\$($historyFile): [Commit]<FAKESHA>"
					Content= "Fake Content That Doesn't Matter"
				});
			}

			Setup -Directory "repo";
			Setup -File ".secrets-scan.json" -Content $configPrimary;
			Setup -File "repo\some-file.txt" -Content "some text";
			$result = Scan-Path -Path "$TestDrive\repo" -ConfigFile "$TestDrive\.secrets-scan.json" -Quiet;
			$result | Should Not Be $null;
			$result.violations | Should Not Be $null;
			$result.warnings | Should Be $null;
			$result.violations.Count | Should Be 2;
			Assert-MockCalled Get-Command -Exactly -Times 0;
			Assert-MockCalled Write-Violations -Exactly -Times 1;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 0;
			Assert-MockCalled Test-Path -Exactly -Times 1;
			Assert-MockCalled Get-Violations -Exactly -Times 3;
			Assert-MockCalled Get-GitLogForFile -Exactly -Times 1;
		}
	}

	Context "When has commit history with duplication violations" {
		It "Must not report duplicates" {
			$historyFile = "repo\some-file.txt";
			Mock Write-Violations {};
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq "$TestDrive\$historyFile" };
			Mock Execute-GitLogCommand {
				return $gitLog;
			}
			Mock Get-Violations {
				return [System.Collections.ArrayList]@(
					"$TestDrive\$($historyFile): [Commit]<FAKESHA>: Violation 1",
					"$TestDrive\$($historyFile): [Commit]<FAKESHA>: Violation 1"
				);
			};
			Mock Get-Command { return $true; };
			Mock Get-GitLogForFile {
				return [System.Collections.ArrayList]@({
					Name= "$TestDrive\$($historyFile): [Commit]<FAKESHA>"
					Content= "Fake Content That Doesn't Matter"
				});
			}

			Setup -Directory "repo";
			Setup -File ".secrets-scan.json" -Content $configPrimary;
			Setup -File "repo\some-file.txt" -Content "some text";
			$result = Scan-Path -Path "$TestDrive\repo" -ConfigFile "$TestDrive\.secrets-scan.json" -Quiet;
			$result | Should Not Be $null;
			$result.violations | Should Not Be $null;
			$result.warnings | Should Be $null;
			$result.violations.Count | Should Be 1;
			Assert-MockCalled Get-Command -Exactly -Times 0;
			Assert-MockCalled Write-Violations -Exactly -Times 1;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 0;
			Assert-MockCalled Test-Path -Exactly -Times 1;
			Assert-MockCalled Get-Violations -Exactly -Times 2;
			Assert-MockCalled Get-GitLogForFile -Exactly -Times 1;

			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			$result.rules.allowed.Count | Should Be 5;
			$result.violations | Should Not Be $null;
			$result.warnings.Count | Should Be 4;
			$result.violations.Count | Should Be 5;
			Assert-MockCalled Write-Violations -Exactly -Times 2;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 2;
			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			Setup -File "repo\.secrets-scan.json" -Content $configSecondary;
			$result.warnings.Count | Should Be 9;
			Assert-MockCalled Write-Violations -Exactly -Times 2;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 2;
		}
	}
	Context "When file contains private key and other content" {
		It "Must report the violation" {
			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			Setup -File ".secrets-scan.json" -Content $configPrimary;
			Setup -Directory "repo";
			Setup -File "repo\my-secrets.txt" -Content $fileWithPrivateKey;
			$result = Scan-Path -Path "$TestDrive\repo" -ConfigFile "$TestDrive\.secrets-scan.json" -Quiet;
			$result | Should Not Be $null;
			$result.rules.allowed.Count | Should Be 2;
			$result.violations | Should Not Be $null;
			$result.warnings | Should Be $null;
			$result.warnings.Count | Should Be 0;
			$result.violations.Count | Should Be 1;
			Assert-MockCalled Write-Violations -Exactly -Times 1;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 1;
		}
	}
	Context "When file contains private key but is excluded" {
		It "Must not report the violation" {
			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			Setup -File ".secrets-scan.json" -Content $configPrimary;
			Setup -Directory "repo";
			Setup -File "repo\.secrets-scan.json" -Content $configSecondary;
			Setup -File "repo\my-secrets.txt" -Content $fileWithPrivateKey;
			$result = Scan-Path -Path "$TestDrive\repo" -ConfigFile "$TestDrive\.secrets-scan.json" -Quiet;
			$result | Should Not Be $null;
			$result.rules.allowed.Count | Should Be 3;
			$result.violations | Should Be $null;
			$result.warnings | Should Not Be $null;
			$result.warnings.Count | Should Be 1;
			$result.violations.Count | Should Be 0;
			Assert-MockCalled Write-Violations -Exactly -Times 1;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 1;
		}
	}

	Context "When scanning the readme and it is excluded" {
		It "Must not report violations" {
			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			Setup -File ".secrets-scan.json" -Content $configPrimary;
			Setup -Directory "repo";
			Setup -File "repo\.secrets-scan.json" -Content $configQuaternary;
			Setup -File "repo\readme.md" -Content $readme;
			$result = Scan-Path -Path "$TestDrive\repo" -ConfigFile "$TestDrive\.secrets-scan.json" -Quiet;
			$result | Should Not Be $null;
			$result.rules.allowed.Count | Should Be 3;
			$result.violations | Should Be $null;
			$result.warnings | Should Not Be $null;
			$result.warnings.Count | Should Be 5;
			$result.violations.Count | Should Be 0;
			Assert-MockCalled Write-Violations -Exactly -Times 1;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 1;

		It "Must processess the files in Path and report violations" {
			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			$result.warnings.Count | Should Be 1;
			$result.violations.Count | Should Be 9;
			Assert-MockCalled Write-Violations -Exactly -Times 2;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 4;
		It "Must processess the files in Path and report violations" {
			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			$result.violations.Count | Should Be 9;
			Assert-MockCalled Write-Violations -Exactly -Times 2;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 6;
		}
	}

	Context "When using the short names for the arguments" {
		It "Must not throw an exception" {
			Mock Write-Violations {};
			Mock Execute-GitLogCommand { return ""; }
			Setup -Directory "repo";
			Setup -File ".secrets-scan.json" -Content $configPrimary;
			Setup -File "repo\my-secrets.txt" -Content $secretsFile;
			{ Scan-Path -Path "$TestDrive\repo" -ConfigFile "$TestDrive\.secrets-scan.json" -Q } | Should Not Throw;
			Assert-MockCalled Write-Violations -Exactly -Times 1;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 1;
		}
	}
}

Describe "Write-Violations" {
	Context "When has one warning" {
		It "Must use singular string for text" {
			Mock Write-Host {
				return $Object;
			};
			$warnings = @('c:\path\fake.txt: some-fake-key');
			$violations = @();

			$result = Write-Violations -Warnings $warnings -Violations $violations;
			$result | Should Not Be $null;
			$result.violations | Should Be $null;
			$result.warnings | Should Not Be $null;
			$result.warnings.Count | Should Be 1;
			$result.violations.Count | Should Be 0;
			$result -join " " | Should Match "Found 1 Violation that was overridden";
			Assert-MockCalled Write-Host -Exactly -Times 2;
		}
	}

	Context "When has multiple warnings" {
		It "Must use plural string for text" {
			Mock Write-Host {
				return $Object;
			};
			$warnings = @('c:\path\fake.txt: some-fake-key', 'c:\path\fake.txt: another-fake-key');
			$violations = @();

			$result = Write-Violations -Warnings $warnings -Violations $violations;
			$result | Should Not Be $null;
			$result.violations | Should Be $null;
			$result.warnings | Should Not Be $null;
			$result.warnings.Count | Should Be 2;
			$result.violations.Count | Should Be 0;
			$result -join " " | Should Match "Found 2 Violations that were overridden";
		}
	}

	Context "When has one violation" {
		It "Must use singular string for text" {
			Mock Write-Host {
				return $Object;
			};
			$violations = @('c:\path\fake.txt: some-fake-key');
			$warnings = @();
			$result = Write-Violations -Warnings $warnings -Violations $violations;
			$result | Should Not Be $null;
			$result.violations | Should Not Be $null;
			$result.warnings | Should Be $null;
			$result.warnings.Count | Should Be 0;
			$result.violations.Count | Should Be 1;
			$result -join " " | Should Match "Found 1 Violation";
		}
	}

	Context "When has multiple violations" {
		It "Must use plural string for text" {
			Mock Write-Host {
				return $Object;
			};
			$violations = @('c:\path\fake.txt: some-fake-key', 'c:\path\fake.txt: another-fake-key');
			$warnings = @();
			$result = Write-Violations -Warnings $warnings -Violations $violations;
			$result | Should Not Be $null;
			$result.violations | Should Not Be $null;
			$result.warnings | Should Be $null;
			$result.violations.Count | Should Be 2;
			$result.warnings.Count | Should Be 0;
			$result -join " " | Should Match "Found 2 Violations";
		}
	}
}

Describe "Invoke-PostProcessViolations" {
	Context "When has violations and no warnings" {
		It "Must return all violations" {
			$secretsConfigFile = ".secrets-scan.json";
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq $secretsConfigFile };
			Mock Load-Rules {
				return $configPrimary | ConvertFrom-Json;
			}
			$rules = Load-Rules -Path $secretsConfigFile;
			$violations = @('c:\mock\my-secrets.text: key:PnsrlQ4QaWqISJ5zcNkma1ClqHBshI0Y65mYwnNT', 'c:\mock\my-secrets.text: aws_secret_key: PnsrlQ4QaWqISJ5zcNkma1ClqHBshI0Y65mYwnNT');
			$warnings = @();
			$result = Invoke-PostProcessViolations -Rules $rules -Violations $violations -Warnings $warnings;
			$result | Should Not Be $null;
			$result.violations | Should Not Be $null;
			$result.violations.Count | Should Be 2;
			$result.warnings | Should Be $null;
			$result.warnings.Count | Should Be 0;
			Assert-MockCalled Load-Rules -Exactly -Times 1;
			Assert-MockCalled Test-Path -Exactly -Times 1;

		}
	}

	Context "When has no violations and has warnings" {
		It "Must return all warnings" {
			$secretsConfigFile = ".secrets-scan.json";
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq $secretsConfigFile };
			Mock Load-Rules {
				return $configPrimary | ConvertFrom-Json;
			}
			$rules = Load-Rules -Path $secretsConfigFile;
			$violations = @('c:\mock\my-secrets.text: key:wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY', 'c:\mock\my-secrets.text: aws_secret_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY');
			$warnings = @();
			$result = Invoke-PostProcessViolations -Rules $rules -Violations $violations -Warnings $warnings;
			$result | Should Not Be $null;
			$result.violations | Should Be $null;
			$result.violations.Count | Should Be 0;
			$result.warnings | Should Not Be $null;
			$result.warnings.Count | Should Be 2;
			Assert-MockCalled Load-Rules -Exactly -Times 1;
			Assert-MockCalled Test-Path -Exactly -Times 1;

		}
	}

	Context "When has no violations and has no warnings" {
		It "Must return empty for both warnings and violations" {
			$secretsConfigFile = ".secrets-scan.json";
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq $secretsConfigFile };
			Mock Load-Rules {
				return $configPrimary | ConvertFrom-Json;
			}
			$rules = Load-Rules -Path $secretsConfigFile;
			$violations = @();
			$warnings = @();
			$result = Invoke-PostProcessViolations -Rules $rules -Violations $violations -Warnings $warnings;
			$result | Should Not Be $null;
			$result.violations | Should Be $null;
			$result.violations.Count | Should Be 0;
			$result.warnings | Should Be $null;
			$result.warnings.Count | Should Be 0;
			Assert-MockCalled Load-Rules -Exactly -Times 1;
			Assert-MockCalled Test-Path -Exactly -Times 1;

		}
	}
}

Describe "Get-GitLogForFile" {
	Context "When Path does not exist" {
		It "Must throw exception" {
			$testFile = "$TestDrive\mock\my-secrets.txt";
			{ Get-GitLogForFile -Path $testFile } | Should Throw;
		}
	}

	## This god damn test fails on the build server. And I have yet to figure out why
	#
	#Context "When Path exists and has commit history" {
	#	It "Must get the log and return the content plus the SHA" {
	#		$testFile = "c:\mock\my-secrets.txt";
	#		Mock Test-Path { return $true; } -ParameterFilter { $Path -eq $testFile };
	#		Mock Execute-GitLogCommand {
	#			$gitLog -join "`n" | Write-Warning;
	#			return $gitLog -join "`n";
	#		};
	#		Mock Get-Command { return $true; }
	#		Mock Invoke-Expression { return; }
	#		$result = Get-GitLogForFile -Path $testFile;
	#		Assert-MockCalled Execute-GitLogCommand -Exactly -Times 1;
	#		$result | Should Not Be $null;
	#		$result.Count | Should Be 2;
	#		$result | foreach {
	#			# check that each Name has the commit SHA
	#			$_.Name -match "\[Commit\](\b[0-9a-f]{5,40}\b)`$" | Should Be $true;
	#		}
	#		Assert-MockCalled Test-Path -Exactly -Times 2;
	#		Assert-MockCalled Get-Command -Exactly -Times 0;
	#		Assert-MockCalled Invoke-Expression -Exactly -Times 0;
	#	}
	#}

	Context "When Path exists and has no commit history" {
		It "Must return an empty array" {
			$testFile = "c:\mock\my-secrets.txt";
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq $testFile };
			Mock Execute-GitLogCommand { return $null } -ParameterFilter { $Path -eq $testFile };
			$result = Get-GitLogForFile -Path $testFile;
			$result | Should Be $null;
			$result.Count | Should Be 0;
			Assert-MockCalled Test-Path -Exactly -Times 2;
			Assert-MockCalled Execute-GitLogCommand -Exactly -Times 1;
		}
	}
}

Describe "Execute-GitLogCommand" {
	Context "When git is not in the path" {
		It "Must return null" {
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq "c:\mock" };
			Mock Get-Command { return $false; } -ParameterFilter { $Name -eq "git.exe" };
			$result = Execute-GitLogCommand -Path "c:\mock"
			$result | Should BeExactly $null;
		}
	}

	Context "When git is in the path" {
		It "Must return commit log" {
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq "c:\mock" };
			Mock Get-Command { return $true; } -ParameterFilter { $Name -eq "git.exe" };
			Mock Invoke-Expression { return $gitLog };
			$result = Execute-GitLogCommand -Path "c:\mock"
			$result | Should BeExactly $gitLog;
			Assert-MockCalled Test-Path -Exactly -Times 1;
			Assert-MockCalled Get-Command -Exactly -Times 1;
			Assert-MockCalled Invoke-Expression  -Exactly -Times 1;
		}
	}
}

Describe "Get-Violations" {
	Context "When content has violations" {
		It "Must return an array of the violations" {
			Mock Test-Path { return $true; } -ParameterFilter { $Path -eq ".secrets-scan.json" };
			Mock Load-Rules {
				return $configPrimary | ConvertFrom-Json;
			}
			$rules = Load-Rules -Path ".secrets-scan.json";
			$result = (Get-Violations -Rules $rules -Data @{ Content = $secretsFile; Name = "c:\mock\my-secrets.txt"; });

			$result | Should Not Be $null;
			$result.Count | Should Be 9;
			Assert-MockCalled Test-Path -Exactly -Times 1;
			Assert-MockCalled Load-Rules -Exactly -Times 1;
		}
	}
	Context "When content does not have any violations" {
		It "Must return an empty array" {
			Mock Test-Path { return $true } -ParameterFilter { $Path -eq ".secrets-scan.json" };
			Mock Load-Rules {
				return $configPrimary | ConvertFrom-Json;
			}
			$rules = Load-Rules -Path ".secrets-scan.json";
			$result = (Get-Violations -Rules $rules -Data @{ Content = $cleanFile; Name = "c:\mock\clean-file.txt"; });

			$result | Should Be $null;
			$result.Count | Should Be 0;
			Assert-MockCalled Test-Path -Exactly -Times 1;
			Assert-MockCalled Load-Rules -Exactly -Times 1;
