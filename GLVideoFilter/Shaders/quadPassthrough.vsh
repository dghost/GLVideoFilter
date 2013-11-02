// pass through vertex shader for full screen quad

attribute vec4 position;
attribute vec2 texCoord;

uniform vec2 posScale;

varying vec2 texCoordVarying;

void main()
{
    gl_Position = position * vec4(posScale,1.0,1.0);
    texCoordVarying = texCoord;
}
