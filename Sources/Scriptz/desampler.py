import os


def frame_index(filename):
    s = filename.split("_")[-1].split(".")[0].strip().strip("0")
    if s == "":
        return 0
    return int(s)


def reduce_fps(folder_path):
    files = os.listdir(folder_path)
    files = [f for f in files if f.endswith("png")]
    files = sorted(files, key=lambda f: frame_index(f))
    files = [f"{folder_path}/{f}" for f in files]

    for i in range(len(files)):
        if i % 3 != 0:
            os.remove(files[i])

    files = os.listdir(folder_path)
    files = [f for f in files if f.endswith("png")]
    files = sorted(files, key=lambda f: frame_index(f))

    for i, filename in enumerate(files):
        file_path = f"{folder_path}/{filename}"
        new_name = os.path.join(folder_path, f"frame-{i}.png")
        os.rename(file_path, new_name)


folder_path = "frames"
reduce_fps(folder_path)
