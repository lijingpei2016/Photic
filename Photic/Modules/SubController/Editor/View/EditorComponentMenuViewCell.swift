//
//  EditViewFooterCell.swift
//  Photic
//
//  Created by lanht on 2022/10/3.
//

import UIKit
import SnapKit

class EditorComponentMenuViewCell: UICollectionViewCell {
    lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 10)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        
        icon.snp.makeConstraints { make in
            make.top.equalTo(13)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }
}
