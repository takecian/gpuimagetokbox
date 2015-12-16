//
//  StreamerViewModel.swift
//  nrhd
//
//  Created by Fujiki Takeshi on 11/24/15.
//  Copyright © 2015 Sony Computer Science Laboratories Inc. All rights reserved.
//

import UIKit

final class ViewModel: NSObject, GPUImageVideoCameraDelegate {
    let filterView = GPUImageView()
    var camera: GPUImageVideoCamera!
    var streamer: GPUImageMovieCapture!
    var filterGroup: GPUImageFilterGroup?
    
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
    
    func finishStreaming() {
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

    // MARK:
    func willOutputSampleBuffer(sampleBuffer: CMSampleBufferRef) {
//        if streamer.active() {
//            let copyBuffer = streamer.copySampleBuffer(sampleBuffer).takeRetainedValue()
//            self.streamer.sendFrame(copyBuffer)
//        }
    }
}
