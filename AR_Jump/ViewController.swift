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

//enum BitMaskCategory: Int {
//    case bullet = 1
//    case target = 4
//}

class ViewController: UIViewController , ARSCNViewDelegate,ARSessionDelegate,SCNPhysicsContactDelegate {

    @IBOutlet weak var arscnView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 50
//    let timer = Each(0.05).seconds
    var Target: SCNNode?
    var didAddTarget:Bool!
    var addButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arscnView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.arscnView.session.run(configuration)
        self.arscnView.autoenablesDefaultLighting = true

        self.arscnView.delegate = self
        self.arscnView.session.delegate = self
        self.arscnView.scene.physicsWorld.contactDelegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.arscnView.addGestureRecognizer(gestureRecognizer)
        didAddTarget = false

        addButton = UIButton.init(frame: CGRect(x: self.view.frame.size.width - 170, y: self.view.frame.size.height - 170, width: 150, height: 60))
        addButton.setTitle("Add Target", for: UIControlState.normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 23)
        addButton.backgroundColor = UIColor.yellow
        addButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        addButton.addTarget(self, action: #selector(createTarget), for: UIControlEvents.touchUpInside)
        self.arscnView.addSubview(addButton)
        
    }

      @objc func createTarget(){
        if(!didAddTarget){
            let targetScene = SCNScene(named: "Jump.scnassets/tar.scn")
            let targetNode = (targetScene?.rootNode.childNode(withName: "tar", recursively: false))!
            targetNode.position = SCNVector3(0,0,-3)
            targetNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: targetNode, options: nil))
            targetNode.physicsBody?.categoryBitMask = 12
            targetNode.physicsBody?.contactTestBitMask = 1
            self.arscnView.scene.rootNode.addChildNode(targetNode)
            didAddTarget = true
            addButton.isHidden = true
        }
//        let scoreTen = targetNode.childNode(withName: "10", recursively: false)
//        let scoreNight = targetNode.childNode(withName: "9", recursively: false)
//        scoreTen?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: scoreTen!, options: nil))
//        scoreTen?.physicsBody?.categoryBitMask = 10
//        scoreTen?.physicsBody?.contactTestBitMask = 1

    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
      
        
            guard let sceneView = sender.view as? ARSCNView else {return}
            guard let pointOfView = sceneView.pointOfView else {return}
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            let position = orientation + location
            let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
            bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            bullet.position = position
            let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
            body.isAffectedByGravity = false
            bullet.physicsBody = body
            bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
            bullet.physicsBody?.categoryBitMask = 1
            bullet.physicsBody?.contactTestBitMask = 12
            self.arscnView.scene.rootNode.addChildNode(bullet)
            bullet.runAction(
                SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                    SCNAction.removeFromParentNode()])
            )
       
        
    }
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        timer.perform(closure: { () -> NextStep in
//            self.power = self.power + 1
//            return .continue
//        })
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.timer.stop()
//        self.shootBullet()
//        self.power = 1
//    }
    
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
        bullet.physicsBody?.categoryBitMask = 1
        bullet.physicsBody?.contactTestBitMask = 12
        self.arscnView.scene.rootNode.addChildNode(bullet)
        bullet.runAction(
            SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                SCNAction.removeFromParentNode()])
        )
    }
    
    
 
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        let nodeA = contact.nodeA
//        let nodeB = contact.nodeB
//        if nodeA.physicsBody?.categoryBitMask == 10 {
//            self.Target = nodeA
//        } else if nodeB.physicsBody?.categoryBitMask == 10 {
//            self.Target = nodeB
//        }
//
//        Target?.removeFromParentNode()
        print("----------------")
    //    return
        
    }

    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
