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
    var seconds: Float = 0
//    var buildWith: Float {
//        get {
//            return seconds * Float(thumbnailW)
//        }
//    }
    var width: Float = 0.0
//    func width() -> Float {
//        return Float(thumbnails.count) * Float(thumbnailW)
//    }
}
