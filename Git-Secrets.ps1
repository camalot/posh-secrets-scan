param (
  [String] $Path
)
function Load-Rules {
  param (
    [String] $Path
  )
  process {
    return Get-Content -Raw -Path $Path | ConvertFrom-Json;
  }
}
function Scan-Path {
  param (
    [String] $Path
  )
	begin {
		$rules = Load-Rules -Path "./rules.json";
	}
  process {
		try {
			$children = @(Get-ChildItem -Path (Resolve-Path -Path $Path) -Recurse);
			[System.Collections.ArrayList] $violations = @();
			for($i = 0; $i -lt $children.Count; ++$i) {
	    # $children | foreach {
	      $item = $children[$i];
	      if ( -not $item.PSIsContainer ) {
					$content = Get-Content -Path $item.FullName;
					for($y = 0; $y -lt $rules.patterns.Count; ++$y) {
	        # $rules.patterns | foreach {
						$pattern = $rules.patterns[$y];
	          $content | Select-String -Pattern $pattern -AllMatches | foreach { $_.Matches; } | foreach {
							$match = $_
							$m = $match.Groups[0].Value;
	            $result = "$($item.FullName): $($match)";
							if ( $violations.IndexOf($result) -ge 0 ) {
								continue;
							}
							$violations.Add($result) | Out-Null;
	          };
	        };
	      } else {
					#return Recursive-Scan -Path $item.FullName;
	      }
	    };
			for($x = 0; $x -lt $violations.Count; ++$x) {
				$v = $violations[$x];
				$rules.allowed | foreach {
					$allowed = $_;
					if($v -match $allowed) {
						$vidx = $violations.IndexOf($v);
						if($vidx -ge 0) {
							$violations.Remove($v) | Out-Null;
						}
					}
				}
			}
			$violations | Write-Host;
			if($violations.Count -gt 0) {
				"`n[Error]: Found $($violations.Count) Violations.`n" | Write-Host -ForegroundColor DarkYellow;
				"Possible mitigations:`n`t- Mark false positives as allowed adding exceptions to 'rules.json'`n`n" | Write-Host -ForegroundColor DarkYellow;
				exit $violations.Count;
			}
	  } catch {
			$_ | Write-Error;
			exit 999;
		}
	}
}

Scan-Path -Path $Path;
