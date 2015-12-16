//
//  GPUImageMoviePublisher.h
//  nrhd
//
//  Created by Fujiki Takeshi on 12/11/15.
//  Copyright © 2015 Sony Computer Science Laboratories Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenTok/OpenTok.h>
#import "GPUImageMovieWriter.h"
//#import "Util.h"
//#import "StreamingCallbackListener.h"

@interface GPUImageMovieCapture : GPUImageMovieWriter<OTVideoCapture> {

    
}

@property (nonatomic, assign) id<OTVideoCaptureConsumer> videoCaptureConsumer;
//@property (nonatomic, assign) id<StreamingCallbackListener> delegate;

- (id)initWithURL: (NSURL *)newMovieURL size: (CGSize)newSize;

- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize __attribute__((unavailable("init is not available")));
- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize fileType:(NSString *)newFileType outputSettings:(NSDictionary *)outputSettings __attribute__((unavailable("init is not available")));

// Movie streaming
- (void)startRecording;
- (void)startRecordingInOrientation:(CGAffineTransform)orientationTransform __attribute__((unavailable("not available")));
- (void)finishRecording;
- (void)finishRecordingWithCompletionHandler:(void (^)(void))handler __attribute__((unavailable("not available")));
- (void)cancelRecording __attribute__((unavailable("not available")));
- (void)processAudioBuffer:(CMSampleBufferRef)audioBuffer;
- (void)enableSynchronizationCallbacks;
-(void)sendFrame:(CMSampleBufferRef)sampleBuffer;
- (CMSampleBufferRef)copySampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 Call this method to check if the streamer is running
 
 @return Whether or not the recorder is active.
 */
- (BOOL)active;

/**
 Call this method to mute / unmute the audio.
 
 @param value If YES, there will be no sound recorded; sound will be recorded otherwise
 */
- (void)mute:(BOOL)value;

/**
 The video stream can be shown or hidden while the recorder is streaming.
 
 @param show BOOL value stating whether or not the video stream should be sent
 */
- (void)showVideo:(BOOL)show;

@end
