//
//  ViewController.swift
//  AR_Jump
//
//  Created by YinjianChen on 2018/1/19.
//  Copyright © 2018年 YinTokey. All rights reserved.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController , ARSCNViewDelegate {

    @IBOutlet weak var arscnView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 1
    let timer = Each(0.05).seconds
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer.perform(closure: { () -> NextStep in
            self.power = self.power + 1
            return .continue
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.timer.stop()
        self.shootDart()
        self.power = 1

    }
    
    func shootDart(){
        guard let pointOfView = self.arscnView.pointOfView else {return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation
        let dartsScene = SCNScene(named: "Jump.scnassets/darts.scn")
        let dartNode = (dartsScene?.rootNode.childNode(withName: "darts", recursively: false))!
        dartNode.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(node: dartNode))
        dartNode.eulerAngles = SCNVector3(-105.degreesToRadians, 0, 0)

        dartNode.physicsBody = body
        dartNode.name = "dart"
        body.restitution = 0.2
        dartNode.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        self.arscnView.scene.rootNode.addChildNode(dartNode)
        
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
