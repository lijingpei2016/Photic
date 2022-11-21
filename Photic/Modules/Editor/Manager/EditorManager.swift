//
//  EditorManager.swift
//  Photic
//
//  Created by lanht on 2022/10/7.
//

import Foundation
import AVFoundation

class EditorManager {
    static let shared = EditorManager()
    
    lazy var assets = [AVAsset]()
    
    lazy var segments = [Segment]()
        
//    lazy var editorPubliser = EditorPublisher()

//    lazy var assetHelper = AssetHelper()
    
//    var assetHelper: AssetHelper?
    
    var avplaver: AVPlayer?
    
    var isPlaying = false
    
    var timeObserver: Any?
    
    private init() {
        
    }
    
    func clear() {
        assets.removeAll()
        segments.removeAll()
    }
    
    func addAsset(_ asset: AVAsset) {
        assets.append(asset)
        
        generatorAvPlayer()
        generatorSegments()
    }
    
    func generatorAvPlayer() {
        if (assets.count == 0) {
            return
        }else if (assets.count == 1) {
            guard let asset = assets.first else {
                return
            }
            avplaver = avplayer(from: asset)
        }else {
            //合成
            let builderAVAssets = NSArray(array: assets)
            let playerItem = PCAssetBuilder.builderAVAssets(builderAVAssets as! [AVAsset])
            avplaver = AVPlayer(playerItem: playerItem)
            avplaver?.seek(to: .zero)
            avplaver?.pause()
        }
        
    }
    
    func generatorSegments() {
        for asset in assets {
            generatorImages(from: asset) {[weak self] images in
                if let imgs = images {
                    let segment = Segment()
                    segment.asset = asset
                    segment.thumbnails = imgs
                    segment.width = Float(self?.seconds(for: asset) ?? 0) * Float(thumbnailW)
                    self?.segments.append(segment)
                    self?.rebuildSegment()
                }
            }
        }
    }
    
    func asset() -> AVAsset? {
        // 这里暂时先操作单个asst, 暂未合成
        guard let asset = assets.first else {
            return nil
        }
        return asset
    }
    
    func previewLayer() -> AVPlayerLayer? {
        guard let avplayer = self.avplaver else {
            return nil
        }
        
        let playerLayer = previewLayer(from: avplayer)
        return playerLayer
    }
    
    func rebuildSegment() {
        publishSegmentsDidChange(segments: self.segments)
    }
    
    func newSegment() {
        
    }
    
    func deleteSegment() {
        
    }
    
    func clearSource() {
        assets.removeAll()
        segments.removeAll()
    }
    
    func seek(to scale: Float) {
        guard let asset = asset(), let avplayer = self.avplaver else {
            return
        }
        let seconds = seconds(for: asset) * Float64(scale)
        print("seek time --- \(seconds)")
        let time = time(for: asset, seconds: seconds)
        
        seek(to: time, player: avplayer)
    }
    
}

extension EditorManager: AssetHelper {

    
}

typealias EditObserver = EditorManager

extension EditorManager: EditorObserver {
    func didAddAsset(_ asset: AVAsset) {
        
    }
    
    func medialineDidScroll(scale: CGFloat) {
        seek(to: Float(scale))
    }
    
    func medialineWidthChangeEnd(ws: [Float]) {
        self.segments.removeAll()
        
        for (i, w) in ws.enumerated() {
            let count = round(w / Float(thumbnailW))
            generatorImages(from: assets[i], count: Int(count)) { [weak self] images in
                if let imgs = images {
                    let segment = Segment()
                    segment.asset = self?.assets[i]
                    segment.thumbnails = imgs
                    segment.width = w
                    self?.segments.append(segment)
                    self?.rebuildSegment()
                    
                }
            }
        }
    }
    
    func play() {
        timeObserver = avplaver?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000), queue: nil, using: { [self] time in
            let progress = CMTimeGetSeconds(avplaver!.currentItem!.currentTime()) / CMTimeGetSeconds(avplaver!.currentItem!.duration)
            publishPlayerChangeProgress(Float(progress))
            if progress >= 1 {
                pause()
            }
        })
        
        if self.avplaver?.currentItem?.currentTime() == self.avplaver?.currentItem?.duration {
            self.avplaver?.seek(to: .zero)
        }
        
        DispatchQueue.main.async {
            self.avplaver?.play()
            self.isPlaying = true
        }
    }
    
    func pause() {
        if let observer = self.timeObserver {
            avplaver?.removeTimeObserver(observer)
            self.timeObserver = nil
        }
        
        publishPlayerPlayPause()
        DispatchQueue.main.async {
            self.avplaver?.pause()
            self.isPlaying = false
        }
        
    }
}

typealias EditPublisher = EditorManager
extension EditorManager: EditorPublisher {
    
}
