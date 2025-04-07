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
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
        
        // scene size
        scene?.size = UIScreen.main.bounds.size
        
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        spaceShip.xScale = 0.7
        spaceShip.yScale = 0.7
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height )
        addChild(background)
        
        addChild(spaceShip)
        
        let asteroidCreate = SKAction.run {
            let asteroid = self.createAsteroid()
            self.addChild(asteroid)
        }
        let asteroidPerSecond: Double = 5
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0 / asteroidPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreate, asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        
        run(asteroidRunAction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            
            let distance = distanceCalculate(a: spaceShip.position, b: touchLocation)
            let speed: CGFloat = 500
            let time = timeToTravelDistance(distance: distance, speed: speed)
            let moveAction = SKAction.move(to: touchLocation, duration: time)
            
            spaceShip.run(moveAction)
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
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        
        return asteroid
    }
    
    override func update(_ currentTime: TimeInterval) {
        
//        let asteroid = createAsteroid()
//        addChild(asteroid)
//        
    }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "asteroid") { asteroid, stop in
            let hightScreen = UIScreen.main.bounds.height
            if asteroid.position.y < -hightScreen {
                asteroid.removeFromParent()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Contact")
    }

    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
}
