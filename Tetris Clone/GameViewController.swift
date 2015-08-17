//
//  GameViewController.swift
//  Tetris Clone
//
//  Created by Francesco Badraun on 14/08/15.
//  Copyright (c) 2015 Pixel Sharp. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, TetrisCloneDelegate {
    
    var scene:GameScene!
    var tetrisClone: TetrisClone!
    
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
    }
    
    func gameDidLevelUp(tetrisClone: TetrisClone) {
        
    }
    
    func gameShapeDidDrop(tetrisClone: TetrisClone) {
        
    }
    
    func gameShapeDidLand(tetrisClone: TetrisClone) {
        scene.stopTicking()
        nextShape()
    }
    
    func gameShapeDidMove(tetrisClone: TetrisClone) {
        scene.redrawShape(tetrisClone.fallingShape!) {}
    }
}