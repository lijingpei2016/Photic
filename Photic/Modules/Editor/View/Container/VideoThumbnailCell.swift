//
//  VideoThumbnailCell.swift
//  Photic
//
//  Created by lanht on 2022/10/7.
//

import UIKit

class VideoThumbnailCell: UIView {

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}
