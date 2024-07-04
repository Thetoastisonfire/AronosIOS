//
//  MenuScene.swift
//  Aronos2 iOS
//
//  Created by Aidan Weigel on 1/13/24.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreGraphics
import SwiftUI

class MenuScene: SKScene {
    
    
    private var initialTap: Bool = true
    
    private var titleBackground: SKSpriteNode?
    
    private var titleBackground2: SKSpriteNode?
    
    private var buttons: [SKShapeNode] = []
    
    var gameStarted = false

   
    func setupTitleScreen() {
        // Load the texture atlas directly in the scene
        let sunAtlas = SKTextureAtlas(named: "Sun")
        titleBackground = SKSpriteNode(texture: sunAtlas.textureNamed("sun1"))

        // Set the size based on the scene's height while maintaining the aspect ratio
        let newHeight = self.frame.size.height
        let newWidth = self.frame.size.height
        titleBackground?.size = CGSize(width: newWidth, height: newHeight)

        // Center the sprite in the scene
        titleBackground?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        titleBackground?.zPosition = -1
        addChild(titleBackground!)
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 32/255.0, green: 32/255.0, blue: 32/225.0, alpha: 1.0)
        setupTitleScreen()
    }
    
       override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           if initialTap {
               initialTap = false
               // Define the new size for the zoom effect
               let zoomSize = CGSize(width: self.size.width * 5, height: self.size.width * 5)

               // Create an SKAction for the zoom effect with ease-in-out timing mode
               let zoomAction = SKAction.resize(toWidth: zoomSize.width, height: zoomSize.height, duration: 1.0)
               zoomAction.timingMode = .easeInEaseOut

               // Run the zoom action on the titleBackground
               titleBackground?.run(zoomAction, completion: {
                           // Call a function to fade in your buttons
                           self.fadeInButtons()
                       })
           } else {
               backgroundColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
               
               guard let touch = touches.first else {
                   return
               }
               let touchLocation = touch.location(in: self)

               let radius: CGFloat = 45.0
               if findButton(at: touchLocation, withRadius: radius) {
                   
                   
                   // when button tapped
                   let sunAtlas = SKTextureAtlas(named: "Sun")
                   self.titleBackground2 = SKSpriteNode(texture: sunAtlas.textureNamed("menu1"))
                   self.titleBackground2?.zPosition = 0
                   let zoomSize = CGSize(width: self.size.width * 5, height: self.size.width * 5)

                   // Create an SKAction for the zoom effect with ease-in-out timing mode
                   let zoomAction = SKAction.resize(toWidth: zoomSize.width, height: zoomSize.height, duration: 1.0)
                   self.titleBackground2?.run(zoomAction)
                   self.addChild(self.titleBackground2!)
                   self.titleBackground?.isHidden = true
                   
                   for button in buttons {
                       button.isHidden = true
                   }
                   let zoomOut = CGSize(width: 1, height: 1)
                   let zoomOutAction = SKAction.resize(toWidth: zoomOut.width, height: zoomOut.height, duration: 1.0)
                   self.titleBackground2?.run(zoomOutAction) {
                       // Assuming GameViewController is instantiated
                       self.titleBackground2?.isHidden = true
                       self.run(SKAction.colorize(with: .black, colorBlendFactor: 1.0, duration: 1.0)) {
                           self.transitionToGameScene()
                       }
                   }
                   
               }
           }
       }
    
    func fadeInButtons() {
        buttons = [
            spawnButton(xCoord: -50, yCoord: 20),
            spawnButton(xCoord: -170, yCoord: -20),
            spawnButton(xCoord: 70, yCoord: -20)
        ]

        for button in buttons {
            button.alpha = 0.0
            button.zPosition = 1
            addChild(button)
            
            let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
            button.run(fadeInAction)
        }
    }

    func spawnButton(xCoord: CGFloat, yCoord: CGFloat) -> SKShapeNode {
        // Create a rounded rectangle shape for the button
        let buttonSize = CGSize(width: 100, height: 100)
        let cornerRadius: CGFloat = 15.0
        
        let buttonShape = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: buttonSize), cornerRadius: cornerRadius)
        buttonShape.fillColor = SKColor.black
        buttonShape.strokeColor = SKColor.black
        buttonShape.position = CGPoint(x: xCoord, y: yCoord)
        buttonShape.name = "startButton"
        
        // Create and position the label within the shape
        let label = SKLabelNode(text: "New Game")
        label.fontSize = 18
        label.fontColor = SKColor.white
        label.fontName = "HelveticaNeue-Regular"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: buttonShape.frame.midX - buttonShape.frame.origin.x, y: buttonShape.frame.midY - buttonShape.frame.origin.y)
        // Use bounds instead of frame for the label position
        
        buttonShape.addChild(label)

        return buttonShape
    }

    
    func findButton(at location: CGPoint, withRadius radius: CGFloat) -> Bool {
        // Find button within the specified radius
        for case let button as SKShapeNode in self.nodes(at: location) {
            let buttonFrame = button.frame
            if buttonFrame.contains(location) {
                return true
            }
        }
        return false
    }
    
    func transitionToGameScene() {
        // Ensure that the scene's view is not nil
        guard let sceneView = self.view else {
            print("Scene view is nil.")
            return
        }
        
        // Create a reveal transition
        let reveal = SKTransition.reveal(with: .down, duration: 2)
        
        // Create a new instance of GameScene
        let newScene = GameScene(size: sceneView.bounds.size)
        
        // Present the new scene with the reveal transition
        sceneView.presentScene(newScene, transition: reveal)
    }

}
