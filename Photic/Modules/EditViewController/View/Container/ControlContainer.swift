//
//  EditControlContainer.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit

class ControlContainer: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        let toolBar = ControlToolBar()
        addSubview(toolBar)
        
        let trackView = ControlTrackView()
        addSubview(trackView)
        
        toolBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        trackView.snp.makeConstraints { make in
            make.top.equalTo(toolBar.snp.bottom)
            make.right.bottom.left.equalToSuperview()
        }
    }
}
