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
    
    lazy var muteButton: UIButton = {
        let muteButton = UIButton(type: .custom)
        muteButton.setTitle("关闭原声", for: .normal)
        muteButton.setTitleColor(.white, for: .normal)
        muteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return muteButton
    }()
    
    lazy var openCoverEditorButton: UIButton = {
        let openCoverEditorButton = UIButton(type: .custom)
        openCoverEditorButton.setTitle("设置\n封面", for: .normal)
        openCoverEditorButton.setTitleColor(.white, for: .normal)
        openCoverEditorButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        openCoverEditorButton.titleLabel?.numberOfLines = 0
        return openCoverEditorButton
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
        addSubview(muteButton)
        addSubview(openCoverEditorButton)
        
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
        
        openCoverEditorButton.snp.makeConstraints { make in
            make.top.equalTo(trackPreview).offset(15)
            make.right.equalTo(trackPreview.snp.left).offset(-30)
            make.width.height.equalTo(50)
        }
        
        muteButton.snp.makeConstraints { make in
            make.centerY.equalTo(openCoverEditorButton)
            make.right.equalTo(openCoverEditorButton.snp.left).offset(-10)
            make.width.equalTo(55)
            make.height.equalTo(40)
        }
    }
    
    @objc func muteBtnAction() {
        
    }
    
    @objc func coverBtnAction() {
        
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
