//
//  GameViewController.swift
//  Tetris Clone
//
//  Created by Francesco Badraun on 14/08/15.
//  Copyright (c) 2015 Pixel Sharp. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
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
        tetrisClone.beginGame()
        
        // present the scene
        skView.presentScene(scene)
        
        scene.addPreviewShapeToScene(tetrisClone.nextShape!) {
            self.tetrisClone.nextShape?.moveTo(StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(self.tetrisClone.nextShape!) {
                let nextShapes = self.tetrisClone.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
            }
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func didTick() {
        tetrisClone.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(tetrisClone.fallingShape!, completion: {})
    }
}
