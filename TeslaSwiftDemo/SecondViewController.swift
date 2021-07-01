//
//  SecondViewController.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 04/03/16.
//  Copyright © 2016 Joao Nunes. All rights reserved.
//

import UIKit
import SwiftUI

class SecondViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
        
        let hostingView = UIHostingController(rootView: TeslaDemoAppView())
                                                //TeslaLoginView(url: URL(string: "https://www.tesla.com")!))
        
        self.addChild(hostingView)
        view.addSubview(hostingView.view)
        
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
    
        hostingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hostingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        hostingView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        hostingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        hostingView.didMove(toParent: self)
        
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

