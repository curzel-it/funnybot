import os

import cv2


def video_to_images(video_path, output_folder):
    # Check if output folder exists, if not, create it
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Load the video
    cap = cv2.VideoCapture(video_path)

    count = 0
    while True:
        # Read frame by frame
        ret, frame = cap.read()

        # If frame is read correctly, ret is True
        if not ret:
            break

        # Save each frame as PNG in the output folder
        output_path = os.path.join(output_folder, f"frame_{count:04d}.png")
        cv2.imwrite(output_path, frame)
        count += 1

    # Release the video capture object
    cap.release()
    print(f"Done! Extracted {count} frames.")


# Example usage
video_path = "/Users/curzel/dev/funnybot/AssetsHighRes/Overlays/LikeAndSubscribe/like-and-subscribe-05-SBV-347596325-HD.mov"
output_folder = "/Users/curzel/dev/funnybot/AssetsHighRes/Overlays/LikeAndSubscribe"
video_to_images(video_path, output_folder)
