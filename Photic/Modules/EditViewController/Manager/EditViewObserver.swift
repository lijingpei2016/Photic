//
//  EditViewObserver.swift
//  Photic
//
//  Created by lanht on 2022/9/4.
//

import UIKit

class EditViewObserver: NSObject {
   @objc static let observer = EditViewObserver()
    
    private override init() {
        super.init()
    }
    
    @objc var trackViewDidScroll: ((_ scale: CGFloat) -> Void)?
    
    @objc var generatorImageCompletion: ((_ images: Array<UIImage>) -> Void)?
    
    @objc var segmentImagesDidChange: ((_ count: Int) -> Void)?
}
