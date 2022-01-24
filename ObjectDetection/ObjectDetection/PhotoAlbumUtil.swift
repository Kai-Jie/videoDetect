//
//  PhotoAlbumUtil.swift
//  ObjectDetection
//
//  Created by Neo Hsu on 2022/1/24.
//  Copyright © 2022 MachineThink. All rights reserved.
//

import Photos
import UIKit

enum PhotoAlbumUtilResult
{
    case success, error, denied
}

class PhotoAlbumUtil: NSObject
{
    static func requestAuthorized()
    {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { accessLevel in
                
            })
        } else {
            PHPhotoLibrary.requestAuthorization({ accessLevel in
                
            })
        }
    }
    
    static func isAuthorized() -> Bool
    {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    static func addVodeo(url:URL)
    {
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                
            } else{
                print(error!.localizedDescription)
            }
        }
    }
    /*
    static func saveVideoInAlbum(url:URL)
    {
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                
                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler:{ (avurlAsset, audioMix, dict) in
                    let newObj = avurlAsset as! AVURLAsset
                    print(newObj.url)
                })
                
            } else{
                print(error!.localizedDescription)
            }
        }
    }*/
}
