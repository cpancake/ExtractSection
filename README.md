ExtractSection
==============

It's a simple VLC extension that uses ffmpeg to extract sections of videos in VLC and saves them to WebM files. It's like an automatic gif-making tool except you have to handle converting it to a gif.

## Usage

Navigate to your VLC install directory, and put extractsection.lua in the lua/extensions folder. Then open up VLC, start something playing, and go to View > Extract Section. It will automatically fill in the start time field. All you need to do is specify the length of the clip in ffmpeg timestamp format (hh:mm:ss.ss), specify a bitrate, and add any additional command line parameters you want. `-an` is a useful one - it removes the audio stream.

![Main Extract Section Window](http://i.imgur.com/JP8TwKo.jpg)

After pressing start, a command line window will open (if you have ffmpeg installed and in your path, of course!) and show you the progress. You can minimize this and continue watching if you want. The resulting WebM will be saved in the directory of the video you're watching, with the name `<file name>-<start position>-<duration>.webm`. Do whatever you want with this.

## Things it can't do.

Subtitles. I can't get ffmpeg to burn in subtitles, no matter what I try.