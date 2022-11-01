//
//  EditorPublisher.swift
//  Photic
//
//  Created by lanht on 2022/10/25.
//

import UIKit

protocol EditorPublisher {
    func segmentsDidChange(segments: [Segment])
}

extension EditorPublisher {
    func segmentsDidChange(segments: [Segment]) {
        DispatchQueue.main.async { 
            NotificationCenter.default.post(name: NSNotification.Name(kSegmentDidChange), object: nil, userInfo: ["segments": segments])
        }
    }
}
