// Shader that inverts Y axis on source texture

attribute vec4 position;
attribute vec2 texCoord;

varying vec2 texCoordVarying;

void main()
{
    gl_Position = position;
    texCoordVarying.x = texCoord.x;
    texCoordVarying.y = 1.0 - texCoord.y;
   
}
