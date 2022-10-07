//
//  EditManager.swift
//  Photic
//
//  Created by lanht on 2022/9/4.
//

import UIKit
import AVFoundation

class AssetHelper: NSObject {
    
    var assert: AVAsset
    
    private lazy var player: AVPlayer = {
        let item = AVPlayerItem(asset: assert)
        let player = AVPlayer(playerItem: item)
        player.seek(to: .zero)
        player.pause()
        return player
    }()
    
    @objc init(assert: AVAsset) {
        self.assert = assert
    }
    
    @objc func seek(to time: CMTime) {
        self.player.seek(to: time, toleranceBefore: CMTime(value: 1, timescale: 1000), toleranceAfter: CMTime(value: 1, timescale: 1000))
    }
    
    @objc func getPreviewLayer() -> AVPlayerLayer? {
        let layer = AVPlayerLayer(player: player)
        return layer
    }
    
    @objc func play() {
        player.play()
    }
    
    @objc func timeForAssert(seconds: Float) -> CMTime {
        guard let track = self.assert.tracks(withMediaType: .video).first else {
            return .zero
        }
        
        let fps = Int32(track.nominalFrameRate)
        let time = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: fps)
        return time
        
    }
    
    @objc func getAssertSeconds() -> Float64 {
        guard let _ = self.assert.tracks(withMediaType: .video).first else {
            return 0
        }
        
        return Float64(self.assert.duration.value) / Float64(self.assert.duration.timescale)
    }
    
    @objc static func generatorImages(from avAsset: AVAsset,  completion: ((_ images: Array<UIImage>) -> Void)?) {
        guard let track = avAsset.tracks(withMediaType: .video).first else {
            return
        }
        
        let fps = Int32(track.nominalFrameRate)
        let totalTimes = Int(Int32(avAsset.duration.value) / avAsset.duration.timescale)
        var times = Array<NSValue>()
        
        for i in 0..<totalTimes {
            let time = CMTimeMakeWithSeconds(Float64(i), preferredTimescale: fps)
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
                    }
                    
                case .failed:
                    ()
                case .cancelled:
                    ()
                @unknown default:
                    ()
                }
            }
        }
        
    }
}
