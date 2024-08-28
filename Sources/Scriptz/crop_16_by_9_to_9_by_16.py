import os

from PIL import Image


def crop_images_in_folder(folder_path):
    # Directory where the cropped images will be saved
    cropped_dir = os.path.join(folder_path, "cropped_images")
    if not os.path.exists(cropped_dir):
        os.makedirs(cropped_dir)

    for filename in os.listdir(folder_path):
        if filename.endswith(".png"):
            image_path = os.path.join(folder_path, filename)
            with Image.open(image_path) as img:
                width, height = img.size

                x = int((height - width) / 2)
                y = 620

                # cropped_img = img.crop((left, top, right, bottom))
                final_path = os.path.join(cropped_dir, filename)

                new_image = Image.new("RGBA", (height, width), (255, 0, 0, 0))
                # Paste the original image into the new image, but shifted down
                new_image.paste(img, (x, y), img)
                new_image.save(final_path)

                print(f"Cropped and saved: {final_path}")


folder_path = "../../AssetsHighRes/Overlays/LikeAndSubscribeShorts"
crop_images_in_folder(folder_path)
