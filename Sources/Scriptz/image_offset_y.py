import os
import pdb

from PIL import Image

image_directory = "aaa/Users/federicocurzel/Downloads"
output_directory = image_directory


# Iterate through all files in the directory
for filename in os.listdir(image_directory):
    if filename.endswith(".png"):
        # Open the image
        file_path = os.path.join(image_directory, filename)
        image = Image.open(file_path)

        # Create a new image with the same size and transparent background
        new_image = Image.new("RGBA", image.size, (255, 0, 0, 0))

        # Paste the original image into the new image, but shifted down
        new_image.paste(image, (0, 250), image)

        # Save the modified image
        output_path = os.path.join(output_directory, filename)
        new_image.save(output_path)

        print(f"Processed {filename}")
