// Canny Edge Detector

uniform sampler2D SamplerRGB;

uniform mediump float lowThreshold;
uniform mediump float highThreshold;

varying mediump vec2 tc11;
varying mediump vec2 tc12;
varying mediump vec2 tc13;
varying mediump vec2 tc21;
varying mediump vec2 tc22;
varying mediump vec2 tc23;
varying mediump vec2 tc31;
varying mediump vec2 tc32;
varying mediump vec2 tc33;

#define sampleR(tc) (texture2D(SamplerRGB, tc).r)
#define sampleRA(tc) (texture2D(SamplerRGB, tc).ra)

void main()
{
    mediump vec2 temp = sampleRA(tc22);
    mediump float m11 = sampleR(tc11);
    mediump float m12 = sampleR(tc12);
    mediump float m13 = sampleR(tc13);
    mediump float m21 = sampleR(tc21);
    mediump float m22 = temp.r;
    mediump float m23 = sampleR(tc23);
    mediump float m31 = sampleR(tc31);
    mediump float m32 = sampleR(tc32);
    mediump float m33 = sampleR(tc33);
    
    mediump float result = 0.0;
    
    if (m22 >= highThreshold)
        result = 1.0;
    else if (m22 >= lowThreshold)
    {
        if ((m11 >= highThreshold) || (m12 >= highThreshold) || (m13 >= highThreshold ) ||
            (m21 >= highThreshold) || (m23 >= highThreshold) ||
            (m31 >= highThreshold) || (m32 >= highThreshold) || (m33 >= highThreshold))
            result = 1.0;
    }
    // set pixel to white if it passed, or black otherwise
    mediump vec4 outColor = vec4(vec3(temp.g),1.0);
    outColor.r += result;

    gl_FragColor = outColor;
}

