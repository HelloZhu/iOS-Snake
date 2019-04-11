//
//  GameManager.swift
//  Snake
//
//  Created by Shizheng Yang on 2018/12/11.
//  Copyright © 2018 haleyysz. All rights reserved.
//

import SpriteKit
import AudioToolbox

class GameManager {
    
    var gameScene: GameScene!
    var nextTime: TimeInterval!
    var timeExtension: TimeInterval = 0.2 // velocity of snake
    var snakeDirection: String = "right"
    var currentScore: Int = 0
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    func initGame() {
        currentScore = 0
        timeExtension = 0.15
        snakeDirection = "right"
        gameScene.snakePosition.removeAll()
        gameScene.snakePosition.append((10,12))
        gameScene.snakePosition.append((10,11))
        gameScene.snakePosition.append((10,10))
        render()
        generateNewPoint()
    }
    
    func render() {
        for (node, x, y) in gameScene.snakeArray {
            if contains(snakeNodes: gameScene.snakePosition, currentNode: (x,y)) {
                node.fillColor = SKColor.black
            } else {
                node.fillColor = SKColor.clear
                if gameScene.scorePosition != nil {
                    if Int(gameScene.scorePosition!.x) == y && Int(gameScene.scorePosition!.y) == x {
                        node.fillColor = SKColor.black
                    }
                }
            }
        }
    }
    
    func contains(snakeNodes:[(Int, Int)], currentNode:(Int,Int)) -> Bool {
        let (n1, n2) = currentNode
        for (s1, s2) in snakeNodes {
            if s1 == n1 && s2 == n2 {
                return true
            }
        }
        return false
    }
    
    func update(time: Double) {
        
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            if time >= nextTime {
                nextTime = time + timeExtension
                updateSnakePosition()
                updateScore()
                checkDeath()
                gameOver()
            }
        }
    }
    
    func move(direction: String) {
        if !(direction == "up" && snakeDirection == "down") && !(direction == "down" && snakeDirection == "up") {
            if !(direction == "left" && snakeDirection == "right") && !(direction == "right" && snakeDirection == "left") {
                if snakeDirection != "dead" {
                    snakeDirection = direction
                }
            }
        }
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(1519) // For older than iPhone6

        let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        lightImpactFeedbackGenerator.prepare()
        lightImpactFeedbackGenerator.impactOccurred()
    }
    
    private func generateNewPoint() {
        var randomX = CGFloat(arc4random_uniform(36))
        var randomY = CGFloat(arc4random_uniform(38))
        
        while contains(snakeNodes: gameScene.snakePosition, currentNode: (Int(randomX), Int(randomY))) {
            randomX = CGFloat(arc4random_uniform(36))
            randomY = CGFloat(arc4random_uniform(38))
        }
        
        gameScene.scorePosition = CGPoint(x: randomX, y: randomY)
    }
    
    private func updateScore() {
        if gameScene.scorePosition != nil {
            if Int(gameScene.scorePosition!.x) == gameScene.snakePosition[0].1 && Int(gameScene.scorePosition!.y) == gameScene.snakePosition[0].0 {
                gameScene.snakePosition.append(gameScene.snakePosition.last!)
                currentScore += 1
                timeExtension = timeExtension * 0.925
                gameScene.currentScore.text = "Score: \(currentScore)"
                generateNewPoint()
            }
        }
    }
    
    private func checkDeath() {
        if gameScene.snakePosition.count > 0 {
            let y = gameScene.snakePosition[0].0
            let x = gameScene.snakePosition[0].1
            
            if y > 37 || y < 0 || x > 39 || x < 0 {
                snakeDirection = "dead"
            }
            
            var array = gameScene.snakePosition
            let head = array[0]
            array.remove(at: 0)
            
            if contains(snakeNodes: array, currentNode: head) {
                snakeDirection = "dead"
            }
        }
    }
    
    private func gameOver() {
        if snakeDirection == "dead" && gameScene.snakePosition.count > 0 {
            updateHighScore()
            snakeDirection = "right"
            gameScene.scorePosition = nil
            gameScene.snakePosition.removeAll()
            gameScene.gameOver.run(SKAction.move(to: CGPoint(x: 0, y: 300), duration: 0.3)) {
                self.gameScene.gameOver.isHidden = false
                self.gameScene.highScore.run(SKAction.move(to: CGPoint(x: 0, y: 200), duration: 0.3))
                self.gameScene.currentScore.run(SKAction.move(to: CGPoint(x: 0, y: 100), duration: 0.3)) {
                    self.gameScene.currentScore.fontSize = 40
                }
                self.gameScene.tip.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.3)) {
                    self.gameScene.tip.isHidden = false
                }
            }
        }
    }
    
    private func updateSnakePosition() {
        var vx = 0
        var vy = 0
        
        switch snakeDirection {
        case "left":
            vx = -1
            vy = 0
            break
        case "up":
            vx = 0
            vy = 1
            break
        case "right":
            vx = 1
            vy = 0
            break
        case "down":
            vx = 0
            vy = -1
            break
        case "dead":
            vibrate()
            vx = 0
            vy = 0
            break
        default:
            break
        }
        if gameScene.snakePosition.count > 0 {
            var index = gameScene.snakePosition.count - 1
            repeat {
                gameScene.snakePosition[index] = gameScene.snakePosition[index - 1]
                index -= 1
            } while index > 0
            gameScene.snakePosition[0] = (gameScene.snakePosition[0].0 + vy, gameScene.snakePosition[0].1 + vx)
        }
        render()
    }
    
    private func updateHighScore() {
        if currentScore > UserDefaults.standard.integer(forKey: "highScore") {
            UserDefaults.standard.removeObject(forKey: "highScore")
            UserDefaults.standard.set(currentScore, forKey: "highScore")
        }
        gameScene.highScore.text = "High Score: \(UserDefaults.standard.integer(forKey: "highScore"))"
    }
}


