# Funnybot
So, I made and app to make short cringy animations, it works like this:

1. You can define a series with a context and a list of characters
2. You can define episodes with a plot and a script
3. The script is written in a language called [FunnyScript](Sources/Docs/funnyscripy_docs.md), which I developed
4. The LLM of your choice can help you convert a plot into FunnyScript, or write it for you
5. Audio for dialogs is generated via ElevenLabs (or macOS voice synthesizer)
6. The script is "compiled", that is, each instruction in it is assigned a start time and a duration (taking into account audio duration for each line of dialog, sounds effects, animations, ...)
7. Entities are moved around following the instructions
8. An image is taked for each frame
9. Images are stitched togeter into a video
10. Audio is added in

## What does it look like?
[![Here's the channel trailer](screenshots/channel-trailer.webp)](https://youtu.be/I9TS46Z1wM4)

I have other videos on [my YouTube channel](https://www.youtube.com/@HiddenMugs)

## Why? 
Idk.

## Does it work? Can I use it?
I mean, there's far, FAR better tools out there, but go ahead... If you really want to try it out I won't stop you 😂

The file [funnybot.json](funnybot.json) can be imported directly in the app and include the "source" for most of my videos, the repo also includes the same assets I use.

## Screenshots
Homepage, showing the list of your series and general settings
![Your series](screenshots/home.png)
Each series has a list of episode, as well as some dedicated settings
![Series details](screenshots/series-details.png)
Example of what an episode looks like
![Episode details](screenshots/episode-details.png)
