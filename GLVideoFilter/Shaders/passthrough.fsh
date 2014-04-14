// passthrough.fsh
//
// Samples the texture and writes the result to the pixel
//

uniform sampler2D SamplerRGB;

varying highp vec2 texCoordVarying;

void main()
{
    gl_FragColor = texture2D(SamplerRGB, texCoordVarying);
}

