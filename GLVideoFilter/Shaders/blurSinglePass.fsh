// Convert Y'UV output of camera into packed RGB/Y output

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

#define sampleRGBA(tc) (texture2D(SamplerRGB, tc))

const mediump float blur1 = 1.0 / 16.0;
const mediump float blur2 = 2.0 / 16.0;
const mediump float blur4 = 4.0 / 16.0;

void main()
{
    mediump vec4 m11 = sampleRGBA(tc11);
    mediump vec4 m12 = sampleRGBA(tc12);
    mediump vec4 m13 = sampleRGBA(tc13);
    mediump vec4 m21 = sampleRGBA(tc21);
    mediump vec4 m22 = sampleRGBA(tc22);
    mediump vec4 m23 = sampleRGBA(tc23);
    mediump vec4 m31 = sampleRGBA(tc31);
    mediump vec4 m32 = sampleRGBA(tc32);
    mediump vec4 m33 = sampleRGBA(tc33);
    

    gl_FragColor =  blur1 * (m11 + m13 + m31 + m33)
                    + blur2 * (m12 + m21 + m23 + m32)
                    + blur4 * m22;
}

