// Sobel.fsh
//
// Simple Sobel pass
// Operates on RGB source
//

uniform sampler2D SamplerRGB;

varying mediump vec2 tc11;
varying mediump vec2 tc12;
varying mediump vec2 tc13;
varying mediump vec2 tc21;
//varying mediump vec2 tc22;
varying mediump vec2 tc23;
varying mediump vec2 tc31;
varying mediump vec2 tc32;
varying mediump vec2 tc33;

#define sampleRGB(tc) (texture2D(SamplerRGB, tc).rgb)

void main()
{
    
    mediump vec3 m11 = sampleRGB(tc11);
    mediump vec3 m12 = sampleRGB(tc12);
    mediump vec3 m13 = sampleRGB(tc13);
    mediump vec3 m21 = sampleRGB(tc21);
 //   mediump vec3 m22 = sampleRGB(tc22)b;
    mediump vec3 m23 = sampleRGB(tc23);
    mediump vec3 m31 = sampleRGB(tc31);
    mediump vec3 m32 = sampleRGB(tc32);
    mediump vec3 m33 = sampleRGB(tc33);

    mediump vec3 H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    
    mediump vec3 V = m11 - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    
    // calculate the length for each channel in the vector
    mediump vec3 sobel = sqrt(H*H+V*V);
    
    gl_FragColor = vec4(sobel,1.0);
}

