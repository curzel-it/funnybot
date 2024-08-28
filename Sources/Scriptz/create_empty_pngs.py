import os

# Folder path
folder_path = "../../AssetsHighRes/SoundEffects"

# List of original files (for which to create 1x1 transparent PNGs)
original_files = [
    "airhorn.m4a",
    "among_us_eject.m4a",
    "anime_wow.m4a",
    "applause_sort.m4a",
    "ara_ara.m4a",
    "oh_my_gah.m4a",
    "beethoven_the_destiny_symphony.m4a",
    "bruh.m4a",
    "dramatic_gunshot.m4a",
    "fbi_open_the_door.m4a",
    "fnaf_running.m4a",
    "illuminati_confirmed.m4a",
    "mario_jump.m4a",
    "metal_gear_solid_alert.m4a",
    "omae_wa_mou_shindeiru.m4a",
    "to_be_continued.m4a",
    "vine_boom_sound.m4a",
    "windows_xp_startup.m4a",
]

# Iterate over the list of files
for original_file in original_files:
    os.system(
        f"cp {folder_path}/airhorn.png {folder_path}/{original_file.replace('m4a', 'png')}"
    )
