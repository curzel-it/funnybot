import subprocess

# video_path = 'path_to_your_video.mov'
# output_dir = 'output_frames'

video_path = "/Users/curzel/Desktop/Untitled.mov"  # Replace with your video path
output_folder = (
    "/Users/curzel/Desktop/frame_%04d.png"  # Replace with your desired output folder
)

# Build the FFmpeg command
command = ["ffmpeg", "-i", video_path, "-vf", "format=rgba", output_folder]

# Run the command
subprocess.run(command, check=True)
