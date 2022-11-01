//
//  VideoTrackPreview.swift
//  Photic
//
//  Created by lanht on 2022/10/6.
//

import UIKit

class VideoTrackPreview: UIView {

    var segmentViews = [VideoSegmentView]()
    
    lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .blue
        return bgView
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
        clipView.isHidden = true
        return clipView
    }()
    
    var totalW: CGFloat = 0

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
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        addGestureRecognizer(tap)
        
        addSubview(bgView)
        addSubview(audioWaveTrackView)
        
        bgView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        audioWaveTrackView.snp.makeConstraints { make in
            make.top.equalTo(bgView.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
            make.height.equalTo(34)
        }
    }
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        clipView.isHidden = !clipView.isHidden
        
        let location = tap.location(in: self)
        guard let target = self.segmentViews.filter({ $0.bounds.contains(location)  }).first else {
            return
        }
                
        clipView.frame = CGRect(x: target.frame.minX - 21, y: target.frame.minY - 1.5, width: target.frame.width + 42, height: target.frame.height + 3)
        addSubview(clipView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    @objc func buildSegmentViews(notifi: Notification) {
        guard let segments = notifi.userInfo?["segments"] as? [Segment] else {
            return
        }
        segmentViews.forEach { $0.removeFromSuperview() }
        segmentViews.removeAll()
        
        var x: CGFloat = bgView.frame.minX
        totalW = 0
        for segment in segments {
            let segmentW = CGFloat(segment.width)
            let segmentView = VideoSegmentView()
            segmentView.frame = CGRect(x: CGFloat(x), y: bgView.frame.minY, width: CGFloat(segmentW), height: bgView.bounds.height)
            segmentView.backgroundColor = .red
            addSubview(segmentView)
            segmentView.updateThumbnailView(segment.thumbnails)
            segmentViews.append(segmentView)
            
            x = x + segmentW
            
            totalW = totalW + segmentW
        }
    }
    
    func reLayoutSegments(scale: Float) {
        totalW = 0
        for segmentView in segmentViews {
            let segmW = segmentView.bounds.width * CGFloat(scale)
            segmentView.frame = CGRect(x: segmentView.frame.minX, y: segmentView.frame.minY, width: segmW, height: segmentView.frame.height)
//            segmentView.widthChange(width: segmW)
            totalW = totalW + segmW
        }
    }
    
    func segmentWidthChangeEnd() {
        var ws = [Float]()
        for segmentView in segmentViews {
            let w = Float(segmentView.bounds.width)
            ws.append(w)
        }
        EditorManager.shared.medialineWidthChangeEnd(ws: ws)
    }
}
