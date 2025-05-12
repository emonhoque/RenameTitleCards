# Get the folder where the script is located
$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logPath = Join-Path $basePath "rename_log.txt"
$whatIfMode = $false  # Set to $true for dry run

# Start fresh log
"Rename Log - $(Get-Date)" | Out-File -FilePath $logPath

# Convert "S3 E2" or "S03E02" → "S03E02"
function ExtractNormalizedCode($name) {
    if ($name -match "(?i)s\s*(\d{1,2})\s*e\s*(\d{1,2})" -or $name -match "(?i)s(\d{1,2})e(\d{1,2})") {
        $season = "{0:D2}" -f [int]$matches[1]
        $episode = "{0:D2}" -f [int]$matches[2]
        return "S$season`E$episode".ToUpper()
    }
    return $null
}

# Loop through all .jpg images
Get-ChildItem -Path $basePath -Recurse -File | Where-Object {
    $_.Extension -match "\.jpe?g$|\.png$|\.webp$"
} | ForEach-Object {
	$image = $_

	# Skip season, specials, and poster images
	if ($image.BaseName -match "^(?i)(season\d{1,4}|specials|poster)$") {
		return
	}

	$code = ExtractNormalizedCode $image.BaseName

    Add-Content $logPath "`nImage: $($image.FullName)"

    if (-not $code) {
        Add-Content $logPath "Could not extract episode code"
        return
    }

    $seasonFolder = Split-Path $image.FullName -Parent

    $videos = Get-ChildItem -Path $seasonFolder -File | Where-Object {
        $_.Extension -in @(".mkv", ".mp4", ".avi", ".m4v", ".mov") -and $_.BaseName -match $code
    }
    
    if ($videos.Count -eq 0) {
        Add-Content $logPath "No video match found"
        return
    }

    $bestMatch = $videos | Sort-Object { $_.BaseName.Length } | Select-Object -First 1
    $newImageName = "$($bestMatch.BaseName).jpg"
    $newImagePath = Join-Path $seasonFolder $newImageName

    if (Test-Path $newImagePath) {
        Add-Content $logPath "Skipped: $newImageName already exists"
    } else {
        if ($whatIfMode) {
            Add-Content $logPath "Would rename: $($image.Name) -> $newImageName"
        } else {
            Rename-Item -Path $image.FullName -NewName $newImageName
            Add-Content $logPath "Renamed: $($image.Name) -> $newImageName"
        }
    }
}
