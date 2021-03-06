#import <CoreVideo/CVOpenGLESTextureCache.h>
#import "FilterViewController.h"


#if __LP64__
static const bool _is64bit = true;
#else
static const bool _is64bit = false;
#endif


@implementation FilterViewController

typedef enum {
    FBO_PING,
    FBO_PONG,
    FBO_RGB,
    NUM_FBOS
} buff_t;

enum
{
    BLUR_NONE,
    BLUR_TWOPASS,
    NUM_BLURS
};

enum
{
    REGULAR,
    PROTANOPE,
    DEUTERANOPE,
    TRITANOPE,
    NUM_CONVOLUTIONS
};


GLKMatrix3 _rgbConvolution;
GLKMatrix3 _colorConvolution[NUM_CONVOLUTIONS];
NSArray *_colorConvolutionNames;

bool _newFrame;
GLuint _positionVBO;
GLuint _texcoordVBO;
GLuint _indexVBO;

GLuint _fboTextures[NUM_FBOS];
GLuint _fbo[NUM_FBOS];

CGFloat _screenWidth;
CGFloat _screenHeight;
GLsizei _textureWidth;
GLsizei _textureHeight;

EAGLContext *_context;

CVOpenGLESTextureRef _lumaTexture;
CVOpenGLESTextureRef _chromaTexture;

AVCaptureSession *_session;
CVOpenGLESTextureCacheRef _videoTextureCache;


// utility shaders
shader_t _blurX, _blurY;
shader_t _yuv2rgb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _filters = nil;
        _shaders = nil;
        _HUD = nil;
        _quad = nil;
        _lockedIcon = nil;
        _unlockedIcon = nil;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    defaults = [NSUbiquitousKeyValueStore defaultStore];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(externalUpdate:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:nil];
    [defaults synchronize];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.contentScaleFactor = [UIScreen mainScreen].scale;
    
    _screenHeight = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
    _screenWidth = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
    
    _lockedIcon = [UIImage imageNamed:@"Locked"];
    _unlockedIcon = [UIImage imageNamed:@"Unlocked"];
    
    [self generateColorConvolutions];
    [self setupGL];
    
    
    _filters = [[FilterManager alloc] init];
    
    [self setupAVCapture];
    _newFrame = false;

    if ([defaults objectForKey:@"blurMode"] != nil)
        [self setBlurMode:[defaults boolForKey:@"blurMode"]];
    else
        [self setBlurMode:YES];
    [self setLockMode:[defaults boolForKey:@"modeLock"]];
    [self setFilterByName:[defaults stringForKey:@"currentFilter"]];
    [self setColorConvolution:(NSInteger)[defaults doubleForKey:@"colorMode"]];
    [super viewWillAppear:animated];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hide:YES];
    [self tearDownAVCapture];
    [self tearDownGL];
    [self updateDefaults];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                  object:nil];
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    _lockedIcon = nil;
    _unlockedIcon = nil;
    
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    self.preferredFramesPerSecond = 60;
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Camera image orientation on screen is fixed
    // with respect to the physical camera orientation.
    
 //   [UIView setAnimationsEnabled:NO];
    /* Your original orientation booleans*/
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView setAnimationsEnabled:NO];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - AV Foundation methods

- (void)cleanUpTextures
{
    if (_lumaTexture)
    {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture)
    {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVReturn err;
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    GLsizei width = (GLsizei) CVPixelBufferGetWidth(pixelBuffer);
    GLsizei height = (GLsizei) CVPixelBufferGetHeight(pixelBuffer);
    
    if (!_videoTextureCache)
    {
        NSLog(@"No video texture cache");
        return;
    }
    
    if (_quad == nil)
    {
//        float textureAspect = height / width;
        float screenHeight =
            (_is64bit
             ? [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale
             : [UIScreen mainScreen].bounds.size.height );
        
        float scale = screenHeight / width;
        
        if (scale <= 1.0)
        {
            _textureWidth = ceil(width * scale);
            _textureHeight = ceil(height * scale);
        } else {
            _textureWidth = width;
            _textureHeight = height;
        }
        
        _quad = [[QuadModel alloc] init];
        
            // set up buffers only *after* you have a source video stream
        // This allows the texture sizes to be set to the same as the source video stream
        [self setupBuffers];
    }
    
    
    [self cleanUpTextures];
    
    // CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture
    // optimally from CVImageBufferRef.
    
    // Y-plane
    glActiveTexture(GL_TEXTURE0);
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RED_EXT,
                                                       width,
                                                       height,
                                                       GL_RED_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &_lumaTexture);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // UV-plane
    glActiveTexture(GL_TEXTURE1);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RG_EXT,
                                                       width/2,
                                                       height/2,
                                                       GL_RG_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       1,
                                                       &_chromaTexture);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    


    // bind the Y'UV to RGB/Y shader
    [_shaders setShader:_yuv2rgb];
    [_shaders setRgbConvolution:_rgbConvolution];
    [_shaders setColorConvolution:_colorConvolution[_colorMode]];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo[FBO_RGB]);
    glViewport(0, 0, _textureWidth,_textureHeight);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Render the camera frame into intermediate texture
    glDrawElements(GL_TRIANGLE_STRIP, [_quad getIndexCount], GL_UNSIGNED_SHORT, 0);
    _newFrame = true;
    
}

- (void)setupAVCapture
{
    NSString *sessionPreset;
    //-- Create CVOpenGLESTextureCacheRef for optimal CVImageBufferRef to GLES texture conversion.
#if COREVIDEO_USE_EAGLCONTEXT_CLASS_IN_API
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
#else
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)_context, NULL, &_videoTextureCache);
#endif
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return;
    }
    
    //-- Setup Capture Session.
    _session = [[AVCaptureSession alloc] init];
    [_session beginConfiguration];
    
    //-- Creata a video device and input from that Device.  Add the input to the capture session.
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(videoDevice == nil)
        assert(0);
    
    
    if (_is64bit)
    {
        AVCaptureDeviceFormat *bestFormat = nil;
        AVFrameRateRange *bestFrameRateRange = nil;
        for ( AVCaptureDeviceFormat *format in [videoDevice formats] ) {
            CMVideoDimensions temp = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
            // cap resolution to 720p
            if (temp.height <= 720)
            {
            //NSLog(@"Found camera resolution %ix%i",temp.width,temp.height);
                for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
                    //NSLog(@"Found frame rate range %f - %f",range.minFrameRate,range.maxFrameRate);
                    if ( range.maxFrameRate >= bestFrameRateRange.maxFrameRate ) {
                        
                        bestFormat = format;
                        bestFrameRateRange = range;
                    }
                }
            }
        }
        
        if ( bestFormat ) {
#if defined(DEBUG)
            CMVideoDimensions temp = CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription);
            NSLog(@"Setting camera resolution %ix%i@%ffps",temp.width,temp.height,bestFrameRateRange.maxFrameRate);
#endif
            if ( [videoDevice lockForConfiguration:NULL] == YES ) {
                videoDevice.activeFormat = bestFormat;
                videoDevice.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
                videoDevice.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
                [videoDevice unlockForConfiguration];
            }
        }
        self.preferredFramesPerSecond = bestFrameRateRange.maxFrameRate;       
        sessionPreset = AVCaptureSessionPresetInputPriority;
        
        //NSLog(@"64bit executable");
    } else {
        
        if ([videoDevice respondsToSelector:@selector(activeVideoMinFrameDuration)])
        {
            int maxHeight = 0;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                // Choosing bigger preset for bigger screen.
                if (self.view.contentScaleFactor == 2.0)
                    maxHeight = 720;
                else
                    maxHeight = 480;
            }
            else
            {
                if (_screenWidth > 480)
                    maxHeight = 540;
                // use a 640x480 video stream for iPhones
                else
                    maxHeight = 480;
            }
            AVCaptureDeviceFormat *bestFormat = nil;
            AVFrameRateRange *bestFrameRateRange = nil;
            for ( AVCaptureDeviceFormat *format in [videoDevice formats] ) {
                CMVideoDimensions temp = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
                if (temp.height <= maxHeight)
                {
                    //NSLog(@"Found camera resolution %ix%i",temp.width,temp.height);

                    for ( AVFrameRateRange *range in format.videoSupportedFrameRateRanges ) {
                        //NSLog(@"Found frame rate range %f - %f",range.minFrameRate,range.maxFrameRate);
                        if ( range.maxFrameRate >= bestFrameRateRange.maxFrameRate ) {
                            
                            bestFormat = format;
                            bestFrameRateRange = range;
                        }
                    }
                }
            }
            
            if ( bestFormat ) {
#if defined(DEBUG)
                CMVideoDimensions temp = CMVideoFormatDescriptionGetDimensions(bestFormat.formatDescription);
                NSLog(@"Setting camera resolution %ix%i@%ffps",temp.width,temp.height,bestFrameRateRange.maxFrameRate);
#endif
                if ( [videoDevice lockForConfiguration:NULL] == YES ) {
                    videoDevice.activeFormat = bestFormat;
                    videoDevice.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration;
                    videoDevice.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration;
                    [videoDevice unlockForConfiguration];
                }
            }
            self.preferredFramesPerSecond = bestFrameRateRange.maxFrameRate;
            sessionPreset = AVCaptureSessionPresetInputPriority;
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                // Choosing bigger preset for bigger screen.
                if (self.view.contentScaleFactor == 2.0)
                    sessionPreset = AVCaptureSessionPreset1280x720;
                else
                    sessionPreset = AVCaptureSessionPreset640x480;
            }
            else
            {
                // use a 640x480 video stream for iPhones
                
                sessionPreset = AVCaptureSessionPreset640x480;
            }
        }
        //NSLog(@"32bit executable");
    }
    
    //-- Add the device to the session.
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(error)
        assert(0);
    
    
    //-- Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    
    //-- Set to YUV420.
    [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)}]; // Necessary for manual preview
    
    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    //-- Set preset session size.
    [_session setSessionPreset:sessionPreset];
    
    [_session addInput:input];
    
    [_session addOutput:dataOutput];
    [_session commitConfiguration];
    
    [_session startRunning];
}

- (void)tearDownAVCapture
{
    [self cleanUpTextures];
    
    CFRelease(_videoTextureCache);
}

#pragma mark - OpenGL methods

- (void)setupGL
{
    [EAGLContext setCurrentContext:_context];
    
    _shaders = [[ShaderManager alloc] init];
    
    [ShaderManager loadShaderNamed:@"blur-x" into:&_blurX];
    [ShaderManager loadShaderNamed:@"blur-y" into:&_blurY];
    [ShaderManager loadShaderNamed:@"yuv-rgb" into:&_yuv2rgb];

}


- (void)setupBuffers
{
    // create frame vertex buffers
    glGenBuffers(1, &_indexVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, [_quad getIndexSize], [_quad getIndices], GL_STATIC_DRAW);
    
    glGenBuffers(1, &_positionVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _positionVBO);
    glBufferData(GL_ARRAY_BUFFER, [_quad getVertexSize], [_quad getVertices], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), 0);
    
    glGenBuffers(1, &_texcoordVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _texcoordVBO);
    glBufferData(GL_ARRAY_BUFFER, [_quad getVertexSize], [_quad getTexCoords], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), 0);
    
    // genereate textures and FBO's
    glGenTextures(NUM_FBOS, &_fboTextures[0]);
    glGenFramebuffers(NUM_FBOS, &_fbo[0]);
    
    for (int i = 0; i < NUM_FBOS; i++)
    {
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo[i]);
        glBindTexture(GL_TEXTURE_2D, _fboTextures[i]);
        
        glTexImage2D( GL_TEXTURE_2D,
                     0,
                     GL_RGBA,
                     _textureWidth, _textureHeight,
                     0,
                     GL_RGBA,
                     GL_UNSIGNED_BYTE,
                     NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _fboTextures[i], 0);
        
        GLenum status;
        status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        switch(status) {
            case GL_FRAMEBUFFER_COMPLETE:
                //NSLog(@"fbo complete");
                break;
                
            case GL_FRAMEBUFFER_UNSUPPORTED:
                NSLog(@"fbo unsupported");
                break;
                
            default:
                /* programming error; will fail on all hardware */
                NSLog(@"Framebuffer Error");
                break;
        }
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLfloat xScale = 1.0;
    GLfloat yScale = (_screenWidth/ _screenHeight) * ((GLfloat) _textureHeight / (GLfloat) _textureWidth);
    float orient = (self.interfaceOrientation == UIDeviceOrientationLandscapeRight) ? -1.0 : 1.0;
    [_shaders setScale:GLKVector2Make(xScale * orient, yScale * orient)];
    [_shaders setTexelSize:GLKVector2Divide(GLKVector2Make(1.0, 1.0), GLKVector2Make(_textureWidth, _textureHeight))];
#if defined(DEBUG)
    NSLog(@"screen: %fx%f text: %ix%i scale: %f",_screenWidth,_screenHeight,_textureWidth,_textureHeight,yScale);
#endif
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:_context];
    
    glDeleteBuffers(1, &_positionVBO);
    glDeleteBuffers(1, &_texcoordVBO);
    glDeleteBuffers(1, &_indexVBO);
    
    _filters = nil;
    _shaders = nil;
    [FilterManager teardownFilters];
    [ShaderManager teardownShaders];

    glDeleteTextures(NUM_FBOS, &_fboTextures[0]);
    glDeleteFramebuffers(NUM_FBOS, &_fbo[0]);
}


// Render from one texture into another FBO
- (BOOL)drawIntoFBO: (int) fboNum WithShaderNamed:(NSString *) name sourceTexture:(int)texNum
{
    if (fboNum >= 0 && fboNum < NUM_FBOS && texNum >= 0 && texNum < NUM_FBOS)
    {
        if (![_shaders setShaderNamed:name])
            return NO;
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo[fboNum]);
        glViewport(0, 0, _textureWidth, _textureHeight);

        
        glBindTexture(GL_TEXTURE_2D, _fboTextures[texNum]);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glDrawElements(GL_TRIANGLE_STRIP, [_quad getIndexCount], GL_UNSIGNED_SHORT, 0);
        
        return YES;
    }
    return NO;
}

// Render from one texture into another FBO
- (BOOL)drawIntoFBO: (int) fboNum WithShader:(shader_t) shader sourceTexture:(int)texNum
{
    if (fboNum >= 0 && fboNum < NUM_FBOS && texNum >= 0 && texNum < NUM_FBOS)
    {
        if (![_shaders setShader:shader])
            return NO;
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo[fboNum]);
        glViewport(0, 0, _textureWidth, _textureHeight);
        
        glBindTexture(GL_TEXTURE_2D, _fboTextures[texNum]);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glDrawElements(GL_TRIANGLE_STRIP, [_quad getIndexCount], GL_UNSIGNED_SHORT, 0);
        
        return YES;
    }
    return NO;
}

// Render from one texture into the view
- (BOOL)drawIntoView:(GLKView *) view WithShaderNamed:(NSString*) name sourceTexture:(int)texNum
{
    if (view != nil)
    {
        if (![_shaders setShaderNamed:name])
            return NO;
        [view bindDrawable];
        glViewport(0, 0, _screenWidth, _screenHeight);
        glBindTexture(GL_TEXTURE_2D, _fboTextures[texNum]);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glDrawElements(GL_TRIANGLE_STRIP, [_quad getIndexCount], GL_UNSIGNED_SHORT, 0);
        
        return YES;
    }
    return NO;
}

- (void)filterFrame:(GLuint) source intoView:(GLKView *) dest
{
    GLuint currentSource = source;
    NSArray *currentFilter = [_filters getCurrentFilter];
    GLuint currentDest = FBO_PING;
    NSInteger numFilters = [currentFilter count];
    
    if (_blurMode)
    {
        if ([self drawIntoFBO:FBO_PONG WithShader:_blurX sourceTexture:currentSource] &&
            [self drawIntoFBO:currentDest WithShader:_blurY sourceTexture:FBO_PONG])
        {
            currentSource = currentDest;
            currentDest = (currentDest == FBO_PING) ? FBO_PONG : FBO_PING;
        }
    }
    
    for (NSInteger i = 0 ; i < (numFilters - 1); i++)
    {
        NSString *shaderName = [currentFilter objectAtIndex:i] ;
        if ([self drawIntoFBO:currentDest WithShaderNamed:shaderName sourceTexture:currentSource])
        {
            currentSource = currentDest;
            currentDest = (currentDest == FBO_PING) ? FBO_PONG : FBO_PING;
        }
    }
    
    if (numFilters > 0)
    {
        NSString *shaderName = [currentFilter objectAtIndex:(numFilters - 1)];
        [self drawIntoView:dest WithShaderNamed:shaderName sourceTexture:currentSource];
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, 0);
    glActiveTexture(GL_TEXTURE0);

    if (_newFrame)
    {
        GLfloat xScale = 1.0;
        GLfloat yScale = (_screenWidth/ _screenHeight) * ((GLfloat) _textureHeight / (GLfloat) _textureWidth);
        float orient = (self.interfaceOrientation == UIDeviceOrientationLandscapeRight) ? -1.0 : 1.0;
        [_shaders setScale:GLKVector2Make(xScale * orient, yScale * orient)];
        [_shaders setTexelSize:GLKVector2Divide(GLKVector2Make(1.0, 1.0), GLKVector2Make(_textureWidth, _textureHeight))];
        [_shaders setLowThreshold:0.1f];
        [_shaders setHighThreshold:0.25f];
        
        [self filterFrame:FBO_RGB intoView:view];
        _newFrame = false;
    }
}

#pragma mark - Overlay updating methods

-(void)updateOverlayWithText:(NSString*)text
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
	
	// Configure for text only and offset down
	_HUD.mode = MBProgressHUDModeText;
	_HUD.labelText = text;
	_HUD.margin = 10.f;
	_HUD.delegate = self;
	_HUD.removeFromSuperViewOnHide = YES;
    
	[_HUD show:YES];
	[_HUD hide:YES afterDelay:2];
}

-(void)updateOverlayLock {
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
	
    NSString *text = (_modeLock ? @"Locked" : @"Unlocked");
    UIImage *image = (_modeLock ? _lockedIcon : _unlockedIcon);
    
    // configure to use the custom view with image
    _HUD.customView = [[UIImageView alloc] initWithImage:image];
	_HUD.mode = MBProgressHUDModeCustomView;
	_HUD.labelText = text;
	_HUD.margin = 10.f;
	_HUD.delegate = self;
	_HUD.removeFromSuperViewOnHide = YES;
	
	[_HUD show:YES];
	[_HUD hide:YES afterDelay:2];
}

-(void)updateOverlayBlur {
    // update the overlay
     NSString *blur;
    if (_blurMode) {
        blur = @"Blur Enabled";
    } else {
        blur = @"Blur Disabled";
    }
    
    [self updateOverlayWithText:blur];
}

-(void)setBlurMode:(BOOL)newMode
{
    if (_blurMode != newMode)
    {
        _blurMode = newMode;
        [self updateOverlayBlur];
        [self saveDefaults];
    }
}

-(void)setLockMode:(BOOL)newMode
{
    if (_modeLock != newMode)
    {
        _modeLock = newMode;
        [self updateOverlayLock];
        [self saveDefaults];
    }
    
}

-(void)setFilterByName:(NSString *)name
{
    if (![name isEqualToString:[_filters getCurrentName]])
    {
        [_filters setFilterByName:name];
        NSString *filterName = [_filters getCurrentName];
        [self updateOverlayWithText:filterName];
        [self saveDefaults];
    }
}

-(void)setColorConvolution:(NSInteger)mode
{
    if (_colorMode != mode)
    {
        if (mode >= NUM_CONVOLUTIONS)
            mode = 0;
        else if (mode < 0)
            mode = NUM_CONVOLUTIONS - 1;

        _colorMode = mode;
        
        [self updateOverlayWithText:[_colorConvolutionNames objectAtIndex:_colorMode]];
        [self saveDefaults];
    }
}

-(void)setNextFilter
{
    [_filters nextFilter];
    NSString *filterName = [_filters getCurrentName];
    [self updateOverlayWithText:filterName];
    [self saveDefaults];
}

-(void)setPrevFilter
{
    [_filters prevFilter];
    NSString *filterName = [_filters getCurrentName];
    [self updateOverlayWithText:filterName];
    [self saveDefaults];
}

-(void)generateColorConvolutions
{
    _rgbConvolution = GLKMatrix3Make(  1       ,1          ,      1,
                                     0       ,-.18732    , 1.8556,
                                     1.57481 , -.46813   ,      0);
    
    _colorConvolution[REGULAR] = GLKMatrix3Identity;
    _colorConvolution[PROTANOPE] = GLKMatrix3MakeAndTranspose(0.20,  0.99, -0.19,
                                                             0.16,  0.79,  0.04,
                                                             0.01, -0.01,  1.00);
    
    _colorConvolution[DEUTERANOPE] = GLKMatrix3MakeAndTranspose(0.43,  0.72, -0.15,
                                                               0.34,  0.57,  0.09,
                                                               -0.02,  0.03,  1.00);
    
    _colorConvolution[TRITANOPE] = GLKMatrix3MakeAndTranspose(0.97,  0.11, -0.08,
                                                             0.02,  0.82,  0.16,
                                                            -0.06,  0.88,  0.18);
    
    _colorConvolutionNames = @[ @"Regular colorspace", @"Simulated Protanope", @"Simulated Deuteranope", @"Simulated Tritanope"];
}

#pragma mark - Touch handling methods

- (IBAction)tapGestureRecgonizer:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (sender.numberOfTapsRequired == 1)
            [self setLockMode:!_modeLock];
        else if (sender.numberOfTapsRequired == 2 && !_modeLock)
            [self setBlurMode:!_blurMode];        
    }
}

- (IBAction)swipeGestureRecognizer:(UISwipeGestureRecognizer *)sender {
    if (!_modeLock && sender.state == UIGestureRecognizerStateRecognized)
    {
        if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
        {
            [self setNextFilter];
        } else if (sender.direction == UISwipeGestureRecognizerDirectionRight)
        {
            [self setPrevFilter];
        }
        
        if (sender.direction == UISwipeGestureRecognizerDirectionUp)
        {
            [self setColorConvolution:_colorMode + 1];
//            [self setBlurMode:!_blurMode];
        } else if (sender.direction == UISwipeGestureRecognizerDirectionDown)
        {
            [self setColorConvolution:_colorMode - 1];
  
//            [self setBlurMode:!_blurMode];
        }
    }
}

-(void) updateDefaults
{
    NSLog(@"Updating defaults...");
    [defaults setDouble:(double)_colorMode forKey:@"colorMode"];
    NSString *filterName = [_filters getCurrentName];
    [defaults setString:filterName forKey:@"currentFilter"];
    [defaults setBool:_modeLock forKey:@"modeLock"];
    [defaults setBool:_blurMode forKey:@"blurMode"];
    [defaults synchronize];
}

-(void) saveDefaults
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateDefaults) object:nil];
    [self performSelector:@selector(updateDefaults) withObject:nil afterDelay:(NSTimeInterval) 2.0];
}

-(void) externalUpdate:(NSNotification*) notificationObject {
    
    
    // prevent NSUserDefaultsDidChangeNotification from being posted while we update from iCloud
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];
    
    NSArray *keys = [[notificationObject userInfo] objectForKey:@"NSUbiquitousKeyValueStoreChangedKeysKey"];
    for (NSString *key in keys)
    {
#if defined(DEBUG)
        NSLog(@"Key '%@' changed",key);
#endif
        if ([key isEqualToString:@"modeLock"])
        {
            [self setLockMode:[defaults boolForKey:key]];
        } else if ([key isEqualToString:@"blurMode"])
        {
            [self setBlurMode:[defaults boolForKey:key]];
        } else if ([key isEqualToString:@"currentFilter"])
        {
            [self setFilterByName:[defaults stringForKey:key]];
        } else if ([key isEqualToString:@"colorMode"])
        {
            [self setColorConvolution:(NSInteger)[defaults doubleForKey:key]];
        }
    }
    // enable NSUserDefaultsDidChangeNotification notifications again
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(externalUpdate:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}


@end
