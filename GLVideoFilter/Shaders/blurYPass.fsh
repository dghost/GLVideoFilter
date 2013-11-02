// Convert Y'UV output of camera into packed RGB/Y output

uniform sampler2D SamplerRGB;


varying mediump vec2 tc12;
varying mediump vec2 tc22;
varying mediump vec2 tc32;

#define sampleRGBA(tc) (texture2D(SamplerRGB, tc))

const mediump float blur1 = 1.0 / 4.0;
const mediump float blur2 = 2.0 / 4.0;

void main()
{
    mediump vec4 m12 = sampleRGBA(tc12);
    mediump vec4 m22 = sampleRGBA(tc22);
    mediump vec4 m32 = sampleRGBA(tc32);
    
    gl_FragColor =  blur1 * (m12 + m32)
                    + blur2 * m22;
}

