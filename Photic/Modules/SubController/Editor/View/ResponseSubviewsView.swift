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
    
    lazy var outputBtn: UIButton = {
        let outputBtn = UIButton(type: .custom)
        outputBtn.backgroundColor = UIColor(hex: "#FE2C55")
        outputBtn.setTitle("  导出  ", for: .normal)
        outputBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        outputBtn.addTarget(self, action: #selector(outputAction), for: .touchUpInside)
        outputBtn.layer.cornerRadius = 3
        return outputBtn
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
        addSubview(outputBtn)
        
        closeBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
        }
        
        outputBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
        }
        
    }
    
    @objc func closeAction() {
        close?()
    }
    
    @objc func outputAction() {
        
    }

}
