###GLVideoFilter v1.2 [![Build Status](https://travis-ci.org/dghost/GLVideoFilter.svg)](https://travis-ci.org/dghost/GLVideoFilter)
Real-time image processing on a live video stream on iOS devices. This project was based on the [GLCameraRipple demo](http://developer.apple.com/library/ios/#samplecode/GLCameraRipple/Introduction/Intro.html), but has been updated to require iOS 6 and take advantage of iOS 7 features when available.

Note: This only runs on actual devices, and will not run in the simulator.

####Description

Built to support accessibility research by [Isla Schanuel](http://www.islaes.com), the purpose of this app was to evaluate the feasibility of edge detection techniques as an accessibility tool. While the screen size and form-factor of iOS devices is not conducive to real-world use, this was intended as a early prototype to test generating an accessible video stream from a non-stereoscopic video stream. As a result, the selection of filters is somewhat narrow in scope and is centered around providing meaningful ways of either enhancing a live video stream (by highlighting object edges) or transforming it entirely into a format that is easier for persons with reduced vision to see. 

The following filters have been implemented:

- Sobel operator using an RGB video stream as source
- Sobel operator using an Grayscale video stream source
- A blended Sobel operator that adds 50% of the grayscale result to the RGB result
- A composite that overlays the result of the Sobel operator on the grayscale video stream.
- A composite that overlays the result of the Sobel operator on the RGB video stream.
- Canny edge detector using a low threshold of 0.2
- A composite that overlays the Canny edge detection results on the grayscale video stream.
- A chained Sobel operator -> Canny edge detector with inverted colors

Additionally, an optional blur pre-pass can be enabled for any video filter.

The program works by performing the following steps:

- The `captureOutput:` delagate performs the following:
	- Performs a colorspace conversion from Y'UV to RGB for each pixel
	- Renders the RGB + Y data into a texture
	- Sets a flag to indicate that the texture has been updated
- During redraw, the 'glkView: drawInRect:' delegate performs the following:
	- Checks if a new frame is available, and if so:
		- It applies a gaussian blur if enabled
		- It applies a pre-pass filter if either of the Canny filters are enabled
		- The selected filter is applied and the result is cached
		- The texture is marked as having been processed
	- The appropriate texture is then rendered to the screen

####Usage
- One-finger left/right swipes cycle between filters.
- One-finger up/down swipes cycle between blur modes.
- One-finger tap locks or unlocks mode changing.

#####Thanks go out to...
- [Isla Schanuel](http://www.islaes.com), for being awesome to work with.
- [Jonathan George](http://jdg.net), for making [MBProgressHUD](https://github.com/jdg/MBProgressHUD).
- [Gary Gehiere](http://blog.iamgary.com/helloworld/), for creating the [Lock/Unlock icons](http://www.pixelpressicons.com/?p=108) and licsensing them as [Creative Commons CA 2.5](http://creativecommons.org/licenses/by/2.5/ca/).