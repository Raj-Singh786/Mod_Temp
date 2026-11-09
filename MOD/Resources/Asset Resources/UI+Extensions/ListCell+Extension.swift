//
//  ListCell+Extension.swift
//  Rmpl
//
//  Created by Rajpal singh on 12/08/26.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func registerXIB(name:String) {
        self.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
    
    func emptyInfo(msg:String){
        
    }
}

extension UITableView {
    
    func registerXIB(name:String){
        self.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
    func emptyInfo(msg:String){
       
    }
}
