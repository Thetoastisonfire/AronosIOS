//
//  CharacterMovement.swift
//  Aronos2 iOS
//
//  Created by Aidan Weigel on 1/5/24.
//

import Foundation
import SpriteKit
import GameplayKit

extension GameScene {
    
    func startmoveAnimation() {
        let moveAnimation = SKAction.animate(with: playerMoveTextures, timePerFrame: 0.1)
        
        chara.run(/*SKAction.repeatForever*/(moveAnimation), withKey: "playerMoveAnimation")
    }
    
    
    
    //literally all of the movement code
    func updateDragDirection(lastTouchPosition: CGPoint, currentTouchPosition: CGPoint) {
        if isJumping {
            // If jumping, don't update movement
            dragDirection = CGVector(dx: 0, dy: 0).normalized()
            return
        }
        
        let dx = currentTouchPosition.x - lastTouchPosition.x
        let dy = currentTouchPosition.y - lastTouchPosition.y
        
        let dragVector = CGVector(dx: dx, dy: dy)
        let dragMagnitude = sqrt(pow(dragVector.dx, 2) + pow(dragVector.dy, 2))
        
        // Check if the drag vector magnitude is above a minimum threshold
        let minDragMagnitude: CGFloat = 10.0
        
        // Scale the drag vector based on its magnitude for slower movement when smaller
        var scaledDragVector = CGVector(dx: dragVector.dx, dy: dragVector.dy)
        
        if !hasSurpassedMinThreshold && dragMagnitude < minDragMagnitude {
            // If the drag vector is too small initially, don't update movement
            dragDirection = CGVector(dx: 0, dy: 0).normalized()
            return
        } else {
            hasSurpassedMinThreshold = true
            // Scale the drag vector only if it has surpassed the minimum threshold
            let scalingFactor: CGFloat = 0.02  // Adjust as needed
            scaledDragVector = CGVector(dx: dragVector.dx * scalingFactor, dy: dragVector.dy * scalingFactor)
        }
        
        dragDirection = scaledDragVector.normalized()
        
        // Calculate the angle in radians
        let angle = atan2(dragDirection!.dy, dragDirection!.dx)
        
        // Convert the angle to degrees
        let angleInDegrees = angle * 180.0 / CGFloat.pi
        
        // Check if the angle is within the jump range
        if dragDirection!.dy > 0 && abs(angleInDegrees) < jumpAngleThreshold {
            if !isCharacterInAir() {
                jump()
            }
            isJumping = true
        } else {
            // If not jumping, set drag direction to move horizontally
            dragDirection = CGVector(dx: scaledDragVector.dx, dy: 0).normalized()
            
            //animation
            if scaledDragVector.dx != 0 {
                    // If not jumping, set drag direction to move horizontally
                    dragDirection = CGVector(dx: scaledDragVector.dx, dy: 0).normalized()
                    
                    // Check if the player is not currently moving
    
                startmoveAnimation()
                isPlayerMoving = true  // Set the flag to indicate that the player is moving
            } else {
                // If the player is not moving, stop the move animation
                chara.removeAction(forKey: "playerMoveAnimation")
                isPlayerMoving = false  // Set the flag to indicate that the player is not moving
            }
           
            
            // chara animation
            if scaledDragVector.dx > 0 { //facing left
                chara.xScale = abs(chara.xScale)
            } else if scaledDragVector.dx < 0 { //facing right
                chara.xScale = -abs(chara.xScale)
            }
            
            
            // float down code
            if isCharacterInAir() && !isJumping {
                let descentForce: CGFloat = -50.0  // Adjust the value as needed
                chara.physicsBody?.applyForce(CGVector(dx: 0, dy: descentForce))
            }
        }
    }
    
    func jump() { //potential jump mechanics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 9.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        }
    }
    
    func isCharacterInAir() -> Bool {
        guard let charaPhysicsBody = chara.physicsBody else {
            return false //checking if we exist!
        }
        // Define a physics body category for the ground
        let groundCategory: UInt32 = 1 << 0  // You can adjust the bit mask as needed
        
        // Check if the character's physics body is in contact with the ground
        let contactedBodies = charaPhysicsBody.allContactedBodies()
        for contactedBody in contactedBodies {
            if contactedBody.categoryBitMask & groundCategory != 0 {
                // The character is in contact with the ground
                return false
            }
        }
        // No contact with the ground, character is in the air
        return true
    }
    /* //tank code DO NOT DELETE!!!
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let startPoint = startPoint else { return }
         let currentPoint = touches.first?.location(in: self)
         let delta = CGVector(dx: currentPoint!.x - startPoint.x, dy: currentPoint!.y - startPoint.y)
         
         //update the line based on drag
         updateDirectionLine(startPoint, delta)
         
     }
     
     //touch detected
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard !isBallMoving else { return } // Ignore new touches if the ball is still moving
         
         if let touchLocation = touches.first?.location(in: self){
             startPoint = touchLocation
             // not paused, or pausing, make direction line
             directionLine = SKShapeNode()
             addChild(directionLine!)
         }
     }
     
     //touch released
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let startPointl = startPoint, let currentPoint = touches.first?.location(in: self) else { return }
         
         //get final vector from starting touch location to end
         let delta = CGVector(dx: currentPoint.x - startPointl.x, dy: currentPoint.y - startPointl.y)
                 applyImpulseToBall(delta)
                 directionLine?.removeFromParent()
         startPoint = nil
     }
     */    
    
}


extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx*dx + dy*dy)
    }
}


extension CGVector {
    func normalized() -> CGVector {
           let length = sqrt(dx * dx + dy * dy)
           return CGVector(dx: dx / length, dy: dy / length)
       }
}


// Touch-based event handling
extension GameScene {


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isJumping = false  // Set the jump flag when the touch begins
            if let touch = touches.first {
                lastTouchPosition = touch.location(in: self)
            }
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first {
                let currentTouchPosition = touch.location(in: self)

                if let lastTouchPosition = lastTouchPosition {
                    updateDragDirection(lastTouchPosition: lastTouchPosition, currentTouchPosition: currentTouchPosition)
                }

                lastTouchPosition = currentTouchPosition
            }
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            if !isCharacterInAir(){
                isJumping = false  // Reset the jump flag when the touch ends
            }
            lastTouchPosition = nil
            dragDirection = nil
            hasSurpassedMinThreshold = false
        }
   
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
      
      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
     
      if ((firstBody.categoryBitMask & PhysicsCategory.wall != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.ball != 0)) {
          
         // run(wallHit) //wall hit effect
        }
      }
}
