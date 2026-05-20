import os
import shutil
import time

DOWNLOADS = "/storage/emulated/0/Download"
DESTINATIONS = {
    "images": ["/storage/emulated/0/Pictures", ".jpg", ".png", ".webp", ".jpeg"],
    "docs": ["/storage/emulated/0/Documents", ".pdf", ".docx", ".txt", ".md"],
    "music": ["/storage/emulated/0/Music", ".mp3", ".m4a", ".wav"],
    "archives": ["/storage/emulated/0/Download/Archives", ".zip", ".rar", ".7z"]
}

def organize():
    print(f"Scanning {DOWNLOADS}...")
    count = 0
    for filename in os.listdir(DOWNLOADS):
        filepath = os.path.join(DOWNLOADS, filename)
        if os.path.isdir(filepath): continue
        
        ext = os.path.splitext(filename)[1].lower()
        for category, config in DESTINATIONS.items():
            dest_dir = config[0]
            extensions = config[1:]
            if ext in extensions:
                if not os.path.exists(dest_dir): os.makedirs(dest_dir)
                shutil.move(filepath, os.path.join(dest_dir, filename))
                print(f"Moved {filename} to {category}")
                count += 1
                break
    print(f"Done. Organized {count} files.")

if __name__ == "__main__":
    organize()
