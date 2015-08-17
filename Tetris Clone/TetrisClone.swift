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

let PointsPerLine = 10
let LevelThreshold = 1000

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
    
    var score: Int
    var level: Int
    
    init() {
        score = 0
        level = 1
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
    
    func dropShape() {
        if let shape = fallingShape {
            while detectIllegalPlacement() == false {
                shape.lowerShapeByOneRow()
            }
            shape.raiseShapeByOneRow()
            delegate?.gameShapeDidDrop(self)
        }
    }
    
    func letShapeFall() {
        if let shape = fallingShape {
            shape.lowerShapeByOneRow()
            if detectIllegalPlacement() {
                shape.raiseShapeByOneRow()
                if detectIllegalPlacement() {
                    endGame()
                } else {
                    settleShape()
                }
            } else {
                delegate?.gameShapeDidMove(self)
                if detectTouch() {
                    settleShape()
                }
            }
        }
    }
    
    func rotateShape() {
        if let shape = fallingShape {
            shape.rotateClockwise()
            if detectIllegalPlacement() {
                shape.rotateCounterClockwise()
            } else {
                delegate?.gameShapeDidMove(self)
            }
        }
    }
    
    func moveShapeLeft() {
        if let shape = fallingShape {
            shape.shiftLeftByOneColumn()
            if detectIllegalPlacement() {
                shape.shiftRightByOneColumn()
                return
            }
            delegate?.gameShapeDidMove(self)
        }
    }
    
    func moveShapeRight() {
        if let shape = fallingShape {
            shape.shiftRightByOneColumn()
            if detectIllegalPlacement() {
                shape.shiftLeftByOneColumn()
                return
            }
            delegate?.gameShapeDidMove(self)
        }
    }
    
    func settleShape() {
        if let shape = fallingShape {
            for block in shape.blocks {
                blockArray[block.column, block.row] = block
            }
            fallingShape = nil
            delegate?.gameShapeDidLand(self)
        }
    }
    
    func detectTouch() -> Bool {
        if let shape = fallingShape {
            for bottomBlock in shape.bottomBlocks {
                if bottomBlock.row == NumRows - 1 || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                    return true
                }
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for var row = NumRows - 1; row > 0; row-- {
            var rowOfBlocks = Array<Block>()
            
            // add every block in a given row
            for column in 0..<NumColumns {
                if let block = blockArray[column, row] {
                    rowOfBlocks.append(block)
                }
            }
            
            // if rowOfBlocks ends up being full, count it as a removed line
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // if no lines were removed, exit
        if removedLines.count == 0 {
            return ([], [])
        }
        
        // add points to player's score based on the number of lines they've created
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        
        // if they're points exceed their level * 1000, they level up
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            // starting in the left-most column and above the bottom-most removed line
            for var row = removedLines[0][0].row - 1; row > 0; row-- {
                if let block = blockArray[column, row] {
                    var newRow = row
                    // count upwards towards the top of the board
                    while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                        newRow++
                    }
                    // take each remaining block found on the game board and lower it as far as possible
                    block.row = newRow
                    blockArray[column, row] = nil
                    blockArray[column, newRow] = block
                    fallenBlocksArray.append(block)
                }
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                if let block = blockArray[column, row] {
                    rowOfBlocks.append(block)
                    blockArray[column, row] = nil
                }
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
}