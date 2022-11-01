//
//  MediaTimelineContainer.swift
//  Photic
//
//  Created by lanht on 2022/10/6.
//

import UIKit

class MediaTimelineContainer: UIView {
    let trackPreviewDefaultH = 105
    
    var firstZoomPoint = CGPoint.zero
    var secondZoomPoint = CGPoint.zero
    var lastLength: Float = 0.0
    
    lazy var trackPreview: VideoTrackPreview = {
        let trackPreview = VideoTrackPreview()
        
        return trackPreview
    }()
    
    lazy var timelineRuler: MediaTimelineRuler = {
        let timelineRuler = MediaTimelineRuler()
        
        return timelineRuler
    }()
    
    var lenthChange: ((_ width: Float) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        let pinchGes = UIPinchGestureRecognizer.init(target: self, action:  #selector(pinchAction(pinchGes:)))
        self.addGestureRecognizer(pinchGes)
        
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
    
    @objc func pinchAction(pinchGes: UIPinchGestureRecognizer) {
        print("pinchGes.scale = \(pinchGes.scale)")

        // 滑动开始 记录一下当前cell的高度
        if pinchGes.state == .began {
            print("pinchGes.state == .began")
            lastLength = Float(pinchGes.view?.bounds.width ?? 0.0)
            
        } else if pinchGes.state == .changed {
            print("pinchGes.state == .changed")

            widthChange(scale: Float(pinchGes.scale))
            pinchGes.scale = 1

        } else {
            print("pinchGes.state == .end")

            widthChangeEnd()
        }
        
    }
    
    func widthChange(scale: Float) {

        trackPreview.reLayoutSegments(scale: scale)
        
        lenthChange?(Float(trackPreview.totalW))
    }
    
    func widthChangeEnd() {
        trackPreview.segmentWidthChangeEnd()
    }
    
    func length(from point1: CGPoint, to point2: CGPoint) -> Float {
        return hypotf(Float(abs(point1.x - point2.x)), Float(abs(point1.y - point2.y)))
    }
}
