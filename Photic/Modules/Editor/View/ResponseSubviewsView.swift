//
//  ResponseSubviewsView.swift
//  Photic
//
//  Created by lanht on 2022/10/5.
//

import UIKit

class ResponseSubviewsView: UIView {

    lazy var closeBtn: UIButton = {
        let closeBtn = UIButton(type: .custom)
        closeBtn.backgroundColor = .clear
        closeBtn.setTitle(" X ", for: .normal)
        closeBtn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return closeBtn
    }()
    
    var close: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        addSubview(closeBtn)
        
        closeBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
        }
    }
    
    @objc func closeAction() {
        close?()
    }

}
