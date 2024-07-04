//
//  modularEnvironments.swift
//  Aronos2 iOS
//
//  Created by Aidan Weigel on 1/10/24.
//

import Foundation
import SwiftUI
import SpriteKit

// Protocol for a background component
protocol BackgroundComponent {
    var environmentIdentifier: String { get }
    func setupBackground()
    func updateBackground()
}
class wakeyWakeyProtocol: BackgroundComponent {
        weak var gameScene: GameScene?  // Reference to the GameScene
        
        var environmentIdentifier: String {
                return "Wakey"
            }
        
        init(gameScene: GameScene) {
            self.gameScene = gameScene
        }

    
        //so, I want it to start by the character lying sideways on the ground, and text slowly fades in
        //that says tap to wake up, and when you tap he will multiply into 10 different hims that all rotate continuously and eventually create a round looking shape similar to an eye, where the him that is standing upright will remain while everything else fades, and then he's in the house, zoomed in to the house size.
    
    
    //changing to just like, later adding soft crying or something, and then wake up fades in, and
    //when you tap the screen shakes and a wooooom sound plays and then it switches to the house
    func setupBackground() {
        guard let gameScene = gameScene else {
            return
        }
        gameScene.setupBall(CGPoint(x: 3000, y: 3000))
        gameScene.chara.isHidden = true;
        gameScene.chara.physicsBody?.friction = 9999;
        
        gameScene.backgroundImage = SKSpriteNode(texture: gameScene.sunTextures[2])
        gameScene.backgroundImage.isHidden = true;
        gameScene.backgroundColor = SKColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1.0)
        // Your existing setup code...

        let tapLabel = SKLabelNode(text: "Tap to wake up")
       
            tapLabel.position = CGPoint(x: 0, y: 0)
            tapLabel.alpha = 0.0
            tapLabel.fontSize = 30
            gameScene.addChild(tapLabel)
      
        // Create action to fade in the tap label after 5 seconds
        let waitAction = SKAction.wait(forDuration: 5.0)
        let fadeInAction = SKAction.fadeIn(withDuration: 2.0)
        let fadeInSequence = SKAction.sequence([waitAction, fadeInAction])
        tapLabel.run(fadeInSequence)

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapEnd(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            gameScene.view?.addGestureRecognizer(tapGesture)
    }

    @objc func handleTapEnd(_ sender: UITapGestureRecognizer) {
        guard let gameScene = gameScene else {
            return
        }

        // Remove tap label
        if let tapLabel = gameScene.childNode(withName: "TapLabel") {
            let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let sequenceAction = SKAction.sequence([fadeOutAction, removeAction])
            tapLabel.run(sequenceAction)
        }

        let shakeAction = SKAction.repeat(SKAction.sequence([
            SKAction.moveBy(x: -20, y: 0, duration: 0.1),
            SKAction.moveBy(x: 40, y: 0, duration: 0.1),
            SKAction.moveBy(x: -40, y: 0, duration: 0.1),
            SKAction.moveBy(x: 40, y: 0, duration: 0.1),
            SKAction.moveBy(x: -20, y: 0, duration: 0.1),
            SKAction.wait(forDuration: 1.5)
        ]), count: 4)

        gameScene.run(shakeAction, completion: {
            // Fade in transition to the next scene
            let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
            gameScene.run(fadeInAction, completion: {
                // Switch to a different scene after shaking
                gameScene.removeAllActions()
                gameScene.removeAllChildren()
               // gameScene.switchToHouseEnvironment()
                gameScene.switchToHeavenEnvironment()
            })
        })
    }




        func updateBackground() {
            // Update day background
            // ...
        }
    }

class HouseBackground: BackgroundComponent {
        weak var gameScene: GameScene?  // Reference to the GameScene
        
        var environmentIdentifier: String {
                return "House"
            }
        
        init(gameScene: GameScene) {
            self.gameScene = gameScene
        }

        func setupBackground() {
            guard let gameScene = gameScene else {
                return
            }
            gameScene.createVoxelGrid(width: gameScene.size.width, height: gameScene.size.width)
            gameScene.setupBall(CGPoint(x: 0.5, y: 0.7))
            
            
            gameScene.noFloor = true//true  //turns off the floor
            gameScene.simpleFloor = false //turns off most of the floor
            gameScene.walkThroughTheGrass = false //makes it so character walks through top nodes
            
            // Background color
            gameScene.backgroundColor = SKColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1.0)
            
            // Get label node from scene and store it for use later
            gameScene.label = gameScene.childNode(withName: "//helloLabel") as? SKLabelNode
            if let label = gameScene.label {
                label.alpha = 0.0
                label.run(SKAction.fadeIn(withDuration: 2.0))
            }
            
            // Add background image and animate it
            gameScene.backgroundImage = SKSpriteNode(texture: gameScene.sunTextures[2])
            
            gameScene.makeTheHouse()
            
            
            gameScene.chara.size = CGSize(width: 120, height: 210)
            
         /*   let rectPhysicsBody = SKPhysicsBody(rectangleOf: rect.frame.size)
            rectPhysicsBody.isDynamic = false
            rectPhysicsBody.categoryBitMask = PhysicsCategory.wall
            rectPhysicsBody.contactTestBitMask = PhysicsCategory.ball
            rectPhysicsBody.collisionBitMask = PhysicsCategory.all
            rectPhysicsBody.usesPreciseCollisionDetection = true*/
            
            
            if let cameraPosition = gameScene.cameraNode?.position {
                let backgroundMove = CGPoint(x: cameraPosition.x, y: -(gameScene.chara.position.y))
                gameScene.backgroundImage.position = CGPoint(x: cameraPosition.x + backgroundMove.x, y: cameraPosition.y + backgroundMove.y)
            } else {
                print("Camera not found")
            }
            gameScene.backgroundImage.size = CGSize(width: gameScene.size.width/2, height: gameScene.size.width/2)
            gameScene.backgroundImage.alpha = 1.0
            gameScene.backgroundImage.zPosition = -2
            gameScene.addChild(gameScene.backgroundImage)
            
            
        //    gameScene.setupBall(CGPoint(x: 0.5, y: 0.5))
        }

        func updateBackground() {
            // Update day background
            // ...
        }
    }

// Example implementation of a day background
class HeavenBackground: BackgroundComponent {
    weak var gameScene: GameScene?  // Reference to the GameScene
    
    var environmentIdentifier: String {
            return "Heaven"
        }
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }

    func setupBackground() {
        guard let gameScene = gameScene else {
            return
        }
        gameScene.setupBall(CGPoint(x: 0.5, y: 0.3))
        
        
        gameScene.noFloor = false//true  //turns off the floor
        gameScene.simpleFloor = true //turns off most of the floor
        gameScene.walkThroughTheGrass = true //makes it so character walks through top nodes
        
        // Background color
        gameScene.backgroundColor = SKColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1.0)
        
        // Get label node from scene and store it for use later
        gameScene.label = gameScene.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = gameScene.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Add background image and animate it
        gameScene.backgroundImage = SKSpriteNode(texture: gameScene.sunTextures[2])
        let changeTextureAction = SKAction.run {
            if gameScene.backgroundImage.texture == gameScene.sunTextures[2] {
                gameScene.backgroundImage.texture = gameScene.sunTextures[3]
            } else {
                gameScene.backgroundImage.texture = gameScene.sunTextures[2]
            }
        }
        gameScene.backgroundImage.size = CGSize(width: gameScene.size.width/2, height: gameScene.size.width/2)
        gameScene.backgroundImage.alpha = 1.0
        let waitAction = SKAction.fadeIn(withDuration: 2.0)
        let textureSwitchSequence = SKAction.sequence([waitAction, changeTextureAction])
        gameScene.backgroundImage.run(SKAction.repeatForever(textureSwitchSequence))
        
        gameScene.createFloor()
        
        if let cameraPosition = gameScene.cameraNode?.position {
            let backgroundMove = CGPoint(x: cameraPosition.x, y: -(gameScene.chara.position.y))
            gameScene.backgroundImage.position = CGPoint(x: cameraPosition.x + backgroundMove.x, y: cameraPosition.y + backgroundMove.y)
        } else {
            print("Camera not found")
        }
        
        gameScene.backgroundImage.zPosition = -1
        gameScene.addChild(gameScene.backgroundImage)
        
        
        

        // Action to spawn a new cloud
        var spawnCloudAction = SKAction.run(gameScene.spawnCloud)

        // Wait action for a random interval
        var waitAction2 = SKAction.wait(forDuration: TimeInterval.random(in: 2.0...5.0))

        // Sequence combining spawn and wait actions
        let spawnSequence = SKAction.sequence([spawnCloudAction, waitAction2])

        // Repeat the group action forever
        let repeatForeverAction = SKAction.repeatForever(spawnSequence)

        // Run the repeating action
        gameScene.run(repeatForeverAction)
        
        spawnCloudAction = SKAction.run(gameScene.backgroundHeavenStuffMovingAndStuff)
        waitAction2 = SKAction.wait(forDuration: TimeInterval.random(in: 6.0...10.0))
        
        gameScene.run(repeatForeverAction)
    
    }

    func updateBackground() {
        // Update day background
        // ...
    }
}

// Example implementation of a day background
class GrasslandBackground: BackgroundComponent {
    
    weak var gameScene: GameScene?  // Reference to the GameScene
    
    var environmentIdentifier: String {
            return "Grassland"
    }
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    func setupBackground() {
        guard let gameScene = gameScene else {
            return
        }
        
        gameScene.noFloor = false//true  //turns off the floor
        gameScene.simpleFloor = false //turns off most of the floor
        gameScene.walkThroughTheGrass = true //makes it so character walks through top nodes
        
        
        // Background color
        gameScene.backgroundColor = SKColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1.0)
        
        // Get label node from scene and store it for use later
        gameScene.label = gameScene.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = gameScene.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Add background image, no anim
        gameScene.backgroundImage = SKSpriteNode(imageNamed: "GrassBackground")
       
        gameScene.backgroundImage.size = CGSize(width: gameScene.size.width*2, height: gameScene.size.width/2 + 100)
        gameScene.backgroundImage.alpha = 1.0
        gameScene.createFloor()
        
        if let cameraPosition = gameScene.cameraNode?.position {
            let backgroundMove = CGPoint(x: cameraPosition.x, y: -(gameScene.chara.position.y))
            gameScene.backgroundImage.position = CGPoint(x: cameraPosition.x + backgroundMove.x, y: cameraPosition.y + backgroundMove.y)
        } else {
            print("Camera not found")
        }
        
        gameScene.backgroundImage.zPosition = -1
        gameScene.addChild(gameScene.backgroundImage)
        
        // Set up day background
        // ...
        
        
        
        gameScene.setupBall(CGPoint(x: 0.5, y: 0.5))
    }

    func updateBackground() {
        // Update day background
        // ...
    }
}

// Example implementation of a night background
class NightBackground: BackgroundComponent {
    
    weak var gameScene: GameScene?  // Reference to the GameScene
    
    var environmentIdentifier: String {
            return "Night"
        }
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    func setupBackground() {
        guard let gameScene = gameScene else {
            return
        }
        gameScene.setupBall(CGPoint(x: 0.5, y: 0.3))
        
        gameScene.noFloor = false//true  //turns off the floor
        gameScene.simpleFloor = false //turns off most of the floor
        gameScene.walkThroughTheGrass = false //makes it so character walks through top nodes
        
        // Background color
        gameScene.backgroundColor = SKColor(red: 32/255.0, green: 32/255.0, blue: 32/255.0, alpha: 1.0)
        
        // Get label node from scene and store it for use later
        gameScene.label = gameScene.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = gameScene.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Add background image and animate it
        gameScene.backgroundImage = SKSpriteNode(texture: gameScene.sunTextures[0])
        let changeTextureAction = SKAction.run {
            if gameScene.backgroundImage.texture == gameScene.sunTextures[1] {
                gameScene.backgroundImage.texture = gameScene.sunTextures[0]
            } else {
                gameScene.backgroundImage.texture = gameScene.sunTextures[1]
            }
        }
        gameScene.backgroundImage.size = CGSize(width: gameScene.size.width/2, height: gameScene.size.width/2)
        gameScene.backgroundImage.alpha = 1.0
        let waitAction = SKAction.fadeIn(withDuration: 2.0)
        let textureSwitchSequence = SKAction.sequence([waitAction, changeTextureAction])
        gameScene.backgroundImage.run(SKAction.repeatForever(textureSwitchSequence))
        
        gameScene.createFloor()
        
        if let cameraPosition = gameScene.cameraNode?.position {
            let backgroundMove = CGPoint(x: cameraPosition.x, y: -(gameScene.chara.position.y))
            gameScene.backgroundImage.position = CGPoint(x: cameraPosition.x + backgroundMove.x, y: cameraPosition.y + backgroundMove.y)
        } else {
            print("Camera not found")
        }
        
        gameScene.backgroundImage.zPosition = -1
        gameScene.addChild(gameScene.backgroundImage)
        
        
        
        gameScene.setupBall(CGPoint(x: 0.5, y: 0.5))
    }

    func updateBackground() {
        // Update night background
        // ...
    }

    // Additional methods specific to night background
    func addStars() {
        // Add stars
        // ...
    }
}
