//
//  ViewController.swift
//  AR_Jump
//
//  Created by YinjianChen on 2018/1/19.
//  Copyright © 2018年 YinTokey. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController , ARSCNViewDelegate,ARSessionDelegate,SCNPhysicsContactDelegate {

    @IBOutlet weak var arscnView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var power: Float = 50
 
    var Target: SCNNode?
    var didAddTarget:Bool!
    var addButton:UIButton!
    var distance:Double = 0.0
    var scoreLabel:UILabel!
    var totalScore:Int = 0
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
        
        scoreLabel = UILabel.init(frame:CGRect(x: self.view.frame.size.width/2 - 40, y: 45, width: 80, height: 30))
        scoreLabel.font = UIFont.systemFont(ofSize: 20)
        scoreLabel.textColor = UIColor.black
        scoreLabel.text = "0"
        scoreLabel.textAlignment  = NSTextAlignment.center
        self.arscnView.addSubview(scoreLabel)
        
    }

      @objc func createTarget(){
        if(!didAddTarget){
            let targetScene = SCNScene(named: "Jump.scnassets/tar.scn")
            let targetNode = (targetScene?.rootNode.childNode(withName: "tar", recursively: false))!
            targetNode.position = SCNVector3(0,0,-5)
            targetNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: targetNode, options: nil))
            targetNode.scale = SCNVector3(1.9,1.9,1.9)
            targetNode.physicsBody?.categoryBitMask = 12
            targetNode.physicsBody?.contactTestBitMask = 1
            self.arscnView.scene.rootNode.addChildNode(targetNode)
            didAddTarget = true
            addButton.isHidden = true

        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
   
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.03))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
        bullet.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.blinn
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = 1
        bullet.physicsBody?.contactTestBitMask = 12
        self.arscnView.scene.rootNode.addChildNode(bullet)
        bullet.name = "bullet"
        bullet.runAction(
            SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                SCNAction.removeFromParentNode()])
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            if(self.distance > 0){
                self.calculateScore()
                self.distance = 0
                let soundID = SystemSoundID(kSystemSoundID_Vibrate)
                AudioServicesPlaySystemSound(soundID)
                self.scoreLabel.text = "\(self.totalScore)"
            }
            
        })

    }
    
    
    func calculateScore(){
        var score:Int = 0
        switch self.distance {
        case 0...0.05:
            score = 10
        case 0.051...0.10:
            score = 9
        case 0.101...0.15:
            score = 8
        case 0.151...0.20:
            score = 7
        case 0.201...0.25:
            score = 6
        case 0.251...0.30:
            score = 5
        case 0.301...0.35:
            score = 4
        case 0.351...0.40:
            score = 3
        case 0.401...0.45:
            score = 2
        case 0.451...0.50:
            score = 1
        default:
            score = 0
        }
        self.totalScore += score
    }

    
    func removebullet() {
        self.arscnView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "bullet" {
                node.removeFromParentNode()
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let point:SCNVector3 = contact.contactPoint
        print("----- \(point)")

        self.distance = sqrt(Double(point.x * point.x + point.y * point.y))

        self.removebullet()
    }

    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
