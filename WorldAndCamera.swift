//
//  WorldBuilder.swift
//  Aronos2 iOS
//
//  Created by Aidan Weigel on 1/4/24.
//

import Foundation
import SpriteKit
import GameplayKit

extension GameScene {
    
    func setupCamera() {
            cameraNode = SKCameraNode()
            camera = cameraNode
            addChild(cameraNode)
    }
    
    func setupInitialBounds() { //camera bounds
           // Set initial bounds based on the size of the scene
           minX = 0//-(self.size.width / 2)
           maxX = self.size.width*2  // this is the long one
           minY = -(self.size.height / 2)
           maxY = self.size.height/2
            
           minCharaX = -(self.size.width/2 )
           maxCharaX = self.size.width*2
    }
    
    func updateCameraPosition() {
        //this should check if any chunks were deleted, and add them to the other side of the screen
        
        updateChunks()
        // Assuming you want to follow a character or an object
        let desiredX = chara.position.x
        let desiredY = chara.position.y

        // Set constraints for character movement
        let clampedCharaX = max(minCharaX, min(desiredX, maxCharaX))
        let clampedCharaY = max(minY, min(desiredY, maxY))
        chara.position = CGPoint(x: clampedCharaX, y: clampedCharaY)

        // Set constraints for camera movement
        let clampedCameraX = max(minX, min(desiredX, maxX))

        // Apply the clamped position to the camera
        cameraNode.position = CGPoint(x: clampedCameraX, y: cameraNode.position.y)

        // Adjust background position based on the character's movement
        backgroundNode.position = CGPoint(x: chara.position.x, y: backgroundNode.position.y)
    }
    
    // Update method to be called in your game loop
    func updateChunks() {
        // Insert chunks into the scene
        insertChunks()
        insertChunksRight()

        // Remove chunks that are out of view
        removeOutOfViewChunks()
        removeOutOfViewChunksRight()
    }

    func insertChunks() {
        if let lastChunk = chunkPool.last {
            let lastChunkPosition = lastChunk.position
            
            if isChunkInViewCoordinateVersion(xCoord: lastChunkPosition.x, yCoord: lastChunkPosition.y) {
                // Add the chunkNode back to chunkInfoArray
                createChunk(xCoord: lastChunkPosition.x, yCoord: lastChunkPosition.y)
                chunkPool.removeLast()
            }
        }
    }

    func removeOutOfViewChunks() {
        let reversedChunkInfoArray = chunkInfoArray.reversed()

        for chunkInfo in reversedChunkInfoArray {
            let chunkNode = chunkInfo.chunkNode

            if !isChunkInView(chunkNode) {
                // Create a new node with the same properties as chunkNode
                let newChunk = SKNode()
                newChunk.position = CGPoint(x: chunkNode.position.x/* + chunkNode.calculateAccumulatedFrame().width*/, y: -(self.size.height/2) )

                // Copy properties, such as size, color, etc., from chunkNode to newChunk if needed

                // Add newChunk to chunkPool
                chunkPool.append(newChunk)

                // Remove chunkNode from chunkInfoArray
                if let index = chunkInfoArray.firstIndex(of: chunkInfo) {
                    chunkInfoArray.remove(at: index)
                }

                // Remove chunkNode from the scene
                chunkNode.removeFromParent()
            }
        }
    }

    func insertChunksRight() {
        if let lastChunk = chunkPool.first {
            let lastChunkPosition = lastChunk.position
            
            if isChunkInViewCoordinateVersion(xCoord: lastChunkPosition.x, yCoord: lastChunkPosition.y) {
                // Add the chunkNode back to chunkInfoArray
                createChunk(xCoord: lastChunkPosition.x, yCoord: lastChunkPosition.y)
                chunkPool.removeFirst()
            }
        }
    }

    func removeOutOfViewChunksRight() {
    
        for chunkInfo in chunkInfoArray {
            let chunkNode = chunkInfo.chunkNode

            if !isChunkInView(chunkNode) {
                // Create a new node with the same properties as chunkNode
                let newChunk = SKNode()
                newChunk.position = CGPoint(x: chunkNode.position.x/* + chunkNode.calculateAccumulatedFrame().width*/, y: -(self.size.height/2) )

                // Copy properties, such as size, color, etc., from chunkNode to newChunk if needed

                // Add newChunk to chunkPool
                chunkPool.append(newChunk)

                // Remove chunkNode from chunkInfoArray
                if let index = chunkInfoArray.firstIndex(of: chunkInfo) {
                    chunkInfoArray.remove(at: index)
                }

                // Remove chunkNode from the scene
                chunkNode.removeFromParent()
            }
        }
    }


    
    func isChunkInView(_ chunk: SKNode) -> Bool {
        guard let camera = cameraNode.scene?.camera else {
            // If the camera or chunk's parent is not available, assume the chunk is in view
            return true
        }
        guard let parent = chunk.parent else { //if no chunk parent then chunk is not in view
            return false
        }

        // Convert the chunk's position to the camera's coordinate system
        let chunkPositionInCamera = camera.convert(chunk.position, from: parent)

        // exaggerated camera view
        let cameraRect = CGRect(x: -(self.size.width / 2) - 100,
                                y: -(self.size.height),
                                width: maxX,
                                height: self.size.height)

        return cameraRect.contains(chunkPositionInCamera)
    }
    
    func isChunkInViewCoordinateVersion(xCoord: CGFloat, yCoord: CGFloat) -> Bool {
        guard let camera = cameraNode.scene?.camera, let parent = parent else {
                // If the camera, chunk's parent, or parent is not available, assume the chunk is in view
                return true
            }

        // Convert the chunk's position to the camera's coordinate system
        let chunkPositionInCamera = camera.convert(CGPoint(x: xCoord, y: yCoord), from: parent)

        // exaggerated camera view
        let cameraRect = CGRect(x: -(self.size.width / 2) - 100,
                                y: -(self.size.height),
                                width: maxX,
                                height: self.size.height)

        return cameraRect.contains(chunkPositionInCamera)
    }


    
    func setupBackground() {
        // Create and add your background node here
        // Adjust its size and content as needed
        backgroundNode = SKNode()
        cameraNode.addChild(backgroundNode)
        // Add background sprites, tiles, or any other elements
    }
    
    func createFloor() {
      //  self.anchorPoint = CGPoint(x: 0, y: 0)
        let areaSize = self.size.width*2 + 100 //max floor size
        var completedRenderArea: CGFloat = -(self.size.width / 2)// + 100 takes 1 off the left
        let pixelSize = (self.size.width + self.size.height) * 0.01
        let gridSize: CGFloat = 4
        var chunkCounter: CGFloat = 4
        
        if !noFloor {
            if !simpleFloor {
                while completedRenderArea < areaSize { //adds chunks 1 by 1 from left to right
                    createChunk(xCoord: completedRenderArea, yCoord:  -self.size.height/2) //should start render at bottom left corner
                    //I still can't get the y axis completely right
                    completedRenderArea = completedRenderArea + (pixelSize * gridSize) - 5
                    chunkCounter += 1;
                }
            }
        // Makes one big node instead of lots of tiny ones for the bottom 2 rows
            let rect = SKShapeNode(rectOf: CGSize(width: self.size.width * 10, height: pixelSize * 3))
            rect.position = CGPoint(x: -(self.size.width / 2), y: (-self.size.height / 2)) // bottom left
            
            //color
            if let currentEnvironment = currentEnvironment {
                if currentEnvironment.environmentIdentifier == "Grassland" {
                    rect.fillColor = grassPalette[2] // top row
                } else if currentEnvironment.environmentIdentifier == "Night" {
                    rect.fillColor = .darkGray // top row
                } else if currentEnvironment.environmentIdentifier == "Heaven" {
                        rect.fillColor = heavenPalette[0] // top row
                    }
                }
          //  rect.fillColor = grassPalette[2]
            rect.strokeColor = .clear
            rect.isHidden = false

            // Create a physics body
            let rectPhysicsBody = SKPhysicsBody(rectangleOf: rect.frame.size)
            rectPhysicsBody.isDynamic = false
            rectPhysicsBody.categoryBitMask = PhysicsCategory.wall
            rectPhysicsBody.contactTestBitMask = PhysicsCategory.ball
            rectPhysicsBody.collisionBitMask = PhysicsCategory.all
            rectPhysicsBody.usesPreciseCollisionDetection = true

            // Assign the physics body to the shape node
            rect.physicsBody = rectPhysicsBody

            addChild(rect)

        }
    }
    
}
