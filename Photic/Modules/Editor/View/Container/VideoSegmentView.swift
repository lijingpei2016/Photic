//
//  SegmentView.swift
//  Photic
//
//  Created by Lanht on 2022/9/1.
//

import Foundation
import UIKit

class VideoSegmentView: UIView {
    
    lazy var content: UIView = {
        let content = UIView()
        content.clipsToBounds = true
        return content
    }()
    
    lazy var videoThumbnailView: VideoThumbnailView = {
        let videoThumbnailView = VideoThumbnailView()
        return videoThumbnailView
    }()
    
    lazy var images = Array<UIImage>()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func initSubViews() {
        
        addSubview(content)
        content.addSubview(videoThumbnailView)
        
        content.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(-2)
        }
        
        videoThumbnailView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
    }
    
    func updateThumbnailView(_ thumbnails: [UIImage]) {
        videoThumbnailView.snp.updateConstraints { make in
            make.width.equalTo(Float(thumbnails.count) * Float(thumbnailW))
        }
        videoThumbnailView.updateContent(thumbnails: thumbnails)
    }
    
    func widthChange(width: CGFloat) {
        videoThumbnailView.snp.updateConstraints { make in
            make.width.equalTo(width - 2)
        }
        
        let count = ceil((width - 2) / thumbnailW)
        videoThumbnailView.increaseCell(count: Int(count))
    }
}
