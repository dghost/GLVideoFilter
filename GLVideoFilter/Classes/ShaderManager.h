#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

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
    UNIFORM_LOWTHRESHOLD,
    UNIFORM_HIGHTHRESHOLD,
    NUM_UNIFORMS
};

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

typedef struct shaderType {
    GLuint handle;
    GLint attributes[NUM_ATTRIBUTES];
    GLint uniforms[NUM_UNIFORMS];
} shader_t;


@interface ShaderManager : NSObject

#pragma mark - Class Interface

+(void)loadShaders;
+(BOOL) loadShaderNamed:(NSString *)name into:(shader_t *)shader;
+(void)teardownShaders;

#pragma mark - Instance Interface

@property GLKVector2 scale;
@property GLKVector2 texelSize;
@property GLfloat lowThreshold;
@property GLfloat highThreshold;
@property GLKMatrix3 rgbConvolution;
@property GLKMatrix3 colorConvolution;

-(BOOL)setShader:(shader_t)program;
-(BOOL)setShaderNamed:(NSString *)name;

@end
