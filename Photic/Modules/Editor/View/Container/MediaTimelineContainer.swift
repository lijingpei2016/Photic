//
//  MediaTimelineContainer.swift
//  Photic
//
//  Created by lanht on 2022/10/6.
//

import UIKit

class MediaTimelineContainer: UIView {
    let trackPreviewDefaultH = 105
    
    lazy var trackPreview: VideoTrackPreview = {
        let trackPreview = VideoTrackPreview()
        
        return trackPreview
    }()
    
    lazy var timelineRuler: MediaTimelineRuler = {
        let timelineRuler = MediaTimelineRuler()
        
        return timelineRuler
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(timelineRuler)
        addSubview(trackPreview)
        
        timelineRuler.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.left.right.equalTo(trackPreview)
            make.top.equalToSuperview()
        }
        
        let hMargin = ScreenWidth / 2
        trackPreview.snp.makeConstraints { make in
            make.top.equalTo(63)
            make.left.equalTo(hMargin)
            make.right.equalTo(-hMargin)
            make.height.equalTo(trackPreviewDefaultH)
        }
    }
}
