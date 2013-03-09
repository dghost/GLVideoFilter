// Convert Y'UV output of camera into packed RGB/Y output

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;

varying highp vec2 texCoordVarying;

void main()
{
    mediump vec3 yuv;
    mediump vec3 rgb;
    yuv.x = texture2D(SamplerY, texCoordVarying).r;
    yuv.yz = texture2D(SamplerUV, texCoordVarying).rg - vec2(0.5, 0.5);
    // Use BT.709 to calculate RGB from Y'UV
    
    rgb = mat3(      1,       1,      1,
                     0, -.18732, 1.8556,
               1.57481, -.46813,      0) * yuv;
    
    // pack the RGB and original Y (grayscale) output into the texture
    gl_FragColor = vec4(rgb,yuv.x);
    
    
}

