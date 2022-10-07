//
//  EditViewFooter.swift
//  Photic
//
//  Created by lanht on 2022/8/28.
//

import UIKit

enum EditOption: String {
    case clip = "分割"
    case delete = "删除"
}

class EditorComponentMenuView: UIView {
    lazy var options = [EditOption.clip, EditOption.delete]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 90, height: editViewFooterH - safeBottom)
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EditViewFooterCell.self, forCellWithReuseIdentifier: String(describing: EditViewFooterCell.self))
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeBottom)
        }
    }
    
}

extension EditorComponentMenuView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EditViewFooterCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EditViewFooterCell.self), for: indexPath) as! EditViewFooterCell
        cell.titleLabel.text = options[indexPath.row].rawValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option: EditOption = options[indexPath.row]
//        switch option {
//        case .clip:
//            
//        case .delete:
//            
//        }
    }
}
