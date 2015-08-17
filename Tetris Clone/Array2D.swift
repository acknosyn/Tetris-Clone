//
//  Array2D.swift
//  Tetris Clone
//
//  Created by Francesco Badraun on 14/08/15.
//  Copyright (c) 2015 Pixel Sharp. All rights reserved.
//

// generics OP

class Array2D<T> {
    let columns: Int
    let rows: Int
    
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        array = Array<T?>(count: rows * columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        
        set {
            array[(row * columns) + column] = newValue
        }
    }
}