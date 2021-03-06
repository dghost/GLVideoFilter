// CannyMag.fsh
//
// Canny Edge Detector
// Takes the result of SobelCanny.fsh and discards pixels that fail
//   to meet the critera applied by the Canny edge detection algorithms
//

uniform sampler2D SamplerRGB;

uniform mediump float threshold;

varying mediump vec2 tc11;
varying mediump vec2 tc12;
varying mediump vec2 tc13;
varying mediump vec2 tc21;
varying mediump vec2 tc22;
varying mediump vec2 tc23;
varying mediump vec2 tc31;
varying mediump vec2 tc32;
varying mediump vec2 tc33;

const mediump float pi = 3.1415926535;

#define sampleRGBA(tc) (texture2D(SamplerRGB, tc))
#define sampleRGB(tc) (texture2D(SamplerRGB, tc).rgb)
#define sampleA(tc) (texture2D(SamplerRGB, tc).a)

// sample H and V and return the magnitude
mediump float mag(mediump vec2 hv)
{
    return (length(hv * 4.0));
}

// sample the angle
mediump float unpack(lowp float angle)
{
    // convert it from 0.0 - 1.0 to -pi/2 to pi/2   
    mediump float theta = angle - 0.5;
    theta = degrees(theta * pi);
    if (theta < 0.0)
        theta += 180.0;
    return theta;
}

#define sampleMag(tc) ((texture2D(SamplerRGB,tc).g))

#define sampleTheta(tc) (unpack(sampleA(tc)))

void main()
{
    mediump vec3 temp = sampleRGB(tc22);
    mediump float angle = unpack(temp.b);
    mediump float m11 = sampleMag(tc11);
    mediump float m12 = sampleMag(tc12);
    mediump float m13 = sampleMag(tc13);
    mediump float m21 = sampleMag(tc21);
    mediump float m22 = temp.g;
    mediump float m23 = sampleMag(tc23);
    mediump float m31 = sampleMag(tc31);
    mediump float m32 = sampleMag(tc32);
    mediump float m33 = sampleMag(tc33);
    
    mediump float result = 0.0;
    
    bool test = (angle <= 22.5 || angle >= 157.5)&&(m22 > m21 && m22 > m23)
    || ((angle <= 112.5 && angle >= 77.5)&&(m22 > m12 && m22 > m32))
    || ((angle <= 77.5 && angle >= 22.5)&&(m22 > m11 && m22 > m33))
    || ((angle >= 112.5 && angle <= 157.5)&&(m22 > m13 && m22 > m31));
    
    mediump vec4 outColor = vec4(vec3(0),temp.r);
    
    if (test)
        outColor.rgb = vec3(m22);
    
    gl_FragColor = outColor;
}

