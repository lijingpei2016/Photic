//
//  VideoThumbnailView.swift
//  Photic
//
//  Created by lanht on 2022/10/7.
//

import UIKit

class VideoThumbnailView: UIView {

    override func layoutSubviews() {
        
    }
    
    func updateContent(thumbnails: [UIImage]) {
        let x = 0
        for(index, thumbnail) in thumbnails.enumerated() {
            let x = x + thumbnailW * index
            let thumbnailCell = VideoThumbnailCell()
            thumbnailCell.frame = CGRect(x: x, y: 0, width: thumbnailW, height: thumbnailW)
            thumbnailCell.imageView.image = thumbnail
            addSubview(thumbnailCell)
        }
    }
}
