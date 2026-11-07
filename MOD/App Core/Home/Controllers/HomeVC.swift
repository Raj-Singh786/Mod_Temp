//
//  HomeVC.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import UIKit

class HomeVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

   
    @IBAction func didTapOnLocationBtn(_ sender: UIButton) {
        
    }
    
    
    private func initialSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerXIB(name: CardCell.identifier)
    }
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
   
}
