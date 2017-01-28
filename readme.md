# Secrets Scan

This is a `powershell` script that will scan a directory for `secret violations`. These can be RSA keys,
AWS Access Keys, or any other type of secrets that may be present in code.

This will not prevent someone from checking them in to a `git` repository. The
purpose is for CI, like jenkins, to execute the scan before the build process,
and fail the build if there are secrets found.

If you would like to prevent the commit from even happening, you should look at
[`git-secrets` from _awslabs_](https://github.com/awslabs/git-secrets). This is a git hook bash script to run on your local development environment. They have a very detailed `readme`
to explain how to configure it.

## Mitigations

-  Mark false positives as allowed by adding exceptions to `.secrets-scan.json`
- Revoke the Secret that was identified. The secret is no longer secure as it now exists in the commit history, even if removed from code.

## Usage

`PS> ./Secrets-Scan.ps1 -Path C:\code\my-project\`

Rules are defined in `.secrets-scan.json` in the root directory of the `Secrets-Scan.ps1`.
Additionally, a scanned directory can contain its own `.secrets-scan.json` that will be
merged with the _root_ configuration. See the *Rules* section below for more information.

## Violations

The `exit code` of the script will be `0` for success, or it will be the count
of the number of violations found. The script will output the full path of the
files that have violations, and the matching violation.

```
C:\code\my-project\super-secret-key.txt: AWS_SECRET_KEY=PnsrlQ4QaWqISJ5zcNkma1ClqHBshI0Y65mYwnNT
C:\code\my-project\super-secret-key.txt: AWS_ACCESS_KEY=RtwpOEp4IeQqHawn7hsBIC13Cap2qCt1AmQqIOMY
C:\code\my-project\Subfolder\more-secrets.txt: aws_account_id:129398745743
C:\code\my-project\Subfolder\my-key.pem: -----BEGIN RSA PRIVATE KEY-----
C:\code\my-project\Subfolder\my-key.pub: -----BEGIN PUBLIC KEY-----

[Error]: Found 5 Violations.

Possible mitigations:
	- Mark false positives as allowed by adding exceptions to '.secrets-scan.json'
	- Revoke the Secret that was identified. The secret is no longer secure as it
	    now exists in the commit history, even if removed from code.

```

## Rules

Rules are defined in `.secrets-scan.json`. In there, you define the matching `patterns`,
and the `allowed` exceptions. Both `patterns` and `allowed` sections are arrays of
`regex` patterns.

### Pattern
This matches on the text in the file.

### Allowed
This matches on the file name and the violation match.

`/path/to/file.ext: VIOLATION_MATCH`

Ideally, only _basic_ exceptions should be defined in the main `.secrets-scan.json`,
other exceptions would be defined in a file, also called `.secrets-scan.json`, within
the root directory of the repository to be scanned. The script will load, and merge,
the 2 configurations together.

```
{
	"patterns": [
		"(?s)(\"|')?(AWS|aws|Aws)?_?(SECRET|secret|Secret)?_?(ACCESS|access|Access)?_?(KEY|key|Key)(\"|')?\\s*(:|=>|=)\\s*(\"|')?[A-Za-z0-9/\\+=]{40}(\"|')?",
		"(?s)(\"|')?(AWS|aws|Aws)?_?(ACCOUNT|account|Account)_?(ID|id|Id)?(\"|')?\\s*(:|=>|=)\\s*(\"|')?[0-9]{4}\\-?[0-9]{4}\\-?[0-9]{4}(\"|')?",
		"(?s)^-----BEGIN\\sRSA\\sPRIVATE\\sKEY-----",
		"(?s)^-----BEGIN\\sPUBLIC\\sKEY-----"
	],
	"allowed": [
		"AKIAIOSFODNN7EXAMPLE",
		"wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
	]
}
```
