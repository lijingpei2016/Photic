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

//    var assertHelper: AssetHelper
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
            EditorManager.shared.clearSource()
        }
        return responseSubviewsView
    }()
        
    lazy var editorRootView: EditRootView = {
        let editorRootView = EditRootView()
        return editorRootView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.minimumLineSpacing = 6
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EditorComponentMenuViewCell.self, forCellWithReuseIdentifier: String(describing: EditorComponentMenuViewCell.self))
        return collectionView
    }()
    
    lazy var editOptions: [EditItem] = {
        let editOptions = [EditItem]()
        let clip = EditItem(option: .clip, image: "clip")
        let music = EditItem(option: .music, image: "music")
        let text = EditItem(option: .text, image: "text")
        let stickers = EditItem(option: .stickers, image: "stickers")
        let pictureIn = EditItem(option: .pictureIn, image: "pictureIn")
        let specialEffect = EditItem(option: .specialEffect, image: "specialEffects")
        let filter = EditItem(option: .filter, image: "filter")
        return [clip, music, text, stickers, pictureIn, specialEffect, filter]
    }()
    
    @objc init(asset: AVAsset) {
        self.asset = asset
        
//        assertHelper = AssetHelper(assert: asset)
        EditorManager.shared.clear()
        EditorManager.shared.addAsset(asset)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        
        updatePlayer()
    }
    
    func initViews() {
        view.addSubview(top)
        view.addSubview(responseSubviewsView)
        view.addSubview(editorRootView)
        view.addSubview(bottom)
        bottom.addSubview(collectionView)
        
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
        
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
    }

    func updatePlayer() {
        if let playerLayer = EditorManager.shared.previewLayer() {
            editorRootView.updatePlayer(playLayer: playerLayer)
        }
    }
    
    func showMenuView() {
        let clipItems = EditItemBuilder.builderClipItem()
        let menuView = EditorComponentMenuView(frame: .zero, menus: clipItems)
        self.view.addSubview(menuView)
        
        menuView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(editorMenuViewH)
        }
    }
}

extension EditAssetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editOptions.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EditorComponentMenuViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EditorComponentMenuViewCell.self), for: indexPath) as! EditorComponentMenuViewCell
//        cell.titleLabel.text = editOptions[indexPath.row].rawValue
        let item = editOptions[indexPath.row]
        cell.titleLabel.text = item.option.rawValue
        cell.icon.image = UIImage(named: item.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = editOptions[indexPath.row]
        switch item.option {
        case .clip:
            showMenuView()
            
        default:
            ()

        }
    }
}


