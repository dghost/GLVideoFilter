###GLVideoFilter
This project was based on the [GLCameraRipple demo](http://developer.apple.com/library/ios/#samplecode/GLCameraRipple/Introduction/Intro.html), but has been updated to support iOS 6.0 and 7.0 features.

Note: This only runs on actual devices, and will not run in the simulator.

####Description
Real-time image processing on a live video stream on iOS devices.

Incorporating accessibility research by [Isla S.](http://www.islaes.com), the purpose of this app was to evaluate the feasibility of edge detection techniques as an accessibility tool. While the screen size and form-factor of iOS devices is not conducive to real-world use, this was intended as a early prototype to test generating an accessible video stream from a non-stereoscopic video stream. As a result, the selection of filters is somewhat narrow in scope and is centered around providing meaningful ways of either enhancing a live video stream (by highlighting object edges) or transforming it entirely into a format that is easier for persons with reduced vision to see. 

The following filters have been implemented:

- Sobel operator using an RGB video stream as source
- Sobel operator using an Grayscale video stream source
- A blended Sobel operator that adds 50% of the grayscale result to the RGB result
- A composite that overlays the result of the Sobel operator on the grayscale video stream.
- A composite that overlays the result of the Sobel operator on the RGB video stream.
- Canny edge detector using a low threshold of 0.15
- A composite that overlays the Canny edge detection results on the grayscale video stream.

Additionally, an optional blur pre-pass can be enabled for any video filter.

The program works by performing the following steps:

- In the `captureOutput` callback, the Y'UV results of the latest camera frame are converted into RGB and the RGB/Y information rendered into a texture.
    - If blurring is enabled, a gaussian blur is applied in Y'UV space prior to the conversion to RGB.
- If Canny or Canny Composite filters are enabled, a Sobel pre-pass is run and the results are cached along with the original Y value.
- The selected filter is applied and the result is cached.
- When a redraw is triggered, the last processed frame is rendered to the screen. 

Due to the number of render passes executed, the intermediate textures are all the same size as the source video stream. On an iPad this is 1280x720, but on an iPhone this is 640x480. This can be changed easily in code but will affect performance.

####Usage
A one-finger tap toggles between filters.
A two-finger tap toggles blurring on/off.
