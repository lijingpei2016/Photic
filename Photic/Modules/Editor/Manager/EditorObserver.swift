//
//  EditViewObserver.swift
//  Photic
//
//  Created by lanht on 2022/9/4.
//

import UIKit
import AVFoundation

let kSegmentDidChange = "kSegmentDidChange"

protocol EditorObserver {
//    static let shared = EditorObserver()
    
//    private init() {}

//    var trackViewDidScroll: ((_ scale: CGFloat) -> Void)?
        
    func didAddAsset(_ asset: AVAsset)
    func medialineWidthChangeEnd(ws: [Float])
    func medialineDidScroll(scale: CGFloat)
    
    func play()
}

extension EditorObserver {
//    func didAddAsset(_ asset: AVAsset) {
//        EditorManager.shared.addAsset(asset)
//    }
//    
//    func mediaTlineWidthChangeEnd(ws: [Float]) {
//        EditorManager.shared.mediaTlineWidthChangeEnd(ws: ws)
//    }
//    
//    func mediaTlineDidScroll(scale: CGFloat) {
//        
//    }
}
