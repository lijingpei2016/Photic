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
        print(pinchGes.state)
        print(pinchGes.scale)
        print(pinchGes.velocity)
        
        // 滑动开始 记录一下当前cell的高度
        if pinchGes.state == .began {

        }
        
        // 滑动过程中 动态修改cell的宽度
        if (pinchGes.numberOfTouches) == 2 && (pinchGes.state == .changed){
            //计算当前捏合后cell的应该宽度
//            let tempHeight = cellLastHeight * pinchGes.scale
//            
//            if tempHeight != cellLastHeight && tempHeight >= 10 && tempHeight <= 30{
//                // 🔥计算捏合中心，根据中心点，确定放大位置
//                let pOne = pinchGes.location(ofTouch: 0, in: self)
//                let pTwo = pinchGes.location(ofTouch: 1, in: self)
//                let center = CGPoint.init(x: (pOne.x+pTwo.x)/2, y: (pOne.y+pTwo.y)/2)
//                
//                
//                // 🔥小学知识用到了 具体计算方式在文章中有讲
//                // 变化之前
//                let y1 = CGFloat(indexPath!.row) * KLineVM.sharedInstance.cellHeight;
//                let o1 = self.contentOffset.y;
//                let h1 = KLineVM.sharedInstance.cellHeight * 0.5;
//                
//                // 变化之后
//                let y2 = CGFloat(indexPath!.row) * tempHeight;
//                let h2 = tempHeight * 0.5;
//                
//                let o2 = y2 + h2 - y1 + o1 - h1;
//                
//                KLineVM.sharedInstance.cellHeight = tempHeight
//                self.reloadData()
//                // 修改偏移量 使中心点一直处于中心 注意设置 estimatedRowHeight、estimatedSectionHeaderHeight、estimatedSectionFooterHeight来保证contentOffset可用
//                self.contentOffset = CGPoint.init(x: 0, y: o2)
//    
//            }
        }
        
        if pinchGes.state == .ended ||  pinchGes.state == .recognized{

        }
        
    }
}
