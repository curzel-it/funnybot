import os
import shutil

from PIL import Image


def downscale_image(input_path, output_path, scale_factor):
    if input_path.endswith(".mp3") or input_path.endswith(".m4a"):
        os.system(f"cp {input_path} {output_path}")
        return

    with Image.open(input_path) as img:
        if img.width < 200 or img.height < 200:
            img.save(output_path)
        else:
            new_size = (img.width // scale_factor, img.height // scale_factor)
            img.resize(new_size).save(output_path)


def copy_and_downscale_images(src_dir, dst_dir, scale_factor):
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)

    for root, dirs, files in os.walk(src_dir):
        for dir in dirs:
            os.makedirs(
                os.path.join(
                    dst_dir, os.path.relpath(os.path.join(root, dir), src_dir)
                ),
                exist_ok=True,
            )

        for file in files:
            if file.lower().endswith((".png", ".jpg", ".jpeg", ".bmp", ".gif", ".m4a")):
                src_file = os.path.join(root, file)
                dst_file = os.path.join(dst_dir, os.path.relpath(src_file, src_dir))
                downscale_image(src_file, dst_file, scale_factor)


if __name__ == "__main__":
    source_folder = "../../AssetsHighRes"
    destination_folder = "../../AssetsLowRes"
    scale_factor = 8
    copy_and_downscale_images(source_folder, destination_folder, scale_factor)

"""
    import sys
    if len(sys.argv) != 4:
        print("Usage: python3 main.py <source_folder> <destination_folder> <scale_factor>")
        sys.exit(1)

    source_folder = sys.argv[1]
    destination_folder = sys.argv[2]
    scale_factor = int(sys.argv[3])

    copy_and_downscale_images(source_folder, destination_folder, scale_factor)
"""
