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
        if #available(iOS 11.3, *) {
            self.configuration.planeDetection = .vertical
        } else {
            // Fallback on earlier versions
            self.configuration.planeDetection = .horizontal

        }
        self.arscnView.session.run(configuration)
        self.arscnView.delegate = self
    }

    @IBAction func startClick(_ sender: Any) {
        var geometry:SCNGeometry
        switch ShapeType.random() {
        case .box:
            geometry = SCNBox(width: 0.01, height:0.01, length: 0.01, chamferRadius: 0.0)
        case .cylinder:
            geometry = SCNCylinder(radius: 02, height: 0.01)
        }
        geometry.materials.first?.diffuse.contents = UIColor.random()
        
        let geometyNode = SCNNode(geometry:geometry)
        geometyNode.position = SCNVector3(0.2,0,0)
        
        self.arscnView.scene.rootNode.addChildNode(geometyNode)
        
    }
    
   
    func createTarget(planeAnchor: ARPlaneAnchor) -> SCNNode {

        let targetScene = SCNScene(named: "Jump.scnassets/Target.scn")
  
        let targetNode = (targetScene?.rootNode.childNode(withName: "target", recursively: false))!
        targetNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        targetNode.eulerAngles = SCNVector3(270.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        targetNode.physicsBody = staticBody
        return targetNode
    }
    
    //ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let targetNode = createTarget(planeAnchor: planeAnchor)
        node.addChildNode(targetNode)
        print("new flat surface detected, new ARPlaneAnchor added")
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("updating floor's anchor...")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
            
        }
        let targetNode = createTarget(planeAnchor: planeAnchor)
        node.addChildNode(targetNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
            
        }
        
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
