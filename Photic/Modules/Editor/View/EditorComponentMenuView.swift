//
//  EditViewFooter.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit
import SnapKit

enum ClipOption: String {
    case clip = "分割"
    case delete = "删除"
}

class EditorComponentMenuView: UIView {
//    lazy var options = [ClipOption.clip, ClipOption.delete]
    let menus: [EditMenuItem]
    lazy var backBgView: UIView = {
        let backBgView = UIView()
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.backgroundColor = .lightGray
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.layer.cornerRadius = 3
        backBgView.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(10)
            make.width.equalTo(32)
            make.height.equalTo(54)
            make.right.equalToSuperview()
        }
        return backBgView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 70)
        layout.minimumLineSpacing = 9
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EditorComponentMenuViewCell.self, forCellWithReuseIdentifier: String(describing: EditorComponentMenuViewCell.self))
        return collectionView
    }()
    
    init(frame: CGRect, menus: [EditMenuItem]) {
        self.menus = menus
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.backgroundColor = UIColor(hex: "#181818")
        self.addSubview(backBgView)
        self.addSubview(collectionView)
        
        backBgView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(backBgView.snp.right)
            make.top.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeBottom)
        }
    }
    
    @objc func backAction() {
        removeFromSuperview()
    }
    
}

extension EditorComponentMenuView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EditorComponentMenuViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EditorComponentMenuViewCell.self), for: indexPath) as! EditorComponentMenuViewCell
        let item = menus[indexPath.row]
        cell.titleLabel.text = item.option.rawValue
        cell.icon.image = UIImage(named: item.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = menus[indexPath.row]
//        switch option {
//        case .clip:
//            
//        case .delete:
//            
//        }
    }
}
