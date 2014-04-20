// quadKernel.vsh
//
// Pre-computes the texture coordinates for the 3x3 kernel
//   and passes them as varyings to the fragment shaders
//

attribute vec4 position;
attribute vec2 texCoord;

uniform vec2 texelSize;

varying vec2 tc[5];

void main()
{
    float offset[3];
    offset[0] = 0.0;
    offset[1] = 1.3846153846;
    offset[2] = 3.2307692308;
    tc[2] = texCoord;
    for (int i = 1 ; i < 3; i++)
    {
        vec2 tcOffset = vec2(0.0,offset[i]) * texelSize;
        tc[2 + i] = texCoord + tcOffset;
        tc[2 - i] = texCoord - tcOffset;
    }
    gl_Position = position;
}
