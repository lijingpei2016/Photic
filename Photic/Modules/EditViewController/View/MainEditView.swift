//
//  MainEditView.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit

class MainEditView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        let header = EditViewHeader()
        header.backgroundColor = .blue
        addSubview(header)
        
        let footer = EditViewFooter()
        footer.backgroundColor = .red
        addSubview(footer)
        
        let preview = EditPreview()
        preview.backgroundColor = .black
        addSubview(preview)
        
        let controlContainer = ControlContainer()
        controlContainer.backgroundColor = .gray
        addSubview(controlContainer)
        
        header.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(editViewHeaderH)
        }
        
        footer.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(editViewFooterH)
        }
        
        preview.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(previewH)
        }
        
        controlContainer.snp.makeConstraints { make in
            make.top.equalTo(preview.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(footer.snp.top)
        }
    }
}
