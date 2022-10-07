//
//  EditorPlayHead.swift
//  Photic
//
//  Created by lanht on 2022/10/5.
//

import UIKit

class EditorPlayHead: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 1
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
