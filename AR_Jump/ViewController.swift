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
    
   
    func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode {
//        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(CGFloat(planeAnchor.extent.z))))
//        concreteNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "concrete")
//        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
//        concreteNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
//        concreteNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
//        let staticBody = SCNPhysicsBody.static()
//        concreteNode.physicsBody = staticBody
//        return concreteNode
        let concreteScene = SCNScene(named: "Jump.scnassets/Target.scn")
  
        let concreteNode = (concreteScene?.rootNode.childNode(withName: "target", recursively: false))!
        concreteNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        return concreteNode
    }
    
    //ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
        print("new flat surface detected, new ARPlaneAnchor added")
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("updating floor's anchor...")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
            
        }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
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
