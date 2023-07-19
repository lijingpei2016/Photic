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
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(undoBtn)
        stackView.addArrangedSubview(redoBtn)
        stackView.addArrangedSubview(fullScreenBtn)
        return stackView
    }()
    
    lazy var undoBtn: UIButton = {
        let undoBtn = UIButton(type: .custom)
        undoBtn.setImage(UIImage(named: "undo_disable"), for: .disabled)
        undoBtn.setImage(UIImage(named: "undo"), for: .normal)
        undoBtn.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        undoBtn.isEnabled = false
        return undoBtn
    }()
    
    lazy var redoBtn: UIButton = {
        let redoBtn = UIButton(type: .custom)
        redoBtn.setImage(UIImage(named: "redo_disable"), for: .disabled)
        redoBtn.setImage(UIImage(named: "redo"), for: .normal)
        redoBtn.addTarget(self, action: #selector(redoAction), for: .touchUpInside)
        redoBtn.isEnabled = false
        return redoBtn
    }()
    
    lazy var fullScreenBtn: UIButton = {
        let fullScreenBtn = UIButton(type: .custom)
        fullScreenBtn.setImage(UIImage(named: "full_screen"), for: .normal)
        fullScreenBtn.addTarget(self, action: #selector(redoAction), for: .touchUpInside)
        return fullScreenBtn
    }()
    
    var playBlock: (() -> Void)?
    
    var pauseBlock: (() -> Void)?
    
    var isPlaying: Bool = false {
        didSet {
            playBtn.setImage(UIImage(named: (isPlaying ? "pause" : "play")), for: .normal)
        }
    }
    
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
        addSubview(stackView)
        
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
            make.width.equalTo(50)
        }
        
        stackView.snp.makeConstraints { make in
            make.right.equalTo(-6)
            make.top.bottom.equalToSuperview()
        }
        
        undoBtn.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }
        
        redoBtn.snp.makeConstraints { make in
            make.width.height.equalTo(undoBtn)
        }
        
        fullScreenBtn.snp.makeConstraints { make in
            make.width.height.equalTo(undoBtn)
        }
    }
    
    func playBtnSetPause() {
        self.isPlaying = false
    }
    
    @objc func playAction() {
        isPlaying ? pauseBlock?() : playBlock?()
        self.isPlaying = !self.isPlaying
    }
    
    @objc func undoAction() {
        
    }
    
    @objc func redoAction() {
        
    }
    
    @objc func fullScreenAction() {
        
    }
}
