//
//  GameViewController.swift
//  SpaceWar
//
//  Created by user on 18.03.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var gameScene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                
                gameScene = scene as? GameScene
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        gameScene.pauseButtonPressed(sender: sender)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
