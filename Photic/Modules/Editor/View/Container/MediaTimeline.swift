//
//  MediaTimeline.swift
//  Photic
//
//  Created by lanht on 2022/10/5.
//

import UIKit

class MediaTimeline: UIScrollView {

    let contentViewDefaultW = ScreenWidth + 15
    
    var dH: CGFloat = 0
    
    lazy var content: UIView = {
        let content = UIView()
        content.backgroundColor = .black
        return content
    }()

    lazy var mediaTimelineContainer: MediaTimelineContainer = {
        let mediaTimelineContainer = MediaTimelineContainer()
        mediaTimelineContainer.lenthChange = { width in
            self.updateWidth(width: width)
        }
        return mediaTimelineContainer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(segmentsChange), name: Notification.Name(kSegmentDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerProgressChange), name: Notification.Name(kPlayerProgressDidChange), object: nil)

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
    
    func updateWidth(width: Float) {
        print("content.bounds.width = \(content.bounds.width)")
        let w = width + Float(ScreenWidth)
        content.snp.updateConstraints { make in
            make.width.equalTo(w)
        }
    }
    
    @objc func segmentsChange(notifi: Notification) {
        if let segments = notifi.userInfo?["segments"] as? [Segment] {
            let segW = segments.map({$0.width}).reduce(0, +)
            
            content.snp.updateConstraints { make in
                make.width.equalTo(Float(ScreenWidth) + Float(segW))
            }
        }
    }
    
    @objc func playerProgressChange(notifi: Notification) {
        if let progress = notifi.userInfo?["progress"] as? Float {
            let x = (mediaTimelineContainer.bounds.width - self.bounds.width) * CGFloat(progress)
            self.contentOffset = CGPoint(x: x, y: 0)
            

        }
    }
}

