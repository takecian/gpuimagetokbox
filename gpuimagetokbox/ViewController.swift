//
//  ViewController.swift
//  gpuimagetokbox
//
//  Created by Fujiki Takeshi on 12/16/15.
//  Copyright © 2015 takecian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let viewModel = ViewModel()
    let button = UIButton()
    @IBOutlet weak var baseView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewModel.startCapture()
        viewModel.filterView.frame = baseView.frame
        baseView.addSubview(viewModel.filterView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startStreaming()
    }

    @IBAction func buttonTapped(sender: AnyObject) {
        viewModel.isInvert = !viewModel.isInvert
        viewModel.updateEffect()
    }
}

