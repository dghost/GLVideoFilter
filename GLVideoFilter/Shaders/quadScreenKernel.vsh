// pass through vertex shader for full screen quad

attribute vec4 position;
attribute vec2 texCoord;

uniform vec2 texelSize;
uniform vec2 posScale;

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
    tc11 = texCoord + vec2(-texelSize.x,+texelSize.y);
    tc12 = texCoord + vec2(0.0,+texelSize.y);
    tc13 = texCoord + vec2(+texelSize.x,+texelSize.y);
    tc21 = texCoord + vec2(-texelSize.x,0.0);
    tc22 = texCoord;
    tc23 = texCoord + vec2(+texelSize.x,0.0);
    tc31 = texCoord + vec2(-texelSize.x,-texelSize.y);
    tc32 = texCoord + vec2(0.0,-texelSize.y);
    tc33 = texCoord + vec2(+texelSize.x,-texelSize.y);
    gl_Position = position * vec4(posScale,1.0,1.0);
}
