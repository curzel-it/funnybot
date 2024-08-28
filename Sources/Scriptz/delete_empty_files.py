import os

directory_path = "../../AssetsHighRes/SoundEffects"

for filename in os.listdir(directory_path):
    path = os.path.join(directory_path, filename)
    # Check if it's a file
    if os.path.isfile(path):
        # Get the size of the file
        size = os.path.getsize(path)
        # If the file is smaller than 10 bytes, delete it
        if size < 10:
            os.remove(path)

print("Conversion complete.")
