#import "ShaderManager.h"
#import <GLKit/GLKit.h>

static bool _initialized = false;
static NSDictionary *_shaderList = nil;

@implementation ShaderManager

#pragma mark - Class Methods and Variables

+(BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load shader '%@'",[file lastPathComponent]);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader '%@' compile log:\n%s", [file lastPathComponent], log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

+(BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}


+(BOOL)loadShader: (shader_t *) program withVertex: (NSString *) vertexName withFragment: (NSString *) fragmentName
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program->handle = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexName ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader '%@'",vertexName);
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader '%@'",fragmentName);
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program->handle, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program->handle, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program->handle, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program->handle, ATTRIB_TEXCOORD, "texCoord");
#if defined(DEBUG)
    NSLog(@"Linking program with vertex shader '%@' and fragment shader '%@'...",vertexName,fragmentName);
#endif
    
    // Link program.
    if (![self linkProgram:program->handle]) {
        NSLog(@"Failed to link program: %d", program->handle);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program->handle) {
            glDeleteProgram(program->handle);
            program->handle = 0;
        }
        
        return NO;
    }
    
    // Get program locations.
    program->uniforms[UNIFORM_Y] = glGetUniformLocation(program->handle, "SamplerY");
    program->uniforms[UNIFORM_UV] = glGetUniformLocation(program->handle, "SamplerUV");
    program->uniforms[UNIFORM_RGB] = glGetUniformLocation(program->handle, "SamplerRGB");
    program->uniforms[UNIFORM_TEXELSIZE] = glGetUniformLocation(program->handle, "texelSize");
    program->uniforms[UNIFORM_RGBCONVOLUTION] = glGetUniformLocation(program->handle, "rgbConvolution");
    program->uniforms[UNIFORM_COLORCONVOLUTION] = glGetUniformLocation(program->handle, "colorConvolution");
    program->uniforms[UNIFORM_SCALE] = glGetUniformLocation(program->handle, "posScale");
    program->uniforms[UNIFORM_THRESHOLD] = glGetUniformLocation(program->handle, "threshold");
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(program->handle, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program->handle, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

+(void)loadShaders
{
    if (!_initialized)
    {
        NSString *plist = [[NSBundle mainBundle] pathForResource:@"Shaders" ofType:@"plist"];
        NSDictionary *shaders = [NSDictionary dictionaryWithContentsOfFile:plist];
        NSString *key;
        NSMutableDictionary *tempShaderList = [NSMutableDictionary dictionary];
        for (key in shaders) {
            NSDictionary *shader = [shaders objectForKey:key];
            NSString *vertex = [shader objectForKey:@"Vertex"];
            NSString *fragment = [shader objectForKey:@"Fragment"];
            shader_t temp;
            if ([self loadShader:&temp withVertex:vertex withFragment:fragment])
            {
                NSData *data = [NSData dataWithBytes:&temp length:sizeof(shader_t)];
                [tempShaderList setObject:data forKey:key];
            }
        }
        _shaderList = [NSDictionary dictionaryWithDictionary:tempShaderList];
        _initialized = true;
    }
}

+(BOOL) loadShaderNamed:(NSString *)name into:(shader_t *)shader
{
    if (!_initialized)
        return NO;
    NSData *temp = [_shaderList objectForKey:name];
    if (temp == nil)
        return NO;
    [temp getBytes:shader length:sizeof(shader_t)];
    return YES;
}

+(void)teardownShaders
{
 
    if (_initialized)
    {
        NSString *key;
        for (key in _shaderList)
        {
            shader_t shader;
            NSData *temp = [_shaderList objectForKey:key];
            [temp getBytes:&shader length:sizeof(shader_t)];
            if (shader.handle)
                glDeleteProgram(shader.handle);
        }
        _shaderList = nil;
        _initialized = false;
    }
}

#pragma mark - Instance Methods and Properties

@synthesize scale=_scale;
@synthesize texelSize=_texelSize;
@synthesize rgbConvolution=_rgbConvolution;
@synthesize colorConvolution=_colorConvolution;
@synthesize threshold=_threshold;

- (id)init {
    if (!_initialized)
        [ShaderManager loadShaders];
    self = [super init];
    if (self)
    {
        self.scale = GLKVector2Make(1, 1);
        self.texelSize = GLKVector2Make(1, 1);
        self.threshold = 0.0f;
        self.rgbConvolution = GLKMatrix3Identity;
        self.colorConvolution = GLKMatrix3Identity;
    }
    return self;
}

-(BOOL)setShader:(shader_t)program
{
    if (program.handle == 0)
        return NO;
    glUseProgram(program.handle);
    
    // bind appropriate uniforms
    if (program.uniforms[UNIFORM_Y] > -1)
    {
        glUniform1i(program.uniforms[UNIFORM_Y], 0);
        glUniform1i(program.uniforms[UNIFORM_UV], 1);
    } else {
        glUniform1i(program.uniforms[UNIFORM_RGB], 0);
    }
    if (program.uniforms[UNIFORM_TEXELSIZE] > -1)
        glUniform2fv(program.uniforms[UNIFORM_TEXELSIZE], 1, (GLfloat *) &_texelSize);
    if (program.uniforms[UNIFORM_RGBCONVOLUTION] > -1)
        glUniformMatrix3fv(program.uniforms[UNIFORM_RGBCONVOLUTION], 1, GL_FALSE, _rgbConvolution.m);
    if (program.uniforms[UNIFORM_COLORCONVOLUTION] > -1)
        glUniformMatrix3fv(program.uniforms[UNIFORM_COLORCONVOLUTION], 1, GL_FALSE, _colorConvolution.m);
    
    if (program.uniforms[UNIFORM_SCALE] > -1)
    {
        glUniform2fv(program.uniforms[UNIFORM_SCALE],1, (GLfloat *) &_scale);
    }
    if (program.uniforms[UNIFORM_THRESHOLD] > -1)
        glUniform1f(program.uniforms[UNIFORM_THRESHOLD], _threshold);
    return YES;
}

-(BOOL)setShaderNamed:(NSString *)name
{
    shader_t program;
    if ([ShaderManager loadShaderNamed:name into:&program])
        return [self setShader:program];
    else
        return NO;
}
@end
