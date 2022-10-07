//
//  EditAssertViewController.swift
//  Photic
//
//  Created by lanht on 2022/9/4.
//

import UIKit
import SnapKit
import AVFoundation

class EditAssetViewController: UIViewController {

    var assertHelper: AssetHelper
    var asset: AVAsset
    
    lazy var top: UIView = {
        let top = UIView()
        top.backgroundColor = UIColor(hex: "#181818")
        return top
    }()
    
    lazy var bottom: UIView = {
        let bottom = UIView()
        bottom.backgroundColor = .black
        return bottom
    }()
    
    lazy var responseSubviewsView: ResponseSubviewsView = {
        let responseSubviewsView = ResponseSubviewsView()
        responseSubviewsView.backgroundColor = UIColor(hex: "#181818")
        responseSubviewsView.close = {[weak self] in
            self?.dismiss(animated: true)
        }
        return responseSubviewsView
    }()
        
    lazy var editorRootView: EditRootView = {
        let editorRootView = EditRootView()
        return editorRootView
    }()
    
    @objc init(asset: AVAsset) {
        self.asset = asset
        assertHelper = AssetHelper(assert: asset)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        
        updatePlayer()
        updatePreview()
    }
    
    func initViews() {
        view.addSubview(top)
        view.addSubview(responseSubviewsView)
        view.addSubview(editorRootView)
        view.addSubview(bottom)
        
        top.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(editorTopViewH)
        }
        
        responseSubviewsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(editorTopViewH)
            make.height.equalTo(editorResponseSubviewsViewH)
        }
        
        editorRootView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(responseSubviewsView.snp.bottom)
        }
        
        bottom.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(editorBottomH)
        }
    }

    func updatePlayer() {
        if let playerLayer = assertHelper.getPreviewLayer() {
            editorRootView.updatePlayer(playLayer: playerLayer)
        }
    }
    
    func updatePreview() {
        EditorManager.shared.addAsset(self.asset)
    }
}

//- (void)setupEditView {
//    MainEditView *mainEditView = [[MainEditView alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    [self.view addSubview:mainEditView];
//    _mainEditView = mainEditView;
//
//    [EditViewObserver observer].trackViewDidScroll = ^(CGFloat scale) {
//        if (self.assertHelper.getAssertSeconds == 0) {
//            return;
//        }
//
//        NSLog(@"seek time --- %f", self.assertHelper.getAssertSeconds * scale);
//
//        CMTime time = [self.assertHelper timeForAssertWithSeconds:self.assertHelper.getAssertSeconds * scale];
//        CMTimeShow(time);
//        [self.assertHelper seekTo:time];
//    };
//}


