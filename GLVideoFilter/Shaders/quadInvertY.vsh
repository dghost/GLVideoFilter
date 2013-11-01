// Shader that inverts Y axis on source texture

attribute vec4 position;
attribute vec2 texCoord;

varying vec2 texCoordVarying;

void main()
{
    texCoordVarying = vec2(texCoord.x, 1.0-texCoord.y);
    gl_Position = position;
}
