//
//  SegmentClipView.swift
//  Photic
//
//  Created by lanht on 2022/10/7.
//

import UIKit

class SegmentClipView: UIView {

    lazy var left: UIView = {
        let l = UIView()
        l.backgroundColor = .white
        return l
    }()
    
    lazy var right: UIView = {
        let right = UIView()
        right.backgroundColor = .white
        return right
    }()
    
    lazy var top: UIView = {
        let top = UIView()
        top.backgroundColor = .white
        return top
    }()
    
    lazy var bottom: UIView = {
        let bottom = UIView()
        bottom.backgroundColor = .white
        return bottom
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(left)
        addSubview(right)
        addSubview(top)
        addSubview(bottom)
        
        left.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(self)
            make.width.equalTo(21)
        }
        
        right.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(self)
            make.width.equalTo(21)
        }
        
        top.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1.5)
        }
        
        bottom.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1.5)
        }
    }
}
