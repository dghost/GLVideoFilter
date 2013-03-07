// Blended Sobel pass
// Adds 50% of BW Sobel result to the RGB result
// Results in image that is slightly brighter than pure RGB

uniform sampler2D SamplerRGB;

uniform highp vec2 texelSize;
varying highp vec2 texCoordVarying;

mediump vec4 sampleRGBA(highp float dx, highp float dy)
{
    return texture2D(SamplerRGB, texCoordVarying + vec2(dx,dy));
}

const mediump float pi2 = 1.0 /  3.1415926535 ;
void main()
{
    highp float dX = texelSize.x;
    highp float dY = texelSize.y;
    
    mediump vec4 m11 = sampleRGBA(-dX,+dY);
    mediump vec4 m12 = sampleRGBA(0.0,+dY);
    mediump vec4 m13 = sampleRGBA(+dX,+dY);
    mediump vec4 m21 = sampleRGBA(-dX,0.0);
    //mediump float m22 = sample(0.0,0.0);
    mediump vec4 m23 = sampleRGBA(+dX,0.0);
    mediump vec4 m31 = sampleRGBA(-dX,-dY);
    mediump vec4 m32 = sampleRGBA(0.0,-dY);
    mediump vec4 m33 = sampleRGBA(+dX,-dY);
    
    // calculate the sobel value for the RGB and Grayscale values
    mediump vec4 H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    mediump vec4 V =     m11  - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    mediump vec4 sobel = sqrt(H*H+V*V);
    
    // add 50% of the grayscale sobel to the RGB sobel.
    mediump vec3 rgb = sobel.rgb + vec3(sobel.a * 0.5 );
    mediump vec4 outColor = vec4(rgb,1.0);

    gl_FragColor = outColor;
    
    
}

