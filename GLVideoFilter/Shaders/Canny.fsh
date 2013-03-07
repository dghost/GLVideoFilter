// Canny Edge Detector

uniform sampler2D SamplerRGB;

uniform highp vec2 texelSize;
varying highp vec2 texCoordVarying;

const mediump float pi = 3.1415926535;


mediump float sampleMag(highp float dx, highp float dy)
{
    mediump vec2 mag = texture2D(SamplerRGB, texCoordVarying + vec2(dx,dy)).gb;
    mag *= 4.0;
    return (sqrt(mag.x * mag.x + mag.y * mag.y));
}

mediump float sampleTheta(highp float dx, highp float dy)
{
    mediump float theta = texture2D(SamplerRGB, texCoordVarying + vec2(dx,dy)).a;
    theta -= 0.5;
    // cast it from - pi/2 to pi/2
    theta = degrees(theta * pi);
    if (theta < 0.0)
        theta = 180.0 + theta;
    return theta;
}

const mediump float blur = 1.0 / 13.0;
void main()
{
    highp float dX = texelSize.x;
    highp float dY = texelSize.y;
    
    mediump float angle = sampleTheta(0.0,0.0);
    
    mediump float m11 = sampleMag(-dX,+dY);
    mediump float m12 = sampleMag(0.0,+dY);
    mediump float m13 = sampleMag(+dX,+dY);
    mediump float m21 = sampleMag(-dX,0.0);
    mediump float m22 = sampleMag(0.0,0.0);
    mediump float m23 = sampleMag(+dX,0.0);
    mediump float m31 = sampleMag(-dX,-dY);
    mediump float m32 = sampleMag(0.0,-dY);
    mediump float m33 = sampleMag(+dX,-dY);
    
    mediump float result = 0.0;
    


    if (angle <= 22.5 || angle >= 157.5)
    {
        result = (m22 > m21 && m22 > m23) ?  m22 : 0.0;
    } else if ( angle <= 112.5 && angle >= 77.5)
    {
        result = (m22 > m12 && m22 > m32) ? m22 : 0.0;
    } else if ( angle <= 77.5 && angle >= 22.5)
    {
        result = (m22 > m11 && m22 > m33) ? m22 : 0.0;
    } else
    {
        result = (m22 > m13 && m22 > m31) ? m22: 0.0;
    }

    // set low threshold
    result = (result > 0.15) ? 1.0 : 0.0;

    // set pixel to white if it passed, or black otherwise
    mediump vec4 outColor = vec4(vec3(result),1.0);

    gl_FragColor = outColor;
    
    
}

