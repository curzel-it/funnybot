import os
import subprocess

# Set the path to the directory containing your MP3 files
directory_path = "../../AssetsHighRes/SoundEffects"

# Loop through all files in the directory
for filename in os.listdir(directory_path):
    if filename.endswith(".m4a"):
        source = os.path.join(directory_path, filename)
        sanitized_name = (
            filename.lower()
            .replace(" ", "_")
            .replace("{", "")
            .replace("}", "")
            .replace("(", "")
            .replace(")", "")
            .replace("!", "")
            .replace("...", "")
            .replace(",", "")
            .replace("'s", "s")
            .replace("'", "")
            .replace('"', "")
            .replace("&", "and")
        )
        destination = os.path.join(directory_path, sanitized_name)
        os.system(f'mv "{source}" "{destination}"')

print("Conversion complete.")
