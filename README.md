###GLVideoFilter v1.0
Real-time image processing on a live video stream on iOS devices. This project was based on the [GLCameraRipple demo](http://developer.apple.com/library/ios/#samplecode/GLCameraRipple/Introduction/Intro.html), but has been updated to require iOS 6 and take advantage of iOS 7 features when available.

Note: This only runs on actual devices, and will not run in the simulator.

####Description

Incorporating accessibility research by [Isla Schanuel](http://www.islaes.com), the purpose of this app was to evaluate the feasibility of edge detection techniques as an accessibility tool. While the screen size and form-factor of iOS devices is not conducive to real-world use, this was intended as a early prototype to test generating an accessible video stream from a non-stereoscopic video stream. As a result, the selection of filters is somewhat narrow in scope and is centered around providing meaningful ways of either enhancing a live video stream (by highlighting object edges) or transforming it entirely into a format that is easier for persons with reduced vision to see. 

The following filters have been implemented:

- Sobel operator using an RGB video stream as source
- Sobel operator using an Grayscale video stream source
- A blended Sobel operator that adds 50% of the grayscale result to the RGB result
- A composite that overlays the result of the Sobel operator on the grayscale video stream.
- A composite that overlays the result of the Sobel operator on the RGB video stream.
- Canny edge detector using a low threshold of 0.2
- A composite that overlays the Canny edge detection results on the grayscale video stream.

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
- One-finger taps cycles between filters.
- Two-finger taps toggles blurring on or off.
- One-finger long press locks or unlocks mode changing.