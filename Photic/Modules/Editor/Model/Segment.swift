//
//  Segment.swift
//  Photic
//
//  Created by lanht on 2022/10/7.
//

import Foundation
import UIKit
import AVFoundation

class Segment: NSObject {
    lazy var thumbnails = [UIImage]()
    var offsetX = 0
    var asset: AVAsset?
    
    func width() -> Float {
        return Float(thumbnails.count * thumbnailW)
    }
}
