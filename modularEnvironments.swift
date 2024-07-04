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
