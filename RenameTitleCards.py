import os
import re
from datetime import datetime
from pathlib import Path
import shutil

what_if_mode = False  # Set to True for dry run
valid_image_exts = ['.jpg', '.jpeg', '.png', '.webp']
valid_video_exts = ['.mkv', '.mp4', '.avi', '.m4v', '.mov']
log_file = Path("rename_log.txt")

log_file.write_text(f"Rename Log - {datetime.now()}\n", encoding="utf-8")

def extract_normalized_code(name):
    match = re.search(r'(?i)s\s*(\d{1,2})\s*e\s*(\d{1,2})', name) or re.search(r'(?i)s(\d{1,2})e(\d{1,2})', name)
    if match:
        season = f"{int(match.group(1)):02}"
        episode = f"{int(match.group(2)):02}"
        return f"S{season}E{episode}"
    return None

def log(line):
    print(line)
    with log_file.open("a", encoding="utf-8") as f:
        f.write(line + "\n")

def should_skip(basename):
    return re.match(r'(?i)^(season\d{1,4}|specials|poster)$', basename) is not None

def find_best_video_match(folder, code):
    videos = [f for f in folder.iterdir() if f.is_file() and f.suffix.lower() in valid_video_exts and code in f.stem]
    if not videos:
        return None
    return sorted(videos, key=lambda f: len(f.stem))[0]

for root, dirs, files in os.walk("."):
    for file in files:
        image_path = Path(root) / file
        if image_path.suffix.lower() not in valid_image_exts:
            continue

        basename = image_path.stem
        if should_skip(basename):
            continue

        code = extract_normalized_code(basename)
        log(f"\nImage: {image_path.resolve()}")
        if not code:
            log("Could not extract episode code")
            continue

        season_folder = image_path.parent
        best_video = find_best_video_match(season_folder, code)
        if not best_video:
            log("No video match found")
            continue

        new_name = best_video.stem + image_path.suffix.lower()
        new_path = season_folder / new_name

        if new_path.exists():
            log(f"Skipped: {new_name} already exists")
        else:
            if what_if_mode:
                log(f"Would rename: {image_path.name} -> {new_name}")
            else:
                shutil.move(str(image_path), str(new_path))
                log(f"Renamed: {image_path.name} -> {new_name}")
