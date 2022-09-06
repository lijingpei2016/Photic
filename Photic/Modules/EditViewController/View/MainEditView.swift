//
//  MainEditView.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit
import AVFoundation

class MainEditView: UIView {
    var trackViewdidScroll: ((_ scale: Float) -> Void)?

    lazy var header: EditViewHeader = {
        let header = EditViewHeader()
        header.backgroundColor = .blue
        return header
    }()
    
    let footer: EditViewFooter = {
        let footer = EditViewFooter()
        footer.backgroundColor = .red
        return footer
    }()
    
    lazy var preview: EditPreview = {
        let preview = EditPreview()
        preview.backgroundColor = .black
        return preview
    }()
    
    lazy var controlContainer: ControlContainer = {
        let controlContainer = ControlContainer()
        controlContainer.backgroundColor = .gray
        
        return controlContainer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        
        addSubview(header)
        
        addSubview(footer)
        
        addSubview(preview)
        
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
    
    @objc func updatePreview(playLayer: AVPlayerLayer) {
        playLayer.frame = preview.bounds
        preview.layer.addSublayer(playLayer)
    }
}
