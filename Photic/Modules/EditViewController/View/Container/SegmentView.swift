//
//  SegmentView.swift
//  Photic
//
//  Created by Lanht on 2022/9/1.
//

import Foundation
import UIKit

class SegmentView: UIView {
    lazy var images = Array<UIImage>()
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: segmentViewH, height: segmentViewH)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: segmentViewH), collectionViewLayout: layout)
        collection.dataSource = self
        collection.register(SegmentViewCell.self, forCellWithReuseIdentifier: "SegmentViewCell")
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
        
        EditViewObserver.observer.generatorImageCompletion = { images in
            self.images = images
            self.collection.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if  {
//            addSubview(collection)
//        }
        
//        collection.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: segmentViewH)
    }
    
    func initSubViews() {
        addSubview(collection)
        
        collection.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}

extension SegmentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SegmentViewCell = collection.dequeueReusableCell(withReuseIdentifier: "SegmentViewCell", for: indexPath) as! SegmentViewCell
        let image = self.images[indexPath.row]
        cell.imageView.image = image
        return cell
    }
    
}
