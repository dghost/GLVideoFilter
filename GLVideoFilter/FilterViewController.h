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
    NUM_UNIFORMS
};

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

enum
{
    LAYER_RGB_YUV,
    EFFECT1,
    EFFECT2,
    NUM_LAYERS
};

enum
{
    SOBEL,
    SOBEL_BW,
    SOBEL_BLEND,
    SOBEL_COMPOSITE,
    SOBEL_COMPOSITE_RGB,
    CANNY,
    CANNY_COMPOSITE,
    NUM_EFFECTS
};
typedef struct shaderType {
    GLuint handle;
    GLint attributes[NUM_ATTRIBUTES];
    GLint uniforms[NUM_UNIFORMS];
} shader_t;


@interface FilterViewController : GLKViewController <AVCaptureVideoDataOutputSampleBufferDelegate>  {
    
    shader_t _YUVtoRGB;
    shader_t _YUVtoRGBblur;
    shader_t _effect[NUM_EFFECTS];
    shader_t _passthrough;
    shader_t _cannySobel;
    
    bool _blur;
    
    int _mode;
    GLuint _positionVBO;
    GLuint _texcoordVBO;
    GLuint _indexVBO;
    
    GLuint _fboTextures[NUM_LAYERS];
    GLuint _fbo[NUM_LAYERS];
       
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    size_t _textureWidth;
    size_t _textureHeight;
    
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

