#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>

@interface QuadModel : NSObject

- (GLfloat *)getVertices;
- (GLfloat *)getTexCoords;
- (GLushort *)getIndices;
- (unsigned int)getVertexSize;
- (unsigned int)getIndexSize;
- (unsigned int)getIndexCount;

- (id)init;

@end
