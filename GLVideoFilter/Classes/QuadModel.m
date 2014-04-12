#import "QuadModel.h"

@interface QuadModel () {
    
    unsigned int numVerts;
    unsigned int numIndicies;
    
    // data passed to GL
    GLKVector3 *quadVertices;
    GLKVector2 *quadTexCoords;
    GLushort *quadIndicies;
}

@end

@implementation QuadModel


- (void)initMesh
{
    numVerts = 4;
    numIndicies = 4;
    quadVertices = (GLKVector3 *) malloc(4 * sizeof(GLKVector3));
    quadTexCoords = (GLKVector2 *) malloc(4 * sizeof(GLKVector2));
    quadIndicies = (GLushort *) malloc(4 * sizeof(GLushort));
    
    quadVertices[0] = GLKVector3Make(-1, -1, 0);
    quadVertices[1] = GLKVector3Make(-1, 1, 0);
    quadVertices[2] = GLKVector3Make(1, -1, 0);
    quadVertices[3] = GLKVector3Make(1, 1, 0);
    
    quadTexCoords[0] = GLKVector2Make(0, 0);
    quadTexCoords[1] = GLKVector2Make(0, 1);
    quadTexCoords[2] = GLKVector2Make(1, 0);
    quadTexCoords[3] = GLKVector2Make(1, 1);

    quadIndicies[0] = 0;
    quadIndicies[1] = 1;
    quadIndicies[2] = 2;
    quadIndicies[3] = 3;
    
}

- (GLfloat *)getVertices
{
    return (GLfloat *) quadVertices;
}

- (GLfloat *)getTexCoords
{
    return (GLfloat *) quadTexCoords;
}

- (GLushort *)getIndices
{
    return quadIndicies;
}

- (unsigned int)getVertexSize
{
    return numVerts * sizeof(GLKVector3);
}

- (unsigned int)getIndexSize
{
    return numIndicies*sizeof(GLushort);
}

- (unsigned int)getIndexCount
{
    return numIndicies;
}

- (void)freeBuffers
{
    free(quadVertices);
    free(quadIndicies);
    free(quadTexCoords);
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self initMesh];
    }
    
    return self;
}


- (void)dealloc
{
    [self freeBuffers];
}

@end
