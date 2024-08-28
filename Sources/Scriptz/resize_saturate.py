import os

from PIL import Image, ImageEnhance


def enhance_and_resize_images(folder_path):
    # Ensure the folder exists
    if not os.path.exists(folder_path):
        raise ValueError(f"Folder '{folder_path}' does not exist")

    # Loop through each file in the folder
    for file_name in os.listdir(folder_path):
        # Check if it's a PNG file
        if file_name.lower().endswith(".png"):
            image_path = os.path.join(folder_path, file_name)

            # Open and process the image
            with Image.open(image_path) as img:
                # Enhance saturation
                enhancer = ImageEnhance.Color(img)
                img_enhanced = enhancer.enhance(1.15)

                # Resize the image
                img_resized = img_enhanced.resize((320, 180), Image.NEAREST)

                # Save the processed image
                output_path = os.path.join(folder_path, file_name).replace(
                    "BackgroundsOriginal", "Backgrounds"
                )
                img_resized.save(output_path, "PNG")


# Example usage:
enhance_and_resize_images("/Users/federicocurzel/dev/funnybot/Junk")
