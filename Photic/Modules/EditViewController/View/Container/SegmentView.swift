//
//  SegmentView.swift
//  Photic
//
//  Created by Lanht on 2022/9/1.
//

import Foundation
import UIKit

class SegmentView: UIView {
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.bounds.height, height: self.bounds.height)
        
        let collection = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collection.dataSource = self
        collection.register(SegmentViewCell.self, forCellWithReuseIdentifier: "SegmentViewCell")
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if  {
//            addSubview(collection)
//        }
    }
    
    func initSubViews() {
        addSubview(collection)
    }
}

extension SegmentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "SegmentViewCell", for: indexPath)
        return cell
    }
    
}
