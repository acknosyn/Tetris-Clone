//
//  TetrisClone.swift
//  Tetris Clone
//
//  Created by Francesco Badraun on 15/08/15.
//  Copyright (c) 2015 Pixel Sharp. All rights reserved.
//

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

protocol TetrisCloneDelegate {
    // invoked when the current round of TetrisClone ends
    func gameDidEnd(terisClone: TetrisClone)
    
    // invoked immediately after a new game has begun
    func gameDidBegin(tetrisClone: TetrisClone)
    
    // invoked when the falling shape has become part of the game board
    func gameShapeDidLand(tetrisClone: TetrisClone)
    
    // invoked when the falling shape has changed its location
    func gameShapeDidMove(tetrisClone: TetrisClone)
    
    // invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(tetrisClone: TetrisClone)
    
    // invoked when the game has reached a new level
    func gameDidLevelUp(tetrisClone: TetrisClone)
}

class TetrisClone {
    var blockArray: Array2D<Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    var delegate: TetrisCloneDelegate?
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if nextShape == nil {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
    
    func newShape() -> (fallingShape: Shape?, nextShape: Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
        if detectIllegalPlacement() {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        return (fallingShape, nextShape)
    }
    
    func detectIllegalPlacement() -> Bool {
        if let shape = fallingShape {
            for block in shape.blocks {
                if block.column < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows {
                    return true
                } else if blockArray[block.column, block.row] != nil {
                    return true
                }
            }
        }
        return false
    }
    
    func endGame() {
        
    }
}