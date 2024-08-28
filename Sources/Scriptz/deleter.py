import os

# Folder path
folder_path = "../../AssetsHighRes/SoundEffects"

# List of files to keep
files_to_keep = [
    "5_second_countdown.m4a",
    "airhorn.m4a",
    "among_us_eject.m4a",
    "anime_wow.m4a",
    "applause_sort.m4a",
    "ara_ara__oh_my_dear.m4a",
    "ayaya_-_oh_my_gah.m4a",
    "beethoven_the_destiny_symphony.m4a",
    "bruh.m4a",
    "censor_beep.m4a",
    "dramatic_gunshot.m4a",
    "fbi_open_the_door.m4a",
    "fnaf_running.m4a",
    "illuminati_confirmed.m4a",
    "mario_jump.m4a",
    "metal_gear_solid_alert.m4a",
    "omae_wa_mou_shindeiru.m4a",
    "to_be_continued.m4a",
    "vine_boom_sound.m4a",
    "windows_xp_-_startup_sound.m4a",
]

# Iterate over all files in the folder
for filename in os.listdir(folder_path):
    file_path = os.path.join(folder_path, filename)
    # Check if the file is not in the list of files to keep
    if filename not in files_to_keep:
        # Check if it is a file and not a directory
        if os.path.isfile(file_path):
            os.remove(file_path)  # Delete the file
            print(f"Deleted: {file_path}")
        else:
            print(f"Skipped (not a file): {file_path}")
    else:
        print(f"Kept: {file_path}")
