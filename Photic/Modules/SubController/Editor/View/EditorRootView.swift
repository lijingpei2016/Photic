//
//  MainEditView.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit
import AVFoundation

protocol EditRootViewDelegate: NSObjectProtocol {
    func showPhotoVC()
}

class EditRootView: UIView {
    var delegate: EditRootViewDelegate?
    
    var trackViewdidScroll: ((_ scale: Float) -> Void)?
    
    lazy var timer: Timer = {
        let timer = Timer(timeInterval: 1.0/16.0, repeats: true) { [weak self] timer in
            self?.autoScroll()
        }
        
        return timer
    }()
    
    lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(autoScroll))
        return displayLink
    }()
    
    lazy var playerLayoutView: PlayerLayoutView = {
        let playerLayoutView = PlayerLayoutView()
        playerLayoutView.backgroundColor = .white
        return playerLayoutView
    }()
    
    lazy var controlBar: EditorControlBar = {
        let controlBar = EditorControlBar()
        controlBar.backgroundColor = editorBackgroundColor
        controlBar.playBlock = {[weak self] in
//            if let timer = self?.timer {
//                timer.fire()
//                RunLoop.main.add(timer, forMode: .common)
//                RunLoop.main.run()
//            }
//            if let link = self?.displayLink {
//                link.add(to: RunLoop.current, forMode: .common)
//            }
            EditorManager.shared.play()
        }
        
        controlBar.pauseBlock = {
            EditorManager.shared.pause()
        }
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
    
    lazy var importBtn: UIButton = {
        let importBtn = UIButton(type: .custom)
        importBtn.setTitle("+", for: .normal)
        importBtn.setTitleColor(UIColor.black, for: .normal)
        importBtn.backgroundColor = .white
        importBtn.layer.cornerRadius = 3
        importBtn.addTarget(self, action: #selector(clickImportBtn), for: .touchUpInside)
        return importBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerPause), name: Notification.Name(kPlayerPlayDidPause), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelTimer() {
        
    }
    
    func initSubViews() {
        
        addSubview(playerLayoutView)
        
        addSubview(controlBar)
        
        addSubview(trackView)
        
        addSubview(playHead)
                
        trackView.addSubview(mediaTimeline)
        
        addSubview(importBtn)

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
        
        importBtn.snp.makeConstraints { make in
            make.right.equalTo(-5.5)
            make.top.equalTo(mediaTimeline).offset(83)
            make.size.equalTo(CGSize(width: 36, height: 36))
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
    
    @objc func autoScroll() {
        let maxOffsetX = mediaTimeline.content.bounds.width - mediaTimeline.bounds.width
        let offsetX = abs(mediaTimeline.contentOffset.x) + 0.2
        let targetX = min(maxOffsetX, offsetX)
        self.mediaTimeline.contentOffset = CGPoint(x: targetX, y: 0)
        if offsetX >= maxOffsetX {
    
//            self.timer.invalidate()
            displayLink.invalidate()
        }
    }
    
    @objc func playerPause() {
        controlBar.playBtnSetPause()
    }
    
    
    @objc func clickImportBtn(){
        self.delegate?.showPhotoVC()
    }
    
}

extension EditRootView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !EditorManager.shared.isPlaying {
            let scale = abs((scrollView.contentOffset.x) / scrollView.contentSize.width)
            EditorManager.shared.medialineDidScroll(scale: scale)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        EditorManager.shared.pause()
    }
}
