//
//  GameViewController.swift
//  Tetris Clone
//
//  Created by Francesco Badraun on 14/08/15.
//  Copyright (c) 2015 Pixel Sharp. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, TetrisCloneDelegate, UIGestureRecognizerDelegate {
    
    var scene:GameScene!
    var tetrisClone: TetrisClone!
    var panPointReference: CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the view
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        
        tetrisClone = TetrisClone()
        tetrisClone.delegate = self
        tetrisClone.beginGame()
        
        // present the scene
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        tetrisClone.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    tetrisClone.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    tetrisClone.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        tetrisClone.dropShape()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func didTick() {
        tetrisClone.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = tetrisClone.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func gameDidBegin(tetrisClone: TetrisClone) {
        levelLabel.text = "\(tetrisClone.level)"
        scoreLabel.text = "\(tetrisClone.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // the following is false when restarting a new game
        if tetrisClone.nextShape != nil && tetrisClone.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(tetrisClone.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(terisClone: TetrisClone) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(tetrisClone.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            self.tetrisClone.beginGame()
        }
    }
    
    func gameDidLevelUp(tetrisClone: TetrisClone) {
        levelLabel.text = "\(tetrisClone.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(tetrisClone: TetrisClone) {
        scene.stopTicking()
        scene.redrawShape(tetrisClone.fallingShape!) {
            tetrisClone.letShapeFall()
        }
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(tetrisClone: TetrisClone) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        let removedLines = tetrisClone.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(tetrisClone.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks) {
                self.gameShapeDidLand(tetrisClone)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(tetrisClone: TetrisClone) {
        scene.redrawShape(tetrisClone.fallingShape!) {}
    }
}