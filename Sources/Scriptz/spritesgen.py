import os
import subprocess
import sys

aseprite_path = "/Applications/Aseprite.app/Contents/MacOS/aseprite"
aseprite_assets_folders = ["/Users/federicocurzel/dev/pet-therapy/Aseprite"]
pngs_folder = "../BitTherapy/Assets/Sprites"
ignore_talking_layers = '--ignore-layer "Talking" --ignore-layer "talking"'
ignore_nontalking_layers = '--ignore-layer "NonTalking" --ignore-layer "nontalking"'


def export_aseprite(file_path, destination_folder):
    if "/palettes/" in file_path:
        return

    asset_name = file_path.split("/")[-1].split(".")[0]
    asset_name = asset_name[:-1] if asset_name.endswith("-") else asset_name
    asset_name = asset_name.replace("_fly-", "_walk-")
    asset_name = asset_name.replace("_fly_talk-", "_walk_talk-")

    cmd = f"{aseprite_path} --all-layers -b {file_path}"

    if does_talk(file_path):
        command = f"{cmd} {ignore_nontalking_layers} --save-as {destination_folder}/{asset_name}_talk-0.png"
        os.system(command)

    command = f"{cmd} {ignore_talking_layers} --save-as {destination_folder}/{asset_name}-0.png"
    os.system(command)


def does_talk(path):
    cmd = [aseprite_path, "--batch", "--list-layers", path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    for line in result.stdout.splitlines():
        if line.strip().lower() == "talking":
            return True
    return False


def find_aseprite_files(folder):
    paths = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".aseprite") or file.endswith(".ase"):
                paths.append(os.path.join(root, file))
    return paths


def export_all_aseprite(root_folder, destination_folder, filter):
    print(f"Looking for *.aseprite and *.ase file in {root_folder}...")
    files = find_aseprite_files(root_folder)
    print(f"Found {len(files)} files")
    for i, file in enumerate(files):
        if i % 10 == 0:
            print(f"Exported {i} files out of {len(files)}")
        if filter(file):
            export_aseprite(file, destination_folder)


name = sys.argv[1] if len(sys.argv) == 2 else ""
for folder in aseprite_assets_folders:
    export_all_aseprite(folder, pngs_folder, lambda path: name in path)
