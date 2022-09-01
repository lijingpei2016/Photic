//
//  MainEditView.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit

class MainEditView: UIView {
    let headerH = 44.0
    let bottomH = 44.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        let previewH = ScreenHeight - safeTop - safeBottom - headerH - bottomH

        let header = EditViewHeader()
        addSubview(header)
        
        let footer = EditViewFooter()
        addSubview(footer)
        
        let preview = EditPreview()
        addSubview(preview)
        
        let controlContainer = EditControlContainer()
        addSubview(controlContainer)
        
        header.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(headerH)
        }
        
        footer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(bottomH)
            make.bottom.equalTo(safeBottom)
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
