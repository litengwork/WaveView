//
//  ViewController.swift
//  WaveView
//
//  Created by Fernando on 2018/6/5.
//  Copyright © 2018年 Liteng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainBackView: WaveView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        mainBackView.colors = [UIColor(rgba: 0xC3D800FF), UIColor(rgba: 0x99BC04B2), UIColor(rgba: 0xC3D800B2)]
        mainBackView.startElevation = 3.0
        mainBackView.fill(to: 0.8)
        mainBackView.startAnimation()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    


}

