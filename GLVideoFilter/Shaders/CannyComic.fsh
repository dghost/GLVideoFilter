// CannyComic.fsh
//
// Comic effect using Canny edge detection + thresholding
//
// Takes the input of CannyMag.fsh
//
// Outputs a black pixel if it is over the high threshold
//  or if it is over the low threshold and a neighbor is
//  over the high threshold. Otherwise, outputs a pixel value
//  based on intensity and a simple cell shading filter
//


uniform sampler2D SamplerRGB;

uniform mediump float lowThreshold;
uniform mediump float highThreshold;
uniform highp vec2 texelSize;


varying mediump vec2 tc11;
varying mediump vec2 tc12;
varying mediump vec2 tc13;
varying mediump vec2 tc21;
varying mediump vec2 tc22;
varying mediump vec2 tc23;
varying mediump vec2 tc31;
varying mediump vec2 tc32;
varying mediump vec2 tc33;

#define sampleR(tc) (texture2D(SamplerRGB, tc).r)
#define sampleRGBA(tc) (texture2D(SamplerRGB, tc))

// parameters that define the comic effect
#define LINE_SLOPE -0.9
#define LINE_INTERVAL 10.0
#define LINE_STRENGTH 1.0
#define BLACK_THRESHOLD 0.2
#define WHITE_THRESHOLD 0.45


void main()
{
    bool result = false;
    mediump vec4 temp = sampleRGBA(tc22);
    mediump float m22 = temp.r;
    
    
    if (m22 >= highThreshold )
    {
        result = true;
    }
    else if (m22 >= lowThreshold){
        mediump float m11 = sampleR(tc11);
        mediump float m12 = sampleR(tc12);
        mediump float m13 = sampleR(tc13);
        mediump float m21 = sampleR(tc21);
        mediump float m23 = sampleR(tc23);
        mediump float m31 = sampleR(tc31);
        mediump float m32 = sampleR(tc32);
        mediump float m33 = sampleR(tc33);
        if ((m11 >= highThreshold) || (m12 >= highThreshold) || (m13 >= highThreshold ) ||
            (m21 >= highThreshold) || (m23 >= highThreshold) ||
            (m31 >= highThreshold) || (m32 >= highThreshold) || (m33 >= highThreshold))
        {
            result = true;
        }
    }
    
    
    // set pixel to white if it passed, or black otherwise
    mediump vec3 outColor;

    if (result)
        outColor = vec3(0.0);
    else
    {
        if (temp.a > WHITE_THRESHOLD)
        {
            outColor = vec3(1.0);
        } else if (temp.a < BLACK_THRESHOLD)
        {
            outColor = vec3(0.0);
        } else
        {
            mediump vec2 pixel = tc22 / texelSize;
            mediump float b = LINE_SLOPE * pixel.x - pixel.y;
            mediump float value = (floor(mod(b,LINE_INTERVAL)) - LINE_STRENGTH  > 0.0) ? 1.0 : 0.0;
            outColor = vec3(value);
        }
    }
    gl_FragColor = vec4(outColor,1.0);
}

