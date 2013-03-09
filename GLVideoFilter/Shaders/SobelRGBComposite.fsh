// Composite Sobel pass
// Shows the scene in grayscale with Sobel results overlaid in red

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
    
    mediump float m11 = sample(-dX,+dY);
    mediump float m12 = sample(0.0,+dY);
    mediump float m13 = sample(+dX,+dY);
    mediump float m21 = sample(-dX,0.0);
    mediump float m22 = sample(0.0,0.0);
    mediump float m23 = sample(+dX,0.0);
    mediump float m31 = sample(-dX,-dY);
    mediump float m32 = sample(0.0,-dY);
    mediump float m33 = sample(+dX,-dY);
    
    mediump vec3 inColor = sampleRGB(0.0,0.0);
  
    // calculate sobel values
    mediump float H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    mediump float V =     m11  - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    mediump float sobel = sqrt(H*H+V*V);

    // set base value to be grayscale value at that pixel
    mediump vec4 outColor = vec4(inColor,1.0);

    // add sobel result to red channel
    outColor.r += sobel;

    gl_FragColor = outColor;
    
    
}

