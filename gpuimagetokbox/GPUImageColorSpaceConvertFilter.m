//
//  GPUImageColorSpaceConverter.m
//  gpuimagetokbox
//
//  Created by Fujiki Takeshi on 12/17/15.
//  Copyright © 2015 takecian. All rights reserved.
//

#import "GPUImageColorSpaceConvertFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageConvertFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     highp float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
     highp float Cr = 0.7132 * (textureColor.r - Y);
     highp float Cb = 0.5647 * (textureColor.b - Y);

     gl_FragColor = vec4(Y, Cr, Cb, 1);
 }
 );
#else
NSString *const kGPUImageConvertFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);

     highp float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
     highp float Cr = 0.7132 * (textureColor.r - Y);
     highp float Cb = 0.5647 * (textureColor.b - Y);
     
     gl_FragColor = vec4(Y, Cr, Cb, 1);
 }
 );
#endif

@implementation GPUImageColorSpaceConvertFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageConvertFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end

