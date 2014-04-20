// blurXPass.fsh
//
// Performs horizontal Gaussian blur
//

uniform sampler2D SamplerRGB;

varying mediump vec2 tc[5];

void main(void)
{
    mediump float weight[3];
    weight[0] = 0.2270270270;
    weight[1] = 0.3162162162;
    weight[2] = 0.0702702703;
    mediump vec4 FragmentColor = texture2D( SamplerRGB, tc[2] ) * weight[0];
    for (int i=1; i<3; i++) {
        FragmentColor += texture2D( SamplerRGB, tc[2 + i] ) * weight[i];
        FragmentColor += texture2D( SamplerRGB, tc[2 - i] ) * weight[i];
    }

    gl_FragColor = FragmentColor;
}