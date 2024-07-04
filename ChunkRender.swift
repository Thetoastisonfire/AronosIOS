//
//  ChunkRender.swift
//  Aronos2 iOS
//
//  Created by Aidan Weigel on 1/2/24.
//

import Foundation
import SpriteKit

extension GameScene {
    
    //first renders chunk, then places it at specified coordinates
    func createChunk(xCoord: CGFloat, yCoord: CGFloat) {
            let pixelSize = (self.size.width + self.size.height) * 0.01
            let gridSize = 4 //makes x^2 chunk
         //   let chunkSize = 16.0//64.0 // this would change pixel size to be confined to chunk size
            let newChunk = SKNode()
            
            newChunk.isHidden = false
        
            let randomTexture = Int.random(in: 0...2)
        if !noFloor { //just disables floor and all its nodes for testing
            for row in 2..<gridSize {
                for col in 0..<gridSize {
                    let rect = SKShapeNode(rectOf: CGSize(width: pixelSize, height: pixelSize))
                    rect.position = CGPoint(x: col * Int(pixelSize), y: row * Int(pixelSize))
                    if (row == 3) {
                        if let currentEnvironment = currentEnvironment {
                            if currentEnvironment.environmentIdentifier == "Grassland" {
                                rect.fillColor = grassPalette[0] // top row
                            } else if currentEnvironment.environmentIdentifier == "Night" {
                                rect.fillColor = .lightGray // top row
                            }
                        }
                    } else {
                        if let currentEnvironment = currentEnvironment {
                            if currentEnvironment.environmentIdentifier == "Grassland" {
                                rect.fillColor = grassPalette[1] // top row
                            } else if currentEnvironment.environmentIdentifier == "Night" {
                                rect.fillColor = .gray // top row
                            }
                        }
                    }
                    rect.strokeColor = .clear
                    rect.isHidden = false
                    
                    var countRandomDeletions = 0
                    if randomTexture != 0 {
                        if row == 2 { // Add physics for the nodes in the almost top row; random deletion
                            
                            rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pixelSize, height: pixelSize))
                            rect.physicsBody?.isDynamic = false
                            rect.physicsBody?.categoryBitMask = PhysicsCategory.wall
                            rect.physicsBody?.contactTestBitMask = PhysicsCategory.ball
                            rect.physicsBody?.collisionBitMask = PhysicsCategory.all
                            rect.physicsBody?.usesPreciseCollisionDetection = true
                        }
                    }
                    if (row == 3 && !walkThroughTheGrass) || (walkThroughTheGrass && row == 2) { // Add physics only for the nodes in the top row
                        
                        rect.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pixelSize, height: pixelSize))
                        rect.physicsBody?.isDynamic = false
                        rect.physicsBody?.categoryBitMask = PhysicsCategory.wall
                        rect.physicsBody?.contactTestBitMask = PhysicsCategory.ball
                        rect.physicsBody?.collisionBitMask = PhysicsCategory.all
                        rect.physicsBody?.usesPreciseCollisionDetection = true
                    }
                    if randomTexture == 0 || row != 3 {
                        newChunk.addChild(rect)
                    } else if row == 3 {
                        if countRandomDeletions == Int.random(in: countRandomDeletions...randomTexture) {
                            newChunk.addChild(rect)
                        }
                        countRandomDeletions += 1
                    }
                }
            }

        }
        
            // Adjust the position of the chunk as needed
        newChunk.position = CGPoint.init(x: xCoord, y: yCoord)
        chunkInfoArray.append( ChunkInfo(chunkNode: newChunk, chunkCoordX:  newChunk.position.x, chunkCoordY: newChunk.position.y) )
        addChild(newChunk)
        }
    
    
    
    func removeChunksInWeirdPatterns() {
        for chunk in chunkInfoArray {
            
            let childCount = chunkInfoArray.last?.chunkNode.children.count ?? 0
            var processedChildCount = 0
            
            for rectangle in chunkInfoArray.last!.chunkNode.children { //chunk is 0-15, NOT 1-16
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
                let removeAction = SKAction.removeFromParent()
                let sequenceAction = SKAction.sequence([fadeOutAction, removeAction])
                
                if processedChildCount != childCount {
                    
                    if (processedChildCount == 0) || (processedChildCount == 5) || (processedChildCount == 10) || (processedChildCount == 15) { //exceptions to deletion
                        
                    } else { //deleted pieces of chunk
                        rectangle.run(sequenceAction)
                    }
                    // This closure will be executed when the actions on the current rectangle are completed
                    processedChildCount += 1
                } else if processedChildCount == childCount {
                    // This is the last child, remove the entire chunk
                    chunk.chunkNode.removeFromParent() //    chunk.removeFromParent()
                }
             /*   rectangle.run(sequenceAction) {
                    // This closure will be executed when the actions on the current rectangle are completed
                    processedChildCount += 1
                    
                    if processedChildCount == childCount {
                        // This is the last child, remove the entire chunk
                        chunk.removeFromParent()
                    }
                } */
            }
        }
        
        }//endofmethod
    
}
