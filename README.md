# Mediux Image Renamer

This project provides two versions of the same utility — one written in **Python**, the other in **PowerShell** — to automatically rename TV episode image files to match their corresponding video filenames using the standardized format:

```
Show Name - SXXEXX - Title.jpg
```

---

## What It Does

- Recursively scans a TV series folder structure
- Finds episode image files using loose season/episode patterns (e.g., `s1e1`, `S 01 E 01`, etc.)
- Normalizes episode codes to uppercase format `SXXEXX`
- Matches each image file to a video file in the same folder with the same episode code
- Renames the image to match the video's filename base
- Skips files like `poster.jpg`, `season01.png`, and `specials.webp`
- Logs all actions to `rename_log.txt`

---

## Available Versions

### 1. Python (`RenameMediux.py`)
- Supports `.jpg`, `.jpeg`, `.png`, `.webp` images
- Matches video extensions: `.mkv`, `.mp4`, `.avi`, `.m4v`, `.mov`
- Dry run mode via:
```python
what_if_mode = True
```

### 2. PowerShell (`RenameMediux.ps1`)
- Supports `.jpg`, `.jpeg`, `.png`, `.webp` images
- Matches video extensions: `.mkv`, `.mp4`, `.avi`, `.m4v`, `.mov`
- Dry run mode via:
```powershell
$whatIfMode = $true
```
- Log output in `rename_log.txt` 

---

## Examples

### Example 1

#### Input Image:
```
"Show Name (Year) - S1 E1.jpg"
or
"S01E01.jpg"
or
"S1 E1.jpg"
```

#### Matching Video:
```
Show Name (Year) - S01E01 - Pilot.mkv
```

#### Output Image:
```
Show Name (Year) - S01E01 - Pilot.jpg
```

### Example 2

#### Input Image:
```
"Show Name (Year) - S1 E1.jpg"
or
"S01E01.jpg"
or
"S1 E1.jpg"
```

#### Matching Video:
```
Show Name (Year) - S01E01 - Pilot [WEB-DL 1080p][HDR][DD+5.1][H.264]-NTb.mkv
```

#### Output Image:
```
Show Name (Year) - S01E01 - Pilot [WEB-DL 1080p][HDR][DD+5.1][H.264]-NTb.jpg
```

This works because the script detects the `S01E01` episode code and renames the image to match the full video filename, regardless of additional tags or formatting.

---

## Skipped Examples
- `poster.jpg`
- `season02.webp`
- `specials.png`

These are recognized and ignored automatically.

---

## Edge Case Handling

- Chooses shortest matching video filename if multiple exist
- Only matches videos in the **same folder**
- Read-only or locked files may cause permission errors (no crash protection in PowerShell yet)
- Paths longer than 260 characters may fail on legacy Windows setups

---

## Requirements

- **Python Version**: Python 3.10 (Tested)
- **PowerShell Version**: Windows PowerShell 5.0 or later
- Compatible with Windows, Linux, or macOS (Python version)

---

## License

MIT License
