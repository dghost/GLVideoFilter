// Shader that inverts Y axis on source texture

attribute vec4 position;
attribute vec2 texCoord;

//varying vec2 texCoordVarying;
uniform vec2 texelSize;

varying vec2 tc11;
varying vec2 tc12;
varying vec2 tc13;
varying vec2 tc21;
varying vec2 tc22;
varying vec2 tc23;
varying vec2 tc31;
varying vec2 tc32;
varying vec2 tc33;

void main()
{
    vec2 texCoordVarying = vec2(texCoord.x, 1.0-texCoord.y);
    
//  texCoordVarying.x = texCoord.x;
//  texCoordVarying.y = 1.0 - texCoord.y;
    tc11 = texCoordVarying + vec2(-texelSize.x,+texelSize.y);
    tc12 = texCoordVarying + vec2(0.0,+texelSize.y);
    tc13 = texCoordVarying + vec2(+texelSize.x,+texelSize.y);
    tc21 = texCoordVarying + vec2(-texelSize.x,0.0);
    tc22 = texCoordVarying;
    tc23 = texCoordVarying + vec2(+texelSize.x,0.0);
    tc31 = texCoordVarying + vec2(-texelSize.x,-texelSize.y);
    tc32 = texCoordVarying + vec2(0.0,-texelSize.y);
    tc33 = texCoordVarying + vec2(+texelSize.x,-texelSize.y);
    gl_Position = position;

   
}
