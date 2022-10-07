//
//  MediaTimeline.swift
//  Photic
//
//  Created by lanht on 2022/10/5.
//

import UIKit

class MediaTimeline: UIScrollView {

    let contentViewDefaultW = ScreenWidth + 15
    
    lazy var content: UIView = {
        let content = UIView()
        content.backgroundColor = .black
        return content
    }()

    lazy var mediaTimelineContainer: MediaTimelineContainer = {
        let mediaTimelineContainer = MediaTimelineContainer()
        return mediaTimelineContainer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(segmentsChange), name: NSNotification.Name(kSegmentDidChange), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(content)
        
        content.addSubview(mediaTimelineContainer)
        
        content.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(contentViewDefaultW)
        }
        
        mediaTimelineContainer.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    @objc func segmentsChange(notifi: Notification) {
        if let segments = notifi.userInfo?["segments"] as? [Segment] {
            let segW = segments.map({$0.width()}).reduce(0, +)
            
            content.snp.updateConstraints { make in
                make.width.equalTo(Float(ScreenWidth) + segW)
            }
        }
    }
}