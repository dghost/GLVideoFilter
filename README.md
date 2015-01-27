##3Note: This repository is now deprecated. 

Please see the [AccessibleVideo](https://github.com/dghost/AccessibleVideo) repository for a modern replacement implemented in Swift/Metal.

###GLVideoFilter v2.0 
Real-time image processing on a live video stream on iOS devices. This project was based on the [GLCameraRipple demo](http://developer.apple.com/library/ios/#samplecode/GLCameraRipple/Introduction/Intro.html), but has been updated to require iOS 6 and take advantage of iOS 7 features when available.

Note: This only runs on actual devices, and will not run in the simulator.

####Description

Built to support accessibility research by [Isla Schanuel](http://www.islaes.com), the purpose of this app was to evaluate the feasibility of edge detection techniques as an accessibility tool. While the screen size and form-factor of iOS devices is not conducive to real-world use, this was intended as a early prototype to test generating an accessible video stream from a non-stereoscopic video stream. As a result, the selection of filters is somewhat narrow in scope and is centered around providing meaningful ways of either enhancing a live video stream (by highlighting object edges) or transforming it entirely into a format that is easier for persons with reduced vision to see. 

####Features

- Flexible filter pipeline that supports arbitrary multi-pass filters
- On-demand frame processing allows camera to update asychronously from the screen
- Supports 60fps cameras under iOS7
- Compatible with ARM64 devices
- Support for iPhones, iPod Touches, and iPads

#####Filters

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

####Usage
- One-finger left/right swipes cycle between filters.
- One-finger up/down swipes cycle between blur modes.
- One-finger tap locks or unlocks mode changing.

#####Thanks go out to...
- [Jonathan George](http://jdg.net), for making [MBProgressHUD](https://github.com/jdg/MBProgressHUD).
- [Gary Gehiere](http://blog.iamgary.com/helloworld/), for creating the [Lock/Unlock icons](http://www.pixelpressicons.com/?p=108) and licsensing them as [Creative Commons CA 2.5](http://creativecommons.org/licenses/by/2.5/ca/).