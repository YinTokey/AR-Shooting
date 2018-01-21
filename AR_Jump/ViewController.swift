//
//  ViewController.swift
//  AR_Jump
//
//  Created by YinjianChen on 2018/1/19.
//  Copyright © 2018年 YinTokey. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController , ARSCNViewDelegate {

    @IBOutlet weak var arscnView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.arscnView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.arscnView.session.run(configuration)
        self.arscnView.delegate = self
    }

    @IBAction func startClick(_ sender: Any) {
        
    }
    
  
    
    func addGeometric(_ position:SCNVector3,_ type:Int){
        
    }
    
    
    //ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}

    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
}

