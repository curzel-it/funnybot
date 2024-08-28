import os
import subprocess

# Set the path to the directory containing your MP3 files
directory_path = "../../AssetsHighRes/SoundEffects"

# Loop through all files in the directory
for filename in os.listdir(directory_path):
    if filename.endswith(".mp3"):
        try:
            # Construct the full path to your file
            full_path = os.path.join(directory_path, filename)
            # Create the output filename by replacing the file extension
            output_filename = full_path.replace(".mp3", ".m4a")

            # Construct the FFmpeg command for converting the file
            command = [
                "ffmpeg",
                "-i",
                full_path,
                "-c:a",
                "aac",
                "-b:a",
                "128k",
                output_filename,
            ]

            # Execute the command
            subprocess.run(command, check=True)
        except:
            pass

print("Conversion complete.")
