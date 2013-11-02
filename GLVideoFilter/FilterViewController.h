#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QuadModel.h"

// Uniform index.
enum
{
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_RGB,
    UNIFORM_TEXELSIZE,
    UNIFORM_RGBCONVOLUTION,
    UNIFORM_COLORCONVOLUTION,
    UNIFORM_SCALE,
    NUM_UNIFORMS
};

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};


typedef enum {
    FBO_PING,
    FBO_PONG,
    FBO_RGB,
    FBO_FINAL,
    NUM_FBOS
} buff_t;

enum
{
    FILTER_NONE,
    SOBEL,
    SOBEL_BW,
    SOBEL_BLEND,
    SOBEL_COMPOSITE,
    SOBEL_COMPOSITE_RGB,
    CANNY,
    CANNY_COMPOSITE,
    NUM_FILTERS
};

enum
{
    BLUR_NONE,
    BLUR_SINGLEPASS,
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

typedef struct shaderType {
    GLuint handle;
    GLint attributes[NUM_ATTRIBUTES];
    GLint uniforms[NUM_UNIFORMS];
} shader_t;


@interface FilterViewController : GLKViewController <AVCaptureVideoDataOutputSampleBufferDelegate>  {
    
    shader_t _YUVtoRGB;
    shader_t _blurSinglePass;
    shader_t _blurTwoPass[2];
    
    shader_t _effect[NUM_FILTERS];
    shader_t _passthrough;
    shader_t _cannySobel;
    
    GLKMatrix3 _rgbConvolution;
    GLKMatrix3 _colorConvolution;
    GLKMatrix3 _finalConvolution;

    GLKMatrix3 _cvdConvolutions[NUM_CONVOLUTIONS];
    GLKMatrix3 _lms2rgb;
    GLKMatrix3 _rgb2lms;
    GLKMatrix3 _error;
    
    unsigned int _blurMode;
    unsigned int _filterMode;
    
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
    
    GLfloat _xScale;
    GLfloat _yScale;
    
    EAGLContext *_context;
    QuadModel *_quad;
    
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    
    NSString *_sessionPreset;
    
    AVCaptureSession *_session;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    GLKVector2 _texelSize;
}


@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
- (IBAction)tapGestureRecgonizer:(UITapGestureRecognizer *)sender;
- (void)cleanUpTextures;
- (void)setupAVCapture;
- (void)tearDownAVCapture;

- (void)setupBuffers;
- (void)setupGL;
- (void)tearDownGL;
- (BOOL)drawIntoFBO: (int) fboNum WithShader:(shader_t) shader sourceTexture:(int)texNum;
- (BOOL)loadShader: (shader_t *) program withVertex: (NSString *) vertexName withFragment: (NSString *) fragmentName;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (void)setProgram:(shader_t) program;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end

