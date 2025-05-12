$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logPath = Join-Path $basePath "rename_log.txt"
$whatIfMode = $false  # Set to $true for dry run

"Rename Log - $(Get-Date)" | Out-File -FilePath $logPath -Encoding utf8

function ExtractNormalizedCode($name) {
    if ($name -match "(?i)s\s*(\d{1,2})\s*e\s*(\d{1,2})" -or $name -match "(?i)s(\d{1,2})e(\d{1,2})") {
        $season = "{0:D2}" -f [int]$matches[1]
        $episode = "{0:D2}" -f [int]$matches[2]
        return "S$season`E$episode".ToUpper()
    }
    return $null
}

Get-ChildItem -Path $basePath -Recurse -File | Where-Object {
    $_.Extension -match "\.jpe?g$|\.png$|\.webp$"
} | ForEach-Object {
	$image = $_

	# Skip season, specials, and poster images
	if ($image.BaseName -match "^(?i)(season\d{1,4}|specials|poster)$") {
		return
	}

	$code = ExtractNormalizedCode $image.BaseName

    Add-Content -Path $logPath -Value "`nImage: $($image.FullName)" -Encoding utf8

    if (-not $code) {
        Add-Content -Path $logPath -Value "Could not extract episode code" -Encoding utf8
        return
    }

    $seasonFolder = Split-Path $image.FullName -Parent

    $videos = Get-ChildItem -Path $seasonFolder -File | Where-Object {
        $_.Extension -in @(".mkv", ".mp4", ".avi", ".m4v", ".mov") -and $_.BaseName -match $code
    }
    
    if ($videos.Count -eq 0) {
        Add-Content -Path $logPath -Value "No video match found" -Encoding utf8
        return
    }

    $bestMatch = $videos | Sort-Object { $_.BaseName.Length } | Select-Object -First 1
    $newImageName = "$($bestMatch.BaseName)$($image.Extension.ToLower())"
    $newImagePath = Join-Path $seasonFolder $newImageName

    if (Test-Path $newImagePath) {
        Add-Content -Path $logPath -Value "Skipped: $newImageName already exists" -Encoding utf8
    } else {
        if ($whatIfMode) {
            Add-Content -Path $logPath -Value "Would rename: $($image.Name) -> $newImageName" -Encoding utf8
        } else {
            Rename-Item -Path $image.FullName -NewName $newImageName
            Add-Content -Path $logPath -Value "Renamed: $($image.Name) -> $newImageName" -Encoding utf8
        }
    }
}
