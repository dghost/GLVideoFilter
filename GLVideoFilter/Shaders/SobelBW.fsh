// Simple Sobel pass
// Operates on Illumination (graysacle) source

uniform sampler2D SamplerRGB;

uniform highp vec2 texelSize;
varying highp vec2 texCoordVarying;

mediump float sample(highp float dx, highp float dy)
{
    return texture2D(SamplerRGB, texCoordVarying + vec2(dx,dy)).a;
}

const mediump float pi2 = 1.0 /  3.1415926535 ;
void main()
{
    highp float dX = texelSize.x;
    highp float dY = texelSize.y;
    
    mediump float m11 = sample(-dX,+dY);
    mediump float m12 = sample(0.0,+dY);
    mediump float m13 = sample(+dX,+dY);
    mediump float m21 = sample(-dX,0.0);
    //mediump float m22 = sample(0.0,0.0);
    mediump float m23 = sample(+dX,0.0);
    mediump float m31 = sample(-dX,-dY);
    mediump float m32 = sample(0.0,-dY);
    mediump float m33 = sample(+dX,-dY);
    
  
    
    mediump float H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    mediump float V =     m11  - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    mediump float sobel = sqrt(H*H+V*V);
    
    
    // output result as gray
    mediump vec4 outColor = vec4(vec3(sobel),1.0);

    gl_FragColor = outColor;
    
    
}

