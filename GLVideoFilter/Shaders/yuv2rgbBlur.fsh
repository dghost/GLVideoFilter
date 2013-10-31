// Convert Y'UV output of camera into packed RGB/Y output

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;


varying mediump vec2 tc11;
varying mediump vec2 tc12;
varying mediump vec2 tc13;
varying mediump vec2 tc21;
varying mediump vec2 tc22;
varying mediump vec2 tc23;
varying mediump vec2 tc31;
varying mediump vec2 tc32;
varying mediump vec2 tc33;

uniform mediump mat3 rgbConvolution;
uniform mediump mat3 colorConvolution;
uniform mediump mat3 rgb2lms;
uniform mediump mat3 lms2rgb;

#define sampleYUV(tc) vec3(texture2D(SamplerY, tc).r, texture2D(SamplerUV, tc).rg - vec2(0.5, 0.5))

/*
mediump vec3 sampleYUV(highp vec2 tc)
{
    mediump vec3 yuv;
    yuv.x = texture2D(SamplerY, tc).r;
    yuv.yz = texture2D(SamplerUV, tc).rg - vec2(0.5, 0.5);
    return yuv;
}
*/

const mediump float blur = 1.0 / 13.0;

void main()
{
    mediump vec3 m11 = sampleYUV(tc11);
    mediump vec3 m12 = sampleYUV(tc12);
    mediump vec3 m13 = sampleYUV(tc13);
    mediump vec3 m21 = sampleYUV(tc21);
    mediump vec3 m22 = sampleYUV(tc22);
    mediump vec3 m23 = sampleYUV(tc23);
    mediump vec3 m31 = sampleYUV(tc31);
    mediump vec3 m32 = sampleYUV(tc32);
    mediump vec3 m33 = sampleYUV(tc33);
    


    mediump vec3 accumulated = m11 + 2.0 * m12 + m13
                        + 2.0 * m21 + m22 + 2.0 * m23
                        + m31 + 2.0 * m32 + m33;
    
    accumulated *= blur;
    
    mediump vec3 rgb = clamp(rgbConvolution * accumulated,0.0,1.0);
    rgb = clamp(colorConvolution * rgb,0.0,1.0);

    
    gl_FragColor = vec4(rgb,accumulated.x);
}

