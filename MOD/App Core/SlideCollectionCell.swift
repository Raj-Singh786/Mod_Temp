//
//  SlideCollectionCell.swift
//  MOD
//
//  Created by Rajpal singh on 06/11/26.
//


import UIKit
class SlideCollectionCell: UICollectionViewCell {
    
    static let identifier = String(describing: SlideCollectionCell.self
    )
    @IBOutlet weak var bannerImage: UIImageView!
    
    
    
    func setUP(slide: SlideStruct) {
        bannerImage.image = UIImage(named: slide.image)
        
    }
}
