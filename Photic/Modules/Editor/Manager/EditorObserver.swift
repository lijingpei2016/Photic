//
//  EditViewObserver.swift
//  Photic
//
//  Created by lanht on 2022/9/4.
//

import UIKit

let kSegmentDidChange = "kSegmentDidChange"

class EditorObserver {
    lazy var notifiCenter = NotificationCenter.default

    var trackViewDidScroll: ((_ scale: CGFloat) -> Void)?
    
    var generatorImageCompletion: ((_ images: Array<UIImage>) -> Void)?
        
    func segmentsDidChange(segments: [Segment]) {
        DispatchQueue.main.async { [self] in
            notifiCenter.post(name: NSNotification.Name(kSegmentDidChange), object: nil, userInfo: ["segments": segments])
        }
    }
}
