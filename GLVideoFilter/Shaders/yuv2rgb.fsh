// Convert Y'UV output of camera into packed RGB/Y output

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;

varying mediump vec2 texCoordVarying;

uniform mediump mat3 rgbConvolution;
uniform mediump mat3 colorConvolution;


mediump mat3 yuv2rgb = mat3(  1.0       ,1.0          ,      1.0 ,
                        0.0       ,-.18732    , 1.8556,

                            1.57481 , -.46813   ,      0.0);
void main()
{
    mediump vec3 yuv;

    yuv.x = texture2D(SamplerY, texCoordVarying).r;
    yuv.yz = texture2D(SamplerUV, texCoordVarying).rg - vec2(0.5, 0.5);
    // Use BT.709 to calculate RGB from Y'UV
    
    mediump vec3 rgb = clamp(rgbConvolution * yuv,0.0,1.0);

    rgb = clamp(colorConvolution * rgb,0.0,1.0);

    // pack the RGB and original Y (grayscale) output into the texture
    gl_FragColor = vec4(rgb,yuv.x);
    
    
}

