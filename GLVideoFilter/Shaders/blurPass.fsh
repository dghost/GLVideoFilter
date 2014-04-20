// blurPass.fsh
//
// Performs approximate gaussian blur
//

uniform sampler2D SamplerRGB;

varying mediump vec2 tc[5];

void main(void)
{
    mediump float weight[2];
    weight[0] = 1.0 / 2.0;
    weight[1] = 1.0 / 4.0;
    mediump vec4 FragmentColor = texture2D( SamplerRGB, tc[2] ) * weight[0];
    FragmentColor += texture2D( SamplerRGB, tc[1] ) * weight[1];
    FragmentColor += texture2D( SamplerRGB, tc[3] ) * weight[1];
    gl_FragColor = FragmentColor;
}
