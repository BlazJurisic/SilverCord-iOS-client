//
//  ViewController.swift
//  SilverCordDemo
//
//  Created by Blaž Jurišić on 27/01/2018.
//  Copyright © 2018 COBE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BinderProtocol {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        bind(id: "TIME", bindCallback: self.bindDataToView)
    }
    
    //ovo je potrebno
    typealias T = TimeVCProps
    
    func bindDataToView(data: TimeVCProps) {
        dateLabel.text = data.time
        nameLabel.text = data.name
        timestampLabel.text = "\(data.timestamp)"
    }
}

struct TimeVCProps: Decodable {
    let name: String
    let time: String
    let timestamp: String
}
