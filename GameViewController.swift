//
//  GameViewController.swift
//  Aronos2 iOS
//
//  Created by Aidan Weigel on 1/2/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SKViewDelegate {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayout(for: size)
    }
    
    func updateLayout(for size: CGSize) {
        // Perform any necessary layout adjustments for the new size or orientation
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()

            // Create an SKView
            let skView = SKView()

            // Set the view controller as the delegate
            skView.delegate = self

            // Configure the SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true

            // Load GameScene from SKS file
            guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
                print("Failed to load GameScene.sks")
                abort()
            }
      //  let scene = GameScene(size: view.bounds.size)
        
        // Set the scene size and scale mode
            scene.size = CGSize(width: view.bounds.width, height: view.bounds.height)
            scene.scaleMode = .aspectFill

            // Present the scene
            skView.presentScene(scene)

            // Set SKView as the root view
            self.view = skView
        }

    
    
    
   /* override func viewDidLoad() {
        super.viewDidLoad()

        let sceneSize = view.bounds.size
        print("Scene Size: \(sceneSize)")

        let scene = GameScene(size: sceneSize)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        print("View Frame Size: \(view.frame.size)")
        print("View Bounds Size: \(view.bounds.size)")
        skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
        
    }*/


    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

  /*  override var prefersStatusBarHidden: Bool {
        return true
    } */
}
