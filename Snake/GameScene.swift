//
//  GameScene.swift
//  Snake
//
//  Created by Shizheng Yang on 2018/12/10.
//  Copyright © 2018 haleyysz. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var tip: SKLabelNode!
    var logo: SKLabelNode!
    var gameOver: SKLabelNode!
    var highScore: SKLabelNode!
    var breakLine: SKShapeNode!
    var currentScore: SKLabelNode!
    var gameBackground: SKShapeNode!
    var background: SKSpriteNode!
    var dPadBtn: SKSpriteNode!
    
    var game: GameManager!
    var scorePosition: CGPoint?
    var snakePosition: [(Int, Int)] = []
    var snakeArray: [(SKShapeNode, x: Int, y: Int)] = []
    
    override func didMove(to view: SKView) {
        initializeGame()
        game = GameManager(gameScene: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        game.update(time: currentTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node.name == "start" {
                    game.vibrate()
                    startGame()
                }
                if node.name == "left" {
                    game.vibrate()
                    game.move(direction: "left")
                }
                if node.name == "up" || node.name == "aBtn" {
                    game.vibrate()
                    game.move(direction: "up")
                }
                if node.name == "right" || node.name == "bBtn" {
                    game.vibrate()
                    game.move(direction: "right")
                }
                if node.name == "down" {
                    game.vibrate()
                    game.move(direction: "down")
                }
            }
        }
    }
    
    // [1] Initialize game
    private func initializeGame() {
        // Create game logo
        logo = SKLabelNode(fontNamed: "Chalkduster")
        logo.zPosition = 2
        logo.position = CGPoint(x: 0, y: 300)
        logo.fontColor = .black
        logo.text = "SNAKE"
        logo.fontSize = 100
        self.addChild(logo)
        
        // Create gameOver logo
        gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.zPosition = 2
        gameOver.position = CGPoint(x: 0, y: frame.size.height)
        gameOver.fontColor = .black
        gameOver.text = "GAME OVER"
        gameOver.fontSize = 80
        self.addChild(gameOver)
        
        // Create high score label
        highScore = SKLabelNode(fontNamed: "Chalkduster")
        highScore.zPosition = 2
        highScore.position = CGPoint(x: 0, y: 200)
        highScore.fontSize = 40
        highScore.text = "High Score: \(UserDefaults.standard.integer(forKey: "highScore"))"
        highScore.fontColor = .black
        self.addChild(highScore)
        
        // Create current score label
        currentScore = SKLabelNode(fontNamed: "Chalkduster")
        currentScore.zPosition = 1
        currentScore.fontSize = 30
        currentScore.fontColor = .black
        currentScore.isHidden = true
        self.addChild(currentScore)
        
        // Create tip label
        tip = SKLabelNode(fontNamed: "Verdana")
        tip.zPosition = 2
        tip.position = CGPoint(x: 0, y: 0)
        tip.fontSize = 20
        tip.text = "Press START to play"
        tip.fontColor = .black
        gameOver.isHidden = false
        self.addChild(tip)
        
        // Create background
        background = SKSpriteNode(imageNamed: "gameboy5.png")
        background.zPosition = 0
        background.size = frame.size
        self.addChild(background)
        
        // Create D-pad button
        dPadBtn = SKSpriteNode(imageNamed: "gameboy-D-pad.png")
        dPadBtn.zPosition = 1
        dPadBtn.setScale(1.141)
        dPadBtn.position = CGPoint(x: -220, y: -285)
        background.addChild(dPadBtn)
        
        let aBtn = SKSpriteNode(imageNamed: "A-B-button.png")
        aBtn.name = "aBtn"
        aBtn.zPosition = 1
        aBtn.position = CGPoint(x: 288, y: -245)
        background.addChild(aBtn)
        
        let bBtn = SKSpriteNode(imageNamed: "A-B-button.png")
        bBtn.name = "bBtn"
        bBtn.zPosition = 1
        bBtn.position = CGPoint(x: 162, y: -305)
        background.addChild(bBtn)
        
        let startBtn = SKSpriteNode(imageNamed: "gameboy-start-btn.png")
        startBtn.name = "start"
        startBtn.zPosition = 1
        startBtn.position = CGPoint(x: 40, y: -401)
        startBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startBtn.zRotation = .pi / 6.75
        background.addChild(startBtn)
        
        let menuBtn = SKSpriteNode(imageNamed: "gameboy-start-btn.png")
        menuBtn.name = "menuBtn"
        menuBtn.zPosition = 1
        menuBtn.position = CGPoint(x: -90, y: -401)
        menuBtn.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        menuBtn.zRotation = .pi / 6.75
        background.addChild(menuBtn)
        
        initializeGameView()
    }
    
    // [2] Initialize game view
    private func initializeGameView() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: frame.size.width / -2.2 - 2, y: (frame.size.height / 3) + 90))
        path.addLine(to: CGPoint(x: frame.size.width / 2.2 + 2, y: (frame.size.height / 3) + 90))
        breakLine = SKShapeNode(path: path)
        breakLine.zPosition = 1
        breakLine.strokeColor = .black
        breakLine.lineWidth = 2
        breakLine.isHidden = true
        background.addChild(breakLine)
        
        // Create left button shape
        let leftBtn = SKShapeNode(rectOf: CGSize(width: 120, height: 100))
        leftBtn.name = "left"
        leftBtn.zPosition = 1
        leftBtn.fillColor = .clear
        leftBtn.position = CGPoint(x: -300, y: -286)
        background.addChild(leftBtn)
        
        // Create up button shape
        let upBtn = SKShapeNode(rectOf: CGSize(width: 100, height: 120))
        upBtn.name = "up"
        upBtn.zPosition = 1
        upBtn.fillColor = .clear
        upBtn.position = CGPoint(x: -220, y: -208)
        background.addChild(upBtn)
        
        // Create right button shape
        let rightBtn = SKShapeNode(rectOf: CGSize(width: 120, height: 100))
        rightBtn.name = "right"
        rightBtn.zPosition = 1
        rightBtn.fillColor = .clear
        rightBtn.position = CGPoint(x: -140, y: -286)
        background.addChild(rightBtn)
        
        // Create down button shape
        let downBtn = SKShapeNode(rectOf: CGSize(width: 100, height: 120))
        downBtn.name = "down"
        downBtn.zPosition = 1
        downBtn.fillColor = .clear
        downBtn.position = CGPoint(x: -220, y: -370)
        background.addChild(downBtn)
        
        initializeGameLayout()
    }
    
    // [3] create background grid layout
    private func initializeGameLayout() {
        let width = frame.size.width - 65
        let cellWidth: CGFloat = width / 40
        let rows = 38 // xMax = 37
        let cols = 40 // yMax = 39
        var x = (width / -2) + (cellWidth / 2)
        var y = CGFloat(-110)
        for i in 0...rows - 1 {
            for j in 0...cols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                snakeArray.append((node: cellNode, x: i, y: j))
                cellNode.zPosition = 1
                cellNode.position = CGPoint(x: x, y: y)
                cellNode.strokeColor = .clear
                background.addChild(cellNode)
                x += cellWidth
            }
            x = CGFloat(width / -2) + (cellWidth / 2)
            y += cellWidth
        }
    }
    
    // [4] Start playing game
    private func startGame() {
        self.gameOver.isHidden = true
        self.breakLine.isHidden = false
        currentScore.run(SKAction.move(to: CGPoint(x: frame.size.width / -3 - 10, y: (frame.size.height / 3) + 100), duration: 0.3)) {
            self.currentScore.fontSize = 30
            self.currentScore.text = "Score: 0"
            self.currentScore.isHidden = false
        }
        logo.run(SKAction.moveBy(x: 0, y: frame.size.height, duration: 0.3)) { self.logo.isHidden = true }
        tip.run(SKAction.moveBy(x: 0, y: -frame.size.height, duration: 0.3)) { self.tip.isHidden = true }
        let scorePosition = CGPoint(x: frame.size.width / 5, y: (frame.size.height / 3) + 100)
        highScore.run(SKAction.move(to: scorePosition, duration: 0.3)) { self.highScore.fontSize = 30 }
        
        // launch gameManager
        self.game.initGame()
    }
}

