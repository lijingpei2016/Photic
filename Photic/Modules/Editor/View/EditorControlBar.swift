//
//  ControlToolBar.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit

class EditorControlBar: UIView {

    lazy var playTimeLabel: UILabel = {
       let playTimeLabel = UILabel()
        playTimeLabel.textColor = .white
        playTimeLabel.font = UIFont.systemFont(ofSize: 12)
        playTimeLabel.text = "00:00"
        return playTimeLabel
    }()
    
    lazy var totalTimeLabel: UILabel = {
       let totalTimeLabel = UILabel()
        totalTimeLabel.textColor = .white.withAlphaComponent(0.5)
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.text = "/ 00:00"
        return totalTimeLabel
    }()
    
    lazy var playBtn: UIButton = {
        let playBtn = UIButton()
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        playBtn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return playBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        addSubview(playTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(playBtn)
        
        playTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
        }
        
        totalTimeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(playTimeLabel.snp.right)
        }
        
        playBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    @objc func playAction() {
        EditObserver.shared.play()
    }
}
