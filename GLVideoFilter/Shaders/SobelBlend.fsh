// SobelBlend.fsh
//
// Blended Sobel pass
// Adds 50% of BW Sobel result to the RGB result
// Results in image that is brighter than pure RGB
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

#define sampleRGBA(tc) (texture2D(SamplerRGB, tc).rgba)

void main()
{
    mediump vec4 m11 = sampleRGBA(tc11);
    mediump vec4 m12 = sampleRGBA(tc12);
    mediump vec4 m13 = sampleRGBA(tc13);
    mediump vec4 m21 = sampleRGBA(tc21);
    //mediump float m22 = sample(tc22);
    mediump vec4 m23 = sampleRGBA(tc23);
    mediump vec4 m31 = sampleRGBA(tc31);
    mediump vec4 m32 = sampleRGBA(tc32);
    mediump vec4 m33 = sampleRGBA(tc33);
    
    // calculate the sobel value for the RGB and Grayscale values
    mediump vec4 H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    mediump vec4 V =     m11  - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    
    // calculate the length of each channel
    mediump vec4 sobel = sqrt(H*H+V*V);
    
    // add 50% of the grayscale sobel to 50% of the RGB sobel.
    mediump vec3 rgb = sobel.rgb * 0.5 + vec3(sobel.a * 0.5 );
    mediump vec4 outColor = vec4(rgb,1.0);
    gl_FragColor = outColor;
}

