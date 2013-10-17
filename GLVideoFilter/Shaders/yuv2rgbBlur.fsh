// Convert Y'UV output of camera into packed RGB/Y output

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;


varying highp vec2 texCoordVarying;

uniform highp vec2 texelSize;

uniform mediump mat3 rgbConvolution;
uniform mediump mat3 colorConvolution;
uniform mediump mat3 rgb2lms;
uniform mediump mat3 lms2rgb;

mediump vec3 sampleYUV(highp float dx, highp float dy)
{
    mediump vec3 yuv;
    yuv.x = texture2D(SamplerY, texCoordVarying + vec2(dx,dy)).r;
    yuv.yz = texture2D(SamplerUV, texCoordVarying + vec2(dx,dy)).rg - vec2(0.5, 0.5);
    return yuv;
}

const mediump float blur = 1.0 / 13.0;

void main()
{
    highp float dX = texelSize.x;
    highp float dY = texelSize.y;
    
    mediump vec3 m11 = sampleYUV(-dX,+dY);
    mediump vec3 m12 = sampleYUV(0.0,+dY);
    mediump vec3 m13 = sampleYUV(+dX,+dY);
    mediump vec3 m21 = sampleYUV(-dX,0.0);
    mediump vec3 m22 = sampleYUV(0.0,0.0);
    mediump vec3 m23 = sampleYUV(+dX,0.0);
    mediump vec3 m31 = sampleYUV(-dX,-dY);
    mediump vec3 m32 = sampleYUV(0.0,-dY);
    mediump vec3 m33 = sampleYUV(+dX,-dY);
    


    mediump vec3 accumulated = m11 + 2.0 * m12 + m13
                        + 2.0 * m21 + m22 + 2.0 * m23
                        + m31 + 2.0 * m32 + m33;
    
    accumulated *= blur;
    
    mediump vec3 rgb = clamp(rgbConvolution * accumulated,0.0,1.0);
    rgb = clamp(rgb2lms * rgb, 0.0,1.0);
    rgb = clamp(colorConvolution * rgb,0.0,1.0);
    rgb = clamp(lms2rgb * rgb,0.0,1.0);

    
    gl_FragColor = vec4(rgb,accumulated.x);
}

