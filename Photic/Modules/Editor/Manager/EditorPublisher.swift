//
//  EditorPublisher.swift
//  Photic
//
//  Created by lanht on 2022/10/25.
//

import UIKit

protocol EditorPublisher {

}

let kSegmentDidChange = "kSegmentDidChange"
let kPlayerProgressDidChange = "kPlayerProgressDidChange"
let kPlayerPlayDidPause = "kPlayerPlayDidEnd"

extension EditorPublisher {
    func publishSegmentsDidChange(segments: [Segment]) {
        DispatchQueue.main.async { 
            NotificationCenter.default.post(name: NSNotification.Name(kSegmentDidChange), object: nil, userInfo: ["segments": segments])
        }
    }
    
    func publishPlayerChangeProgress(_ progress: Float) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(kPlayerProgressDidChange), object: nil, userInfo: ["progress": progress])
        }
    }
    
    func publishPlayerPlayPause() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(kPlayerPlayDidPause), object: nil, userInfo: nil)
        }
    }
}
