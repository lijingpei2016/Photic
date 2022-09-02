//
//  ControlTrackView.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit

class ControlTrackView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        let content = UIScrollView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: controlViewH))
        content.showsVerticalScrollIndicator = false
        content.showsHorizontalScrollIndicator = false
        content.alwaysBounceHorizontal = true
        if #available(iOS 13.0, *) {
            content.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            content.contentInsetAdjustmentBehavior = .never
        }
        content.contentInset = controlViewContentInset
        addSubview(content)
        
        let segmentView = SegmentView(frame: CGRect(x: 0, y: segmentViewTop, width: 100, height: segmentViewH))
        segmentView.backgroundColor = .white
        content.addSubview(segmentView)
        content.contentSize = CGSize(width: segmentView.frame.width, height: 0)

        let centerLine = UIView()
        centerLine.backgroundColor = .white
        addSubview(centerLine)

        centerLine.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalTo(centerLineTop)
            make.width.equalTo(2)
            make.height.equalTo(centerLineH)
        }
    }

}
