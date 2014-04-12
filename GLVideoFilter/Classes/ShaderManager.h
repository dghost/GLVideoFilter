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
    UNIFORM_THRESHOLD,
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
+(void)loadShaders;
+(BOOL) loadShaderNamed:(NSString *)name into:(shader_t *)shader;
+(void)teardownShaders;

@property GLKVector2 scale;
@property GLKVector2 texelSize;
@property GLfloat threshold;
@property GLKMatrix3 rgbConvolution;
@property GLKMatrix3 colorConvolution;

-(void)setShader:(shader_t)program;
-(void)setShaderNamed:(NSString *)name;

@end
