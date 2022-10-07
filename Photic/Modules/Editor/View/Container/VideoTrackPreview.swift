//
//  VideoTrackPreview.swift
//  Photic
//
//  Created by lanht on 2022/10/6.
//

import UIKit

class VideoTrackPreview: UIView {

    var segmentViews = [VideoSegmentView]()
    
    lazy var segmentContainer: UIView = {
        let segmentContainer = UIView()
        return segmentContainer
    }()
    
    lazy var audioWaveTrackView: VideoAudioWaveTrackView = {
        let audioWaveTrackView = VideoAudioWaveTrackView()
        return audioWaveTrackView
    }()
    
    lazy var videoSegment: VideoSegmentView = {
        let videoSegment = VideoSegmentView()
        return videoSegment
    }()
    
    lazy var clipView: SegmentClipView = {
        let clipView = SegmentClipView()
        return clipView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(buildSegmentViews), name: NSNotification.Name(kSegmentDidChange), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(segmentContainer)
        addSubview(audioWaveTrackView)
        
        segmentContainer.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        audioWaveTrackView.snp.makeConstraints { make in
            make.top.equalTo(segmentContainer.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
            make.height.equalTo(34)
        }
    }
    
    @objc func buildSegmentViews(notifi: Notification) {
        guard let segments = notifi.userInfo?["segments"] as? [Segment] else {
            return
        }
        var x: Float = 0.0
        for segment in segments {
            let segmentW = segment.width()
            let segmentView = VideoSegmentView()
            segmentView.frame = CGRect(x: CGFloat(x), y: 0, width: CGFloat(segmentW), height: segmentContainer.bounds.height)
            segmentView.backgroundColor = .red
            segmentContainer.addSubview(segmentView)
            segmentView.updateThumbnailView(segment.thumbnails)
            segmentViews.append(segmentView)
            
            x = x + segmentW
        }
        
    }
}
