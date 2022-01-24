//
//  AssetVideoRecord.swift
//  ObjectDetection
//
//  Created by Neo Hsu on 2022/1/24.
//  Copyright © 2022 MachineThink. All rights reserved.
//

import AVFoundation
import UIKit

public class AssetVideoRecord: NSObject
{
    let queue = DispatchQueue(label: "net.machinethink.videorecord-queue")

    private var assetWriter:AVAssetWriter?
    private var pixelBufferAdaptor:AVAssetWriterInputPixelBufferAdaptor?
    private var bitRat:Float  = 24
    private var outputSize:CGSize = CGSize(width: 1280,height: 720)
    private var outputURL:URL?
    
    public func setUp(outputSize:CGSize,bitRat:Float,completion: @escaping (Bool) -> Void)
    {
        self.bitRat = bitRat
        self.outputSize = outputSize
        
        queue.async {
            let videoCompositionProps = [AVVideoAverageBitRateKey: bitRat]
            let outputSettings:[String:Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: outputSize.width,
                AVVideoHeightKey: outputSize.height,
                AVVideoCompressionPropertiesKey: videoCompositionProps
                ] as [String : Any]
            
            
            let result = self.setUpVideoWrite(outputSettings: outputSettings)
          
            completion(result)
        }
    }
    
    func setUpVideoWrite(outputSettings:[String:Any]) ->Bool
    {
        //outputURL = URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!.path + "/detectVideo/test\(Int(Date().timeIntervalSince1970)).mp4")

        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        outputURL = docDir.appendingPathComponent("detectVideo\(Int(Date().timeIntervalSince1970)).mp4")
        
        do{
            assetWriter = try AVAssetWriter(outputURL: outputURL!, fileType: .mp4)
            assetWriter?.shouldOptimizeForNetworkUse = true
        }catch
        {
            print("assetWriter init failed.")
            return false
        }
        
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        writerInput.expectsMediaDataInRealTime = true
        
        if assetWriter?.canAdd(writerInput) == true
        {
            assetWriter?.add(writerInput)
        }
        
        return true
    }
    
    public func start(sampleBuffer:CMSampleBuffer)
    {
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
    }
    
    public func stop()
    {
        queue.async {
            self.assetWriter?.inputs.first?.markAsFinished()
            self.assetWriter?.finishWriting {
                PhotoAlbumUtil.addVodeo(url: self.outputURL!)
                
                self.assetWriter = nil
                self.outputURL = nil
            }
        }
    }
    
    public func recordVideo(sampleBuffer:CMSampleBuffer)
    {
        queue.async {
            if let writerInput = self.assetWriter?.inputs.first
            {
                if writerInput.isReadyForMoreMediaData {
                    writerInput.append(sampleBuffer)
                }
            }
        }
        
    }
}
