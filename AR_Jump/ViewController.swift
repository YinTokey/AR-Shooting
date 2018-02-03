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

enum BitMaskCategory: Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController , ARSCNViewDelegate,ARSessionDelegate,SCNPhysicsContactDelegate {

    @IBOutlet weak var arscnView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 1
    let timer = Each(0.05).seconds
    var targetOren : SCNVector4!
    var Target: SCNNode?
    var value:Int!
    var didAddTarget:Bool!
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
        self.arscnView.session.delegate = self
        self.arscnView.scene.physicsWorld.contactDelegate = self
        
        didAddTarget = false

    }

    func createTarget(planeAnchor: ARPlaneAnchor) -> SCNNode {

        let targetScene = SCNScene(named: "Jump.scnassets/Target.scn")
  
        let targetNode = (targetScene?.rootNode.childNode(withName: "target", recursively: false))!
        targetNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        targetNode.eulerAngles = SCNVector3(270.degreesToRadians, 0, 0)

        let staticBody = SCNPhysicsBody.static()
        targetNode.physicsBody = staticBody
        targetNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        targetNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
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
        self.shootBullet()
        self.power = 1

    }
    
    func shootBullet(){
        guard let pointOfView = self.arscnView.pointOfView else {return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation

        let bullet = SCNNode(geometry: SCNSphere(radius: 0.02))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        body.restitution = 0.2
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        self.arscnView.scene.rootNode.addChildNode(bullet)
        bullet.runAction(
            SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                SCNAction.removeFromParentNode()])
        )
    }
    
    
    //ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        if(didAddTarget == false){
            let targetNode = createTarget(planeAnchor: planeAnchor)
            node.addChildNode(targetNode)
            didAddTarget = true
        }
  
        print("new flat surface detected, new ARPlaneAnchor added")
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("updating floor's anchor...")

        if(didAddTarget == false){
            let targetNode = createTarget(planeAnchor: planeAnchor)
            node.addChildNode(targetNode)
            didAddTarget = true
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else {return}
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        value = nodeA.physicsBody?.categoryBitMask
        
        print("@@@@@ \(value)")
        return
        
    }

    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
