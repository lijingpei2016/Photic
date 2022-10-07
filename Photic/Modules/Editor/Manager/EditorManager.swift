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
    
    lazy var editorObserver = EditorObserver()
    
//    var assetHelper: AssetHelper?
    
    private init() {
        
    }
    
    func addAsset(_ asset: AVAsset) {
        assets.append(asset)
        
        AssetHelper.generatorImages(from: asset) {[weak self] images in
            let segment = Segment()
            segment.asset = asset
            segment.thumbnails = images
            self?.segments.append(segment)
            self?.rebuildSegment()
        }
    }
    
    func rebuildSegment() {
        editorObserver.segmentsDidChange(segments: self.segments)
    }
    
    func newSegment() {
        
    }
    
    func deleteSegment() {
        
    }
}
