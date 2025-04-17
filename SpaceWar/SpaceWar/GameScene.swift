//
//  GameScene.swift
//  SpaceWar
//
//  Created by user on 18.03.2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceShipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1
    
    var spaceShip: SKSpriteNode!
    var score = 0
    var scoreLabel: SKLabelNode!
    var spaceBackground: SKSpriteNode!
    var asteroidLayer: SKNode!
    var starsLayer: SKNode!
    var gameIsPaused: Bool = false
    
    func pauseTheGame() {
        gameIsPaused = true
        self.asteroidLayer.isPaused = true
        physicsWorld.speed = 0
        starsLayer.isPaused = true
    }
    
    func pauseButtonPressed(sender: AnyObject) {
        if !gameIsPaused {
            pauseTheGame()
        } else {
            unpauseTheGame()
        }
    }
    
    func unpauseTheGame() {
        gameIsPaused = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
        starsLayer.isPaused = false
    }
    
    func resetTheGame() {
        score = 0
        scoreLabel.text = "Score: \(score)"
        
        gameIsPaused = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
        
        // scene size
        scene?.size = UIScreen.main.bounds.size
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        spaceShip.xScale = 0.7
        spaceShip.yScale = 0.7
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        
        let colorAction = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 1)
        let colorAction2 = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 1)
        
        let colorSequenceAnimation = SKAction.sequence([colorAction, colorAction2])
        let colorActionRepeat = SKAction.repeatForever(colorSequenceAnimation)
        
        spaceShip.run(colorActionRepeat)
        spaceBackground = SKSpriteNode(imageNamed: "background")
        spaceBackground.size = CGSize(width: width + 50, height: height + 50 )
        addChild(spaceBackground)
        
        //Stars
        let starPath = Bundle.main.path(forResource: "Stars", ofType: "sks")
        let starsEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: starPath!) as? SKEmitterNode
        starsEmitter?.zPosition = 1
        starsEmitter?.position = CGPoint(x: frame.midX, y: frame.height / 2)
        starsEmitter?.particlePositionRange.dx = frame.width
        starsEmitter?.advanceSimulationTime(10)
        
        starsLayer = SKNode()
        starsEmitter?.zPosition = 1
        addChild(starsLayer)
        
        starsLayer.addChild(starsEmitter!)
        addChild(spaceShip)
        
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 2
        addChild(asteroidLayer)
        
        let asteroidCreate = SKAction.run {
            let asteroid = self.createAsteroid()
            self.asteroidLayer.addChild(asteroid)
            asteroid.zPosition = 2
        }
        let asteroidPerSecond: Double = 1
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0 / asteroidPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreate, asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        
        self.asteroidLayer.run(asteroidRunAction)
        
        scoreLabel = SKLabelNode(text: "Score \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / scoreLabel.frame.size.width, y: 300)
        addChild(scoreLabel)
        
        spaceBackground.zPosition = 0
        spaceShip.zPosition = 1
        scoreLabel.zPosition = 3
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameIsPaused {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                
                let distance = distanceCalculate(a: spaceShip.position, b: touchLocation)
                let speed: CGFloat = 500
                let time = timeToTravelDistance(distance: distance, speed: speed)
                let moveAction = SKAction.move(to: touchLocation, duration: time)
                moveAction.timingMode = SKActionTimingMode.easeInEaseOut
                
                spaceShip.run(moveAction)
                
                let bgMoveAction = SKAction.move(to: CGPoint(x: -touchLocation.x / 100, y: -touchLocation.y / 100), duration: time)
                
                spaceBackground.run(bgMoveAction)
            }
        }
    }
    
    func distanceCalculate(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }
    
    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> TimeInterval {
        let time = distance / speed
        return TimeInterval(time)
    }
    
    func createAsteroid() -> SKSpriteNode {
        let asteroid = SKSpriteNode(imageNamed: "Asteroid")
        
        let randomScale = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 6)) / 5
        
        asteroid.xScale = randomScale
        asteroid.yScale = randomScale
        
        asteroid.position.x = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 16))
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.name = "asteroid"
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        
        let asteroidSpeedX: CGFloat = 150
        asteroid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3
        asteroid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * asteroidSpeedX
        
        return asteroid
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //        let asteroid = createAsteroid()
        //        addChild(asteroid)
        //
    }
    
    override func didSimulatePhysics() {
        asteroidLayer.enumerateChildNodes(withName: "asteroid") { asteroid, stop in
            let hightScreen = UIScreen.main.bounds.height
            if asteroid.position.y < -hightScreen {
                asteroid.removeFromParent()
                
                self.score = self.score + 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
}
