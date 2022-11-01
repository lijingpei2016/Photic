//
//  MainEditView.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit
import AVFoundation

class EditRootView: UIView {
    var trackViewdidScroll: ((_ scale: Float) -> Void)?
    
    lazy var playerLayoutView: PlayerLayoutView = {
        let playerLayoutView = PlayerLayoutView()
        playerLayoutView.backgroundColor = .white
        return playerLayoutView
    }()
    
    lazy var controlBar: EditorControlBar = {
        let controlBar = EditorControlBar()
        controlBar.backgroundColor = editorBackgroundColor
        return controlBar
    }()
    
    lazy var trackView: UIView = {
        let trackView = UIView()
        return trackView
    }()
    
    lazy var playHead: EditorPlayHead = {
        let playHead = EditorPlayHead()
        return playHead
    }()
    
    lazy var mediaTimeline: MediaTimeline = {
        let mediaTimeline = MediaTimeline()
        mediaTimeline.delegate = self
        return mediaTimeline
    }()
    
    lazy var editorPlayer: EditorPlayer = {
        let editorPlayer = EditorPlayer()
        editorPlayer.backgroundColor = .black
        return editorPlayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        
        addSubview(playerLayoutView)
        
        addSubview(controlBar)
        
        addSubview(trackView)
        
        addSubview(playHead)
                
        trackView.addSubview(mediaTimeline)

        playerLayoutView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(playLayoutViewH)
//            make.height.equalTo(playLayoutViewH)
        }
        
        controlBar.snp.makeConstraints { make in
            make.top.equalTo(playerLayoutView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(editorControlBarH)
        }
        
        // playLayoutViewH是动态的，trackViewH也是动态的，等后面搞懂规则再修改
        let trackViewH = ScreenHeight - editorTopViewH - editorResponseSubviewsViewH - playLayoutViewH - editorControlBarH - safeBottom
        trackView.snp.makeConstraints { make in
            make.top.equalTo(controlBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(trackViewH)
        }
        
        playHead.snp.makeConstraints { make in
            make.top.equalTo(mediaTimeline).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(2)
            make.height.equalTo(141)
        }
        
        mediaTimeline.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    func showPlayer() {
        editorPlayer.frame = self.playerLayoutView.bounds
        playerLayoutView.addSubview(editorPlayer)
    }
    
    func updatePlayer(playLayer: AVPlayerLayer) {
        let playerH = playLayoutViewH
        let bounds = CGRect(x: 0, y: 0, width: ScreenWidth, height: playerH)
        editorPlayer.frame = bounds
        playerLayoutView.addSubview(editorPlayer)
        
        playLayer.frame = bounds
        editorPlayer.layer.addSublayer(playLayer)
    }
}

extension EditRootView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scale = abs((scrollView.contentOffset.x) / scrollView.contentSize.width)
        EditorManager.shared.medialineDidScroll(scale: scale)
    }
}
