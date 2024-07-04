
//
//  GameScene.swift
//  Aronos2 Shared
//
//  Created by Aidan Weigel on 12/29/23.
//
import Foundation
import SpriteKit
import GameplayKit


extension GameScene {
    
    
    func setupBall(_ origin: CGPoint) {
        createChara(position: origin)
    }
    
    func createChara(position: CGPoint) {
        
        chara = SKSpriteNode(texture: playerMoveTextures[0])  // Using first texture from playerMoveTextures
        chara.size = CGSize(width: 40, height: 70)
        chara.color = SKColor.white
        chara.position = CGPoint(x: 0.5, y: 0.5)
        chara.isHidden = false

        chara.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 50))
        chara.physicsBody?.affectedByGravity = true
        chara.physicsBody?.allowsRotation = false
        chara.physicsBody?.isDynamic = true
        chara.physicsBody?.friction = 15
        chara.physicsBody?.linearDamping = 1.5
        
        chara.physicsBody?.categoryBitMask = PhysicsCategory.ball
        chara.physicsBody?.contactTestBitMask = PhysicsCategory.wall
        chara.physicsBody?.collisionBitMask = PhysicsCategory.all
        chara.zPosition = 1
        addChild(chara)
        afterimageNodes = []

    }
    
    //afterimage effect the ball has
    func createAfterimageNode() {
        guard let chara = chara, isBallMoving else { return }

        let afterimageNode = SKShapeNode(circleOfRadius: 15)
        chara.color = SKColor.white
        afterimageNode.position = chara.position
        afterimageNode.zPosition = chara.zPosition - 1
        afterimageNode.alpha = 0.5

        addChild(afterimageNode)
        afterimageNodes.append(afterimageNode)
        // Limit the number of afterimage nodes
        if afterimageNodes.count > 5 {
            let removedNode = afterimageNodes.removeFirst()
            removedNode.removeFromParent()
        }
    }
    
    //helper function
    func removeAfterimages() {
        for afterimageNode in afterimageNodes {
            afterimageNode.removeFromParent()
        }
        afterimageNodes.removeAll()
    }
    
    //logic to adjust the direction line while dragging
    func updateDirectionLine(_ startPoint: CGPoint, _ delta: CGVector) {
        guard let directionLine = directionLine else { return }

        // position of line is the ball's position
        directionLine.position = chara.position

        // angle of rotation based on drag direction
        let angle = atan2(-delta.dy, -delta.dx)

        // set rotation of line
        directionLine.zRotation = angle

        // clean line
        directionLine.removeAllChildren()
        
        // length of vector with Pythagorean theorem
        let length = sqrt(delta.dx * delta.dx + delta.dy * delta.dy)

        // power based on lenght
        let power = min(length * 0.002, 1.0)

        // map power from green to red
        let color = UIColor(hue: CGFloat(0.33 - power * 0.33), saturation: 1.0, brightness: 1.0, alpha: 1.0)

        
        //make line
        let lineSegment = SKShapeNode(rectOf: CGSize(width: length, height: 2))
        lineSegment.position = CGPoint(x: length / 2, y: 0)
        lineSegment.strokeColor = SKColor(cgColor: color.cgColor)
        lineSegment.lineWidth = 2
        directionLine.addChild(lineSegment)
    }
    
    //send the ball flying
    func applyImpulseToBall(_ delta: CGVector) {
            let velocity = CGVector(dx: -delta.dx * 0.1, dy: -delta.dy * 0.1)
            chara.physicsBody?.applyImpulse(velocity)
    }
    
    //helper variables for many other funcitons
    var isBallMoving: Bool {
        guard let velocity = chara.physicsBody?.velocity else { return false }
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        return speed > 10
    }
    
    //if ball is to fast, it skips over the hole
    var isBallFast: Bool {
        guard let velocity = chara.physicsBody?.velocity else { return false }
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        return speed > 600
    }
    
}
