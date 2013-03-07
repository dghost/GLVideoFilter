// Sobel pre-pass for the Canny edge detectors

uniform sampler2D SamplerRGB;

uniform highp vec2 texelSize;
varying highp vec2 texCoordVarying;

mediump float sample(highp float dx, highp float dy)
{
    return texture2D(SamplerRGB, texCoordVarying + vec2(dx,dy)).a;
}
mediump vec3 sampleRGB(highp float dx, highp float dy)
{
    mediump vec3 rgb;
    rgb = texture2D(SamplerRGB, texCoordVarying + vec2(dx,dy)).rgb;
    return rgb;
}

const mediump float pi = 1.0 /  3.1415926535 ;
void main()
{
    highp float dX = texelSize.x;
    highp float dY = texelSize.y;
    
    mediump float m11 = sample(-dX,+dY);
    mediump float m12 = sample(0.0,+dY);
    mediump float m13 = sample(+dX,+dY);
    mediump float m21 = sample(-dX,0.0);
    mediump float m22 = sample(0.0,0.0);
    mediump float m23 = sample(+dX,0.0);
    mediump float m31 = sample(-dX,-dY);
    mediump float m32 = sample(0.0,-dY);
    mediump float m33 = sample(+dX,-dY);
    
  
    
    mediump float H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    mediump float V =     m11  - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;

    
    // atan returns -pi/2 to pi/2 - multiply by 1/pi and add 0.5
    mediump float theta = atan(H/V) * pi;
    theta += 0.5;

    mediump vec4 outColor = vec4(m22,abs(H*0.25),abs(V*0.25),theta);

    gl_FragColor = outColor;
    
    
}

