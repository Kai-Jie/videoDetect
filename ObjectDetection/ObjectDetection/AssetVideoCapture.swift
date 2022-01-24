//
//  AssetVideoCapture.swift
//  ObjectDetection
//
//  Created by Neo Hsu on 2022/1/22.
//  Copyright © 2022 MachineThink. All rights reserved.
//

import AVFoundation

public protocol AssetVideoCaptureDelegate: AnyObject {
  func videoCapture(_ capture: AssetVideoCapture, didCaptureVideoFrame: CMSampleBuffer)
}

public class AssetVideoCapture: NSObject
{
    public var previewLayer: AVSampleBufferDisplayLayer?
    public weak var delegate: AssetVideoCaptureDelegate?
    
    let queue = DispatchQueue(label: "net.machinethink.videocapture-queue")

    private var assetReader:AVAssetReader?
    
    public func setUp(completion: @escaping (Bool) -> Void)
    {
        queue.async {
            let result = self.setUpVideoRender()
          
            completion(result)
        }
    }
    
    func setUpVideoRender() ->Bool
    {
        let sourceURL = Bundle.main.url(forResource: "testVideo", withExtension: "mp4")!
        let asset = AVAsset(url: sourceURL)

        do{
            self.assetReader = try AVAssetReader(asset: asset)
        }catch{
            print("assetReader init failed.")
            return false
        }

        let track = asset.tracks(withMediaType: AVMediaType.video).first
        
        let outputSettings:[String:Any] = [kCVPixelBufferMetalCompatibilityKey as String: true,(kCVPixelBufferPixelFormatTypeKey as String):Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        let trackOutput = AVAssetReaderTrackOutput(track: track!, outputSettings: outputSettings)
        trackOutput.alwaysCopiesSampleData = false
        
        if self.assetReader?.canAdd(trackOutput) == true
        {
            self.assetReader?.add(trackOutput)
        } else {
            print("can't reader")
            return false
        }
        
        let masterClock = CMClockGetHostTimeClock()
        var timebase: CMTimebase? = nil
        
        CMTimebaseCreateWithSourceClock(allocator: kCFAllocatorDefault, sourceClock: masterClock, timebaseOut: &timebase)
        CMTimebaseSetRate(timebase!, rate: 1.0)

        let previewLayer = AVSampleBufferDisplayLayer()
      //  previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.videoGravity = AVLayerVideoGravity.resize
        previewLayer.controlTimebase = timebase
        
        self.previewLayer = previewLayer
        
        return true
    }
    
    func getVideoTrack() -> AVAssetTrack?
    {
         if let videoTrack = self.assetReader?.asset.tracks(withMediaType: AVMediaType.video).first
         {
             return videoTrack
         }
        
        return nil
    }
    
    public func start()
    {
        self.assetReader?.startReading()
        
        runVideo()
    }
    
    private func runVideo()
    {
        queue.async
        {
            let maxRetryCount = 200
            var retryCount = 0
            var isRunning = true

            while isRunning == true
            {
                if self.assetReader?.status == AVAssetReader.Status.failed
                {
                    self.previewLayer?.flush()
                    
                    retryCount = retryCount + 1
                    
                    if retryCount > maxRetryCount
                    {
                        isRunning = false
                        break
                    }
                    
                    sleep(1)
                    continue
                }else if self.assetReader?.status == AVAssetReader.Status.reading
                {
                    if let sampleBufferRef =  self.assetReader?.outputs.first?.copyNextSampleBuffer() {
                        DispatchQueue.main.async {
                            self.previewLayer?.enqueue(sampleBufferRef)
                            self.delegate?.videoCapture(self, didCaptureVideoFrame: sampleBufferRef)
                       }
                    }
                    
                    usleep(40000)
                    continue
                }
                
                isRunning = false
                break
            }
        }
    }

    public func stop()
    {
        self.assetReader?.cancelReading()
    }
    
}
