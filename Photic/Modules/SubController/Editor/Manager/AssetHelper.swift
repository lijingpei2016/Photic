//
//  EditManager.swift
//  Photic
//
//  Created by lanht on 2022/9/4.
//

import UIKit
import AVFoundation

protocol AssetHelper: AnyObject {
    
//    var assert: AVAsset
    
//    private lazy var player: AVPlayer = {
//        let item = AVPlayerItem(asset: assert)
//        let player = AVPlayer(playerItem: item)
//        player.seek(to: .zero)
//        player.pause()
//        return player
//    }()
    
//    @objc init(assert: AVAsset) {
//        self.assert = assert
//    }
    
    func avplayer(from asset: AVAsset) -> AVPlayer
    func previewLayer(from avplayer: AVPlayer) -> AVPlayerLayer
    func time(for asset: AVAsset, seconds: Float64) -> CMTime
    func seconds(for asset: AVAsset) -> Float64
    func seek(to time: CMTime, player: AVPlayer)
    func generatorImages(from avAsset: AVAsset, count: Int, completion: ((_ images: Array<UIImage>?) -> Void)?)
}

extension AssetHelper {
    func avplayer(from asset: AVAsset) -> AVPlayer {
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        player.seek(to: .zero)
        player.pause()
        return player
    }
    
    func previewLayer(from avplayer: AVPlayer) -> AVPlayerLayer {
        let layer = AVPlayerLayer(player: avplayer)
        return layer
    }
    
    func seek(to time: CMTime, player: AVPlayer) {
        player.seek(to: time, toleranceBefore: CMTime(value: 1, timescale: 1000), toleranceAfter: CMTime(value: 1, timescale: 1000))
    }
    
    
//    @objc func play() {
//        player.play()
//    }
    
    func time(for asset: AVAsset, seconds: Float64) -> CMTime {
        guard let track = asset.tracks(withMediaType: .video).first else {
            return .zero
        }
        
        let fps = Int32(track.nominalFrameRate)
        let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: fps)
        return time
    }
    
    func seconds(for asset: AVAsset) -> Float64 {
        guard let _ = asset.tracks(withMediaType: .video).first else {
            return 0
        }
        
        return Float64(asset.duration.value) / Float64(asset.duration.timescale)
    }
    
    func generatorImages(from avAsset: AVAsset, count: Int = 0, completion: ((_ images: Array<UIImage>?) -> Void)?) {
        guard let track = avAsset.tracks(withMediaType: .video).first else {
            return
        }
        
        let fps = Int32(track.nominalFrameRate)
        let seconds = ceil((Double(avAsset.duration.value) / Double(avAsset.duration.timescale)))
        var imgCount = Int(seconds)
        
        print("imgCount == \(imgCount)")
        var times = Array<NSValue>()
        if count != 0 {
            imgCount = count
        }
        
        let interval = seconds / Double(imgCount)
        
        for i in 0..<imgCount {
            let t = Double(i) * interval
            let time = CMTimeMakeWithSeconds(Float64(t), preferredTimescale: fps)
            CMTimeShow(time)
            let value = NSValue(time: time)
            times.append(value)
        }

        let genetator = AVAssetImageGenerator(asset: avAsset)
        genetator.maximumSize = CGSize(width: 100, height: 100)
        genetator.appliesPreferredTrackTransform = true
        
        DispatchQueue(label: "image.generator", attributes: .init(rawValue: 0)).async {
            var images = Array<UIImage>()
            genetator.generateCGImagesAsynchronously(forTimes: times) { requestTime, cgImage, time, result, error in
                switch result {
                case .succeeded:
                    guard let cgImg = cgImage else {
                        return
                    }
                    let image = UIImage(cgImage: cgImg)
                    let imageData = image.pngData()
                    images.append(image)
                    
                    if times.count == images.count {
                        genetator.cancelAllCGImageGeneration()
                        
                        DispatchQueue.main.async {
                            completion?(images)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion?(nil)
                        }
                    }
                    
                case .failed:
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                case .cancelled:
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                }
            }
        }
    }
}
