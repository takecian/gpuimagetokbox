//
//  VideoGenerator.m
//  Lizap
//
//  Created by FUJIKI TAKESHI on 2015/06/13.
//  Copyright (c) 2015年 Takeshi Fujiki. All rights reserved.
//

#import "VideoGenerator.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoGenerator ()

@property (nonatomic) AVAssetWriter *videoWriter;

@end

@implementation VideoGenerator

+ (CMSampleBufferRef)copySampleBuffer:(CMSampleBufferRef)sampleBuffer;
{
    CFAllocatorRef allocator = CFAllocatorGetDefault();
    CMSampleBufferRef sbufCopyOut;
    CMSampleBufferCreateCopy(allocator,sampleBuffer,&sbufCopyOut);
    return sbufCopyOut;
}

+ (void)sampleBufferFromRawData:(GPUImageRawDataOutput*)output frametime:(CMTime)frametime block:(void (^)(CMSampleBufferRef))block;{
    [output lockFramebufferForReading];
    
    GLubyte *outputBytes = [output rawBytesForImage];
    NSInteger bytesPerRow = [output bytesPerRowInOutput];
    NSLog(@"bytesPerRow = %ld", (long)bytesPerRow);

    CVPixelBufferRef pixel_buffer = NULL;
    OSStatus result = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, 640, 480, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, outputBytes, bytesPerRow, nil, nil, nil, &pixel_buffer);

    CMSampleBufferRef newSampleBuffer = NULL;
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixel_buffer, &videoInfo);
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                       pixel_buffer,
                                       true,
                                       NULL,
                                       NULL,
                                       videoInfo,
                                       &timimgInfo,
                                       &newSampleBuffer);
    
    CMItemCount count;
    CMTime newTimeStamp = frametime;
    CMSampleBufferGetSampleTimingInfoArray(newSampleBuffer, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(newSampleBuffer, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++)
    {
        pInfo[i].decodeTimeStamp = newTimeStamp; // kCMTimeInvalid if in sequence
        pInfo[i].presentationTimeStamp = newTimeStamp;
        
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, newSampleBuffer, count, pInfo, &sout);
    free(pInfo);
    
    block(sout);
    CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
    CVPixelBufferRelease(pixel_buffer);

    [output unlockFramebufferAfterReading];
    return;
}

@end
