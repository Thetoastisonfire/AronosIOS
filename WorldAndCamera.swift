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
            let rect = SKShapeNode(rectOf: CGSize(width: self.size.width * 5, height: pixelSize * 3))
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
    
    func spawnCloud() {
        let cloud = SKShapeNode(circleOfRadius: 50)
        cloud.fillColor = SKColor.white
        cloud.position = CGPoint(x: self.size.width * 2, y: CGFloat.random(in: 0.1 * (self.size.height/2)...0.9 * (self.size.height/2)) - (self.size.height/2) )
        addChild(cloud)
        clouds.append(cloud)
        cloud.zPosition = 2;
        // Define the actions
        let moveUntilAction = SKAction.moveTo(x: -self.size.width/2 - 200, duration: TimeInterval.random(in: 20.0...30.0))
        // Run the actions sequentially
        cloud.run(moveUntilAction) {
            // Remove the cloud when it completes the sequence
            cloud.removeFromParent()
            if let index = self.clouds.firstIndex(of: cloud) {
                self.clouds.remove(at: index)
            }
        }
    }
    
    func backgroundHeavenStuffMovingAndStuff() {
        let cloud = SKSpriteNode(imageNamed: "back2")
        cloud.position = CGPoint(x: self.size.width * 2, y: -(self.size.height/2) )
        addChild(cloud)
        cloud.zPosition = 2;
        // Define the actions
        let moveUntilAction = SKAction.moveTo(x: -self.size.width/2 - 200, duration: TimeInterval.random(in: 20.0...30.0))
        // Run the actions sequentially
        cloud.run(moveUntilAction) {
            // Remove the cloud when it completes the sequence
            cloud.removeFromParent()
        }
    }
    
    func makeTheHouse() {
        let couch = SKSpriteNode(imageNamed: "couach")
        couch.position = CGPoint(x: size.width/2 + 200, y: (-size.height/2) )
        couch.size = CGSize(width: 200, height: 100)
        couch.zPosition = 0
        addChild(couch)
        
        let pillar = SKSpriteNode(imageNamed: "pillar")
        pillar.position = CGPoint(x: size.width/4, y: -(chara.position.y))
       // pillar.size = CGSize(width: 100, height: 100)
        pillar.zPosition = 2
        addChild(pillar)
        
        
        let topFloor = SKShapeNode(rectOf: CGSize(width: size.width, height: ((size.width + size.height) * 0.01) * 3))
        topFloor.position = CGPoint(x: 0, y: -(chara.position.y))
        topFloor.zPosition = 0
        topFloor.fillColor = .white
        topFloor.zPosition = 1
        addChild(topFloor)
        
        let topFloorPhysicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: ((size.width + size.height) * 0.01) * 3))
        topFloorPhysicsBody.isDynamic = false
        topFloorPhysicsBody.categoryBitMask = PhysicsCategory.wall
        topFloorPhysicsBody.contactTestBitMask = PhysicsCategory.ball
        topFloorPhysicsBody.collisionBitMask = PhysicsCategory.all
        topFloorPhysicsBody.usesPreciseCollisionDetection = true
    }
    
    
    //didn't work how I wanted but could be used as like a sawblade or smth
  /*  func multiplyCharacter(origin: CGPoint) {
        for _ in 1...10 {
            let chara = SKShapeNode(rect: CGRect(x: 0.5, y: 0.5, width: 120, height: 210))
            chara.fillColor = SKColor.white
            chara.position = origin
            chara.isHidden = false

            chara.zPosition = 0
            addChild(chara)

            // Rotate the character 90 degrees initially
            chara.zRotation = CGFloat.pi / 2

            // Create and run rotate animation
            let rotateAnimation = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 2.0))
            chara.run(rotateAnimation, withKey: "playerRotateAnimation")
        }
    }*/


    
    
    
    
    //voxel code
    func createVoxelGrid(width: CGFloat, height: CGFloat) {
        let gridSize = CGSize(width: width, height: height)
            for _ in 0..<Int(gridSize.height) {
                var row: [Voxel] = []
                for _ in 0..<Int(gridSize.width) {
                    let voxel = Voxel(type: 0, color: .green) // Default voxel
                    row.append(voxel)
                }
                voxelGrid.append(row)
            }
        }
    
}//endofclass
