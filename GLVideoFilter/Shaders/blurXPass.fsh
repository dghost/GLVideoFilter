// blurXPass.fsh
//
// Performs horizontal Gaussian blur
//

uniform sampler2D SamplerRGB;

varying mediump vec2 tc21;
varying mediump vec2 tc22;
varying mediump vec2 tc23;

#define sampleRGBA(tc) (texture2D(SamplerRGB, tc))

const mediump float blur1 = 1.0 / 4.0;
const mediump float blur2 = 2.0 / 4.0;

void main()
{
    mediump vec4 m21 = sampleRGBA(tc21);
    mediump vec4 m22 = sampleRGBA(tc22);
    mediump vec4 m23 = sampleRGBA(tc23);

    gl_FragColor =  blur1 * (m21 + m23) + blur2 * m22;
}

