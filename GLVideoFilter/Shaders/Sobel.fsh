// Simple Sobel pass
// Operates on RGB source

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


void main()
{
    
    mediump vec3 m11 = texture2D(SamplerRGB, tc11).rgb;
    mediump vec3 m12 = texture2D(SamplerRGB, tc12).rgb;
    mediump vec3 m13 = texture2D(SamplerRGB, tc13).rgb;
    mediump vec3 m21 = texture2D(SamplerRGB, tc21).rgb;
 //   mediump vec3 m22 = texture2D(SamplerRGB, tc22).rgb;
    mediump vec3 m23 = texture2D(SamplerRGB, tc23).rgb;
    mediump vec3 m31 = texture2D(SamplerRGB, tc31).rgb;
    mediump vec3 m32 = texture2D(SamplerRGB, tc32).rgb;
    mediump vec3 m33 = texture2D(SamplerRGB, tc33).rgb;

    mediump vec3 H = -m11 - 2.0*m12 - m13 +m31 + 2.0*m32 + m33;
    
    mediump vec3 V = m11 - m13 + 2.0*m21 - 2.0*m23 +     m31  -     m33;
    
    mediump vec3 sobel = sqrt(H*H+V*V);
    
    gl_FragColor = vec4(sobel,1.0);
    
    
    /*
    mediump vec3 laplacian = -m11 -m12 -m13 -m21 + 8.0 *m22 - m23 - m31 - m32 -m33;
    gl_FragColor = vec4(laplacian,1.0);
     */
}

