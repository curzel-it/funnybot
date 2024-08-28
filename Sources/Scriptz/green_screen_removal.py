import os

from PIL import Image


def is_green(rgb):
    """Determine if a pixel is within the range of green colors to be replaced."""
    # Define the range of green in RGB
    green_range = {"min": (0, 50, 0), "max": (180, 255, 180)}
    return all(
        green_range["min"][i] <= rgb[i] <= green_range["max"][i] for i in range(3)
    )


def replace_green_with_transparency(image_path, save_path):
    # Open the image file
    img = Image.open(image_path)
    # Convert the image to RGBA if it is not already
    img = img.convert("RGBA")

    # Load the data of the image
    datas = img.getdata()

    newData = []
    for item in datas:
        # Change all green (with the specific RGB value) to transparency
        if is_green(item):
            # Adding a fourth element for transparency (0 means transparent)
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)

    # Update image data
    img.putdata(newData)
    # Save the modified image
    img.save(save_path, "PNG")


root = "/Users/curzel/dev/funnybot/AssetsHighRes/Overlays/LikeAndSubscribe"

# List of your PNG image paths
for filename in sorted(os.listdir(root)):
    if not filename.endswith("png"):
        continue
    path = f"{root}/{filename}"
    save_path = path  # .replace('.png', '_transparent.png') # Modify as needed
    replace_green_with_transparency(path, save_path)
    print(f"Processed and saved: {save_path}")
