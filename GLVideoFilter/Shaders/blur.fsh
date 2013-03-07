// 3x3 Gaussian blur pass

uniform sampler2D SamplerRGB;

uniform highp vec2 texelSize;
varying highp vec2 texCoordVarying;

mediump vec4 sampleRGBA(highp float dx, highp float dy)
{
        return texture2D(SamplerRGB, texCoordVarying + vec2(dx,dy));
}

const mediump float blur = 1.0 / 13.0;
void main()
{
    highp float dX = texelSize.x;
    highp float dY = texelSize.y;
    
    mediump vec4 m11 = sampleRGBA(-dX,+dY);
    mediump vec4 m12 = sampleRGBA(0.0,+dY);
    mediump vec4 m13 = sampleRGBA(+dX,+dY);
    mediump vec4 m21 = sampleRGBA(-dX,0.0);
    mediump vec4 m22 = sampleRGBA(0.0,0.0);
    mediump vec4 m23 = sampleRGBA(+dX,0.0);
    mediump vec4 m31 = sampleRGBA(-dX,-dY);
    mediump vec4 m32 = sampleRGBA(0.0,-dY);
    mediump vec4 m33 = sampleRGBA(+dX,-dY);
    
  


    mediump vec4 accumulated = m11 + 2.0 * m12 + m13
                        + 2.0 * m21 + m22 + 2.0 * m23
                        + m31 + 2.0 * m32 + m33;
    accumulated *= blur;

    gl_FragColor = accumulated;
    
    
}

