//
//  ViewController.swift
//  ImageDiff
//
//  Created by Denys Iuzvyk on 1/13/17.
//  Copyright © 2017 duzvik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView {
        get {
            return self.view as! UIImageView
        }
    }
    
    override func loadView() {
        self.view = UIImageView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let t1 = Int64(Date().timeIntervalSince1970 * 1000)

        let imageDiff = ImageDiff(imageA: UIImage(named: "face-22")!, imageB: UIImage(named: "face-33")!)
        //let imageDiff = ImageDiff(imageA: UIImage(named: "test1")!, imageB: UIImage(named: "test2")!)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = imageDiff.compare()
        
        let t2 = Int64(Date().timeIntervalSince1970 * 1000)
        print("TIME => \(t2-t1) msec")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

