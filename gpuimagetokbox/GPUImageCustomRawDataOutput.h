//
//  GPUImageCustomRawDataOutput.h
//  gpuimagetokbox
//
//  Created by Fujiki Takeshi on 12/18/15.
//  Copyright © 2015 takecian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenTok/OpenTok.h>
#import "GPUImageRawDataOutput.h"

@interface GPUImageCustomRawDataOutput : GPUImageRawDataOutput<OTVideoCapture>

@property(nonatomic, copy) void(^newFrameAvailableBlockWithTime)(CMTime frameTime);
@property (atomic, assign) id<OTVideoCaptureConsumer> videoCaptureConsumer;

- (void)startRecording;
- (void)finishRecording;
- (BOOL)active;

- (void)sendFrame:(CMSampleBufferRef)sampleBuffer;
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;

@end
