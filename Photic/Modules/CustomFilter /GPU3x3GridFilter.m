//
//  GPU3x3GridFilter.m
//  Photic
//
//  Created by LJP on 2023/7/19.
//

#import "GPU3x3GridFilter.h"

NSString *const kGPUImage3x3GridFragmentShaderString = SHADER_STRING
    (
    varying highp vec2 textureCoordinate;

    uniform sampler2D inputImageTexture;

    void main()
{
    highp vec2 textureCoord = textureCoordinate;

    //横向坐标分成三块
    if (textureCoord.s <= 0.333) {
        textureCoord.s *= 3.0;
    } else if (textureCoord.s <= 0.666) {
        textureCoord.s = (textureCoord.s - 0.333) * 3.0;
    } else {
        textureCoord.s = (textureCoord.s - 0.666) * 3.0;
    }

    //纵向坐标分成三块
    if (textureCoord.t <= 0.333) {
        textureCoord.t *= 3.0;
    } else if (textureCoord.t <= 0.666) {
        textureCoord.t = (textureCoord.t - 0.333) * 3.0;
    } else {
        textureCoord.t = (textureCoord.t - 0.666) * 3.0;
    }
    gl_FragColor = texture2D(inputImageTexture, textureCoord);
}

    );

@implementation GPU3x3GridFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImage3x3GridFragmentShaderString])) {
        return nil;
    }
    return self;
}

@end
