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
    let timer = Each(0.05).seconds
    var Target: SCNNode?
    var didAddTarget:Bool!
    var addButton:UIButton!
    var targetsArray:Array<Any>!
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
            targetNode.position = SCNVector3(0,0,-6)
            targetNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: targetNode, options: nil))
            targetNode.scale = SCNVector3(1.5,1.5,1.5)
            targetNode.physicsBody?.categoryBitMask = 12
            targetNode.physicsBody?.contactTestBitMask = 1
//            self.arscnView.scene.rootNode.addChildNode(targetNode)
            didAddTarget = true
            addButton.isHidden = true
            
            for i in 1...10{
                self.addSmallTarget(i, targetNode)
            }

        }
    }
    
    func addSmallTarget(_ score:Int,_ bigTargetNode:SCNNode){
        let targetName = "\(score)"
     
        let z:Float = -3.0 + Float(0.002) * Float(score)
        let smallTarget = bigTargetNode.childNode(withName: targetName, recursively: false)
        smallTarget?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: smallTarget!, options: nil))
        smallTarget?.name = targetName
        smallTarget?.position = SCNVector3(0,0,z)
        smallTarget?.physicsBody?.categoryBitMask = 12 - score
        smallTarget?.physicsBody?.contactTestBitMask = 1
        self.arscnView.scene.rootNode.addChildNode(smallTarget!)

    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
   
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.03))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = 1
        bullet.physicsBody?.contactTestBitMask = 2|3|4|5|6|7|8|9|10|11
        self.arscnView.scene.rootNode.addChildNode(bullet)
        bullet.name = "bullet"
        bullet.runAction(
            SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                SCNAction.removeFromParentNode()])
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            if(self.distance > 0){
                self.calculateScore()
                self.distance = 0
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
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        timer.perform(closure: { () -> NextStep in
//            self.power = self.power + 1
//            return .continue
//        })
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.timer.stop()
//        self.shootDarts()
//        self.power = 1
//    }
    
    func shootDarts(){
        self.removeEveryOtherDarts()

        let dartScene = SCNScene(named: "Jump.scnassets/darts.scn")
        let dartNode = (dartScene?.rootNode.childNode(withName: "darts", recursively: false))!
        guard let pointOfView = self.arscnView.pointOfView else {return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation
        dartNode.position = position
        dartNode.scale = SCNVector3(0.07,0.07,0.07)
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: dartNode))
        body.isAffectedByGravity = false
        body.restitution = 0.2
        dartNode.name = "darts"
        dartNode.physicsBody = body
        dartNode.physicsBody?.applyForce(SCNVector3(orientation.x*power * 0.2, orientation.y*power * 0.2, orientation.z*power * 0.2), asImpulse: true)
        dartNode.physicsBody?.categoryBitMask = 1
        dartNode.physicsBody?.contactTestBitMask = 2|3|4|5|6|7|8|9|10|11
        self.arscnView.scene.rootNode.addChildNode(dartNode)
        dartNode.runAction(
            SCNAction.sequence([SCNAction.wait(duration: 5.0),
                                SCNAction.removeFromParentNode()])
        )
    }
    
    func removeEveryOtherDarts() {
        self.arscnView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "darts" {
                node.removeFromParentNode()
            }
        }
    }
    
    func removebullet() {
        self.arscnView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "bullet" {
                node.removeFromParentNode()
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {

        print("------point  \(contact.contactPoint)")
        let point:SCNVector3 = contact.contactPoint
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
