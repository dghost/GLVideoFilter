// Simple Sobel pass
// Operates on Illumination (graysacle) source

uniform sampler2D SamplerRGB;

varying mediump vec2 tc11;
varying mediump vec2 tc12;
varying mediump vec2 tc13;
varying mediump vec2 tc21;
varying mediump vec2 tc22;
varying mediump vec2 tc23;
varying mediump vec2 tc31;
varying mediump vec2 tc32;
varying mediump vec2 tc33;

//const mediump float pi2 = 1.0 /  3.1415926535;
const mediump float pi = 3.1415926535;

#define sampleRGBA(tc) (texture2D(SamplerRGB, tc))
#define sampleRGB(tc) (texture2D(SamplerRGB, tc).rgb)
#define sampleA(tc) (texture2D(SamplerRGB, tc).a)
void main()
{
    
    mediump float m11 = sampleA(tc11);
    mediump float m12 = sampleA(tc12);
    mediump float m13 = sampleA(tc13);
    mediump float m21 = sampleA(tc21);
 //   mediump float m22 = sampleA(tc22);
    mediump float m23 = sampleA(tc23);
    mediump float m31 = sampleA(tc31);
    mediump float m32 = sampleA(tc32);
    mediump float m33 = sampleA(tc33);
    

      
    mediump float H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    mediump float V =  m11  - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    mediump float sobel = length(vec2(H,V));
    
    
    // output result as gray
    mediump vec4 outColor = vec4(sobel);

    gl_FragColor = outColor;
    
    
}

