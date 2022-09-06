//
//  ControlTrackView.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit

class ControlTrackView: UIView {
    
    private lazy var content: UIScrollView = {
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
        content.delegate = self
        return content
    }()
    
    lazy var segmentView: SegmentView = {
        let segmentView = SegmentView(frame: CGRect(x: 0, y: segmentViewTop, width: 0, height: segmentViewH))
        segmentView.backgroundColor = .white
        return segmentView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
        
        EditViewObserver.observer.segmentImagesDidChange = { [self] count in
            self.content.contentOffset = CGPoint(x: -controlViewContentInset.left, y: 0)
            self.segmentView.frame = CGRect(x: 0, y: segmentViewTop, width: Double(count) * segmentViewH, height: segmentViewH)
            self.content.contentSize = CGSize(width: Double(Float(count)) * segmentViewH, height: 0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        
        addSubview(content)
        
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

extension ControlTrackView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("contentOffset.x --- \(scrollView.contentOffset.x)")

        let scale = abs((scrollView.contentOffset.x + controlViewContentInset.left) / scrollView.contentSize.width)
        print("scale --- \(scale)")
        EditViewObserver.observer.trackViewDidScroll?(scale)
    }
}
