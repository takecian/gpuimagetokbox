//
//  StreamerViewModel.swift
//  nrhd
//
//  Created by Fujiki Takeshi on 11/24/15.
//  Copyright © 2015 Sony Computer Science Laboratories Inc. All rights reserved.
//

import UIKit

protocol StreamerViewModelDelegate {
    func streamingStoppWithError()
    func streamingStopped()
}

enum StreamerState {
    case Setup
    case Prepare
    case Streaming
}

final class ViewModel: NSObject, GPUImageVideoCameraDelegate {
    var delegate: StreamerViewModelDelegate?
    
    var isMute = false
    var isFront = true
    var isMirror = false
    var isRadioMode = false
    var cid: Int!
    var wsOpenUrl: String?
    var isPickupImageMode = false
    var isEventLogged = false
    var retryEnable = true
    
    let filterView = GPUImageView()
    var muteMark: GPUImagePicture!
    var waterMark: GPUImagePicture!
    var telop: GPUImagePicture!
    var frameImage: GPUImagePicture!
    var stillGpuImage: GPUImagePicture!
    var camera: GPUImageVideoCamera!
    var streamer: GPUImageMovieCapture!
    var filterGroup: GPUImageFilterGroup?
    let filterCount = 10
    var stillImage: UIImage!
    var slimValue: CGFloat = 1.0
    var faceValue: CGFloat = 9.0
    var filterIndex = 0
    var frameIndex = 0
    var telopImage: UIImage?
    
    var faces = [CGRect]()
    var lastFaceDetected = NSDate()
    
    var videoRect: CGRect!
    var isStreaming: Bool {
        get {
            return self.streamer.active()
        }
    }
    
    func startCapture() {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            // simulator
        #else
            
            self.camera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePosition.Front)
            
            self.camera.frameRate = 12
            
            self.camera.outputImageOrientation = UIInterfaceOrientation.Portrait
            self.camera.horizontallyMirrorFrontFacingCamera = true
            self.camera.horizontallyMirrorRearFacingCamera = false
            
            self.camera.startCameraCapture()
        #endif
    }
    
    func setupStreamer() {
        let tempDir = NSTemporaryDirectory()
        let targetUrl = NSURL(fileURLWithPath: "\(tempDir)/temp.mp4")
        do {
            try NSFileManager.defaultManager().removeItemAtPath("\(tempDir)/temp.mp4")
        } catch _ {
        }
        
        self.streamer = GPUImageMovieCapture(URL: targetUrl, size: CGSizeMake(480, 360))
        
        self.streamer.encodingLiveVideo = true
        self.streamer.shouldPassthroughAudio = true
        self.camera.delegate = self

        self.camera.audioEncodingTarget = self.streamer
        
        self.streamer.completionBlock = {
            Logger.log("StreamerViewController: streaming finished.")
        }
        
        self.streamer.failureBlock = { (error) in
            Logger.log("StreamerViewController: streaming failured")
        }
        
        self.updateEffect()
    }

    func handleCasStartFailed() {
        self.filterGroup?.removeTarget(self.streamer)
        self.camera.audioEncodingTarget = nil;
    }
    
    func finishStreaming() {
        self.retryEnable = false

        self.streamer.finishRecording()
        self.filterGroup?.removeTarget(self.streamer)
        self.camera.audioEncodingTarget = nil;
    }
    
    func updateEffect() {
        self.camera.removeAllTargets()
        filterGroup?.removeAllTargets()
        var filters = [GPUImageOutput]()
        
        filters.append(createBaseFilter())

        self.filterGroup = self.connectFilters(filters)
        self.camera.addTarget(self.filterGroup)
        self.filterGroup?.addTarget(self.filterView)
        self.filterGroup?.addTarget(self.streamer)
    }
    
    func createBaseFilter() -> GPUImageFilter {
        let filter = GPUImageSepiaFilter()
        return filter
    }

    func createTelopFilter(img: UIImage) -> GPUImageFilter {
        let filter = GPUImageOverlayBlendFilter()
        self.telop = GPUImagePicture(image: img, smoothlyScaleOutput:true)
        self.telop.processImage()
        self.telop.addTarget(filter)
        return filter
    }
    
    func connectFilters(filters: [GPUImageOutput]) -> GPUImageFilterGroup {
        let filterGroup = GPUImageFilterGroup()
        
        var firstFilter: GPUImageOutput!
        var lastFilter: GPUImageOutput!
        for filter in filters {
            filterGroup.addFilter(filter)
            
            if firstFilter == nil {
                firstFilter = filter
            }
            
            if lastFilter != nil {
                if let f = filter as? GPUImageFilterGroup {
                    lastFilter.addTarget(f)
                }else if let f = filter as? GPUImageFilter {
                    lastFilter.addTarget(f)
                }
            }
            lastFilter = filter
        }
        filterGroup.initialFilters = [firstFilter]
        filterGroup.terminalFilter = lastFilter
        
        return filterGroup
    }

    func generateThumbnail() -> CGImage {
        self.filterGroup?.useNextFrameForImageCapture()
        return (self.filterGroup?.newCGImageFromCurrentlyProcessedOutput().takeRetainedValue())!
    }
    
    // MARK:
    func willOutputSampleBuffer(sampleBuffer: CMSampleBufferRef) {
        if streamer.active() {
            let copyBuffer = streamer.copySampleBuffer(sampleBuffer).takeRetainedValue()
            self.streamer.sendFrame(copyBuffer)
        }
    }
}
