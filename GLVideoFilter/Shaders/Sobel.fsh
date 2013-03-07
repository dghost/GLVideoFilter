// Simple Sobel pass
// Operates on RGB source

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

void main()
{
    highp float dX = texelSize.x;
    highp float dY = texelSize.y;
    
    mediump vec3 m11 = sampleRGB(-dX,+dY);
    mediump vec3 m12 = sampleRGB(0.0,+dY);
    mediump vec3 m13 = sampleRGB(+dX,+dY);
    mediump vec3 m21 = sampleRGB(-dX,0.0);
    //mediump vec3 m22 = sample(0.0,0.0);
    mediump vec3 m23 = sampleRGB(+dX,0.0);
    mediump vec3 m31 = sampleRGB(-dX,-dY);
    mediump vec3 m32 = sampleRGB(0.0,-dY);
    mediump vec3 m33 = sampleRGB(+dX,-dY);
    
  
    
    mediump vec3 H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    
    mediump vec3 V =     m11  -     m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    
    mediump vec3 sobel = sqrt(H*H+V*V);
    gl_FragColor = vec4(sobel,1.0);
    
    
    /*
    mediump vec3 laplacian = -m11 -m12 -m13 -m21 + 8.0 *m22 - m23 - m31 - m32 -m33;
    gl_FragColor = vec4(laplacian,1.0);
     */
}

