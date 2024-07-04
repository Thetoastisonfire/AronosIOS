//
//  GameScene.swift
//  Aronos2 Shared
//
//  Created by Aidan Weigel on 1/2/24.
//

import SpriteKit
import GameplayKit
import CoreGraphics


class GameScene: SKScene {
    
    //basic character
    var chara: SKSpriteNode!
    var afterimageNodes: [SKShapeNode] = []
    var startPoint: CGPoint?
    var directionLine: SKShapeNode?
    var isPlayerMoving = false
    
    //movement vectors
    var dragDirection: CGVector?
    var lastTouchPosition: CGPoint?
   
    //jump trigger
    let jumpAngleThreshold: CGFloat = 45.0
    var isJumping = false  //jump state
    var hasSurpassedMinThreshold = false //initial drag vector bool
    
    //camera and stuff
    var cameraNode: SKCameraNode!
    var backgroundNode: SKNode!
    let cameraStuffOn = true  //if you want to turn camera off
    var minX: CGFloat = 0 //min camera bounds
    var maxX: CGFloat = 0
    var minY: CGFloat = 0 //max camera bounds
    var maxY: CGFloat = 0
    var minCharaX: CGFloat = 0 //min character bounds
    var maxCharaX: CGFloat = 0 //max character bounds
    
    
    var backgroundImage: SKSpriteNode! //background
    

    var label : SKLabelNode?

    
    struct ChunkInfo: Equatable {
        var chunkNode: SKNode
        var chunkCoordX: CGFloat
        var chunkCoordY: CGFloat
        
        static func == (lhs: ChunkInfo, rhs: ChunkInfo) -> Bool {
               return lhs.chunkNode == rhs.chunkNode
           }
    }
    
    
    var playerAtlas: SKTextureAtlas {
        return SKTextureAtlas(named: "Player")
    }
    
    var playerMoveTextures: [SKTexture] {
        return [
            playerAtlas.textureNamed("rect_frame_1"),
            playerAtlas.textureNamed("rect_frame_2"),
            playerAtlas.textureNamed("rect_frame_3"),
            playerAtlas.textureNamed("rect_frame_4"),
            playerAtlas.textureNamed("rect_frame_5"),
            playerAtlas.textureNamed("rect_frame_6"),
            playerAtlas.textureNamed("rect_frame_7"),
            playerAtlas.textureNamed("rect_frame_8"),
            playerAtlas.textureNamed("rect_frame_9"),
            playerAtlas.textureNamed("rect_frame_10")
        ]
    }
    
    var sunAtlas: SKTextureAtlas {
        return SKTextureAtlas(named: "Sun")
    }
    
    var sunTextures: [SKTexture] {
        return [
            sunAtlas.textureNamed("sun1"),
            sunAtlas.textureNamed("sun2"),
            sunAtlas.textureNamed("sun3"),
            sunAtlas.textureNamed("sun4"),
            sunAtlas.textureNamed("sun5")
        ]
    }
    
    var chunkInfoArray: [ChunkInfo] = [] //active chunks
    var chunkPool: [SKNode] = [] //inactive chunks
    var chunkPoolRight: [SKNode] = [] //inactive chunks but on the right
    
 
    let grassPalette = [SKColor(red: 85/255.0, green: 137/255.0, blue: 82/255.0, alpha: 1.0),
                        SKColor(red: 43/255.0, green: 137/255.0, blue: 47/255.0, alpha: 1.0),
                        SKColor(red: 137/255.0, green: 74/255.0, blue: 42/255.0, alpha: 1.0)] //light green, green, brown

    let heavenPalette = [SKColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1.0)] //off-white
    
    var noFloor = false//true  //turns off the floor
    var simpleFloor = true //turns off most of the floor
    var walkThroughTheGrass = true //makes it so character walks through top nodes
    
    //modular environment
    var currentEnvironment: BackgroundComponent?

    //for wall collision
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let all: UInt32 = UInt32.max
        static let wall: UInt32 = 0b1       // 1
        static let ball: UInt32 = 0b10      // 2
    }
    
    // this is where the screen border walls are set up
    private func setupPhysics() {
        let extendedFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width * 2, height: self.frame.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: extendedFrame)
        physicsBody?.friction = 0
        physicsBody?.restitution = 1.0
        // physicsWorld.contactDelegate = self
    }

// Reference to the currently active environment component
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isBallMoving {
            createAfterimageNode()
        } else {
            removeAfterimages()
        }
        
        guard let dragDirection = dragDirection else { return }

        let speed: CGFloat = 300.0
        let velocity = CGVector(dx: dragDirection.dx * speed, dy: dragDirection.dy * speed)

        chara.physicsBody?.velocity = velocity
        
        if cameraStuffOn {
            updateCameraPosition() // Update camera, but is also dealing with chunk stuff
            
            // Update the environment
            currentEnvironment?.updateBackground()
            
            if let cameraPosition = cameraNode?.position {
                // Move the background at a fraction of the camera's movement
                let parallaxFactor: CGFloat = 0.05  // Adjust this value for the desired parallax effect
                let backgroundMove = CGPoint(x: cameraPosition.x * parallaxFactor, y: -(chara.position.y * parallaxFactor) )

                // Enumerate through nodes and update positions
                backgroundImage.position = CGPoint(x: cameraPosition.x + backgroundMove.x, y: cameraPosition.y + backgroundMove.y)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        switchToHeavenEnvironment()
   //     switchToGrasslandEnvironment() //still wayyy too many nodes
   //     switchToNightEnvironment()     //wayyyyyyyy too many nodes
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.createFloor() //uhhhh idk if this is right
        setupPhysics()
        
        //the chamera and the bachrounch and the characherch
        if cameraStuffOn {
            setupCamera()
            setupBackground()
            setupInitialBounds()
        }
        setupBall(CGPoint(x: 0.5, y: 0.5))
    }
    
    //modular environments
    func switchToHeavenEnvironment() {
        let heavenEnvironment = HeavenBackground(gameScene: self)
        currentEnvironment = heavenEnvironment
        currentEnvironment?.setupBackground()
    }

    func switchToGrasslandEnvironment() {
        let grassEnvironment = GrasslandBackground(gameScene: self)
        currentEnvironment = grassEnvironment
        currentEnvironment?.setupBackground()
        // Additional night environment setup
       // (currentEnvironment as? GrasslandBackground)?.addStars()
    }
    
    func switchToNightEnvironment() {
        let nightEnvironment = NightBackground(gameScene: self)
        currentEnvironment = nightEnvironment
        currentEnvironment?.setupBackground()
    }
    
} //end of class
