//
//  File.swift
//  
//
//  Created by Erik Heitfield on 6/24/21.
//

import Foundation

/// This structure provides an efficient means of performing elementary row operations
/// on a matrix of floating point numbers.
struct DereferencedRealMatrix<Value: FloatingPoint> {
    
    private var startRows: [[Value]]
    private (set) var rPtrs: [Int]
    private (set) var cPtrs: [Int]
    
    init(_ rows: [[Value]]) {
        self.startRows = rows
        self.rPtrs = Array(0..<rows.count)
        self.cPtrs = Array(0..<(rows.count > 0 ? rows[0].count : 0 ))
    }
    
    subscript(i: Int, j: Int) -> Value {
        get {
            return startRows[rPtrs[i]][cPtrs[j]]
        }
        set {
            startRows[rPtrs[i]][cPtrs[j]] = newValue
        }
    }
    
    /// Swap two rows
    /// - Parameters:
    ///   - row0: index of first row
    ///   - row1: index of second row
    mutating func swapRows(_ row0: Int, _ row1: Int) {
        let oldIRow = rPtrs[row0]
        rPtrs[row0] = rPtrs[row1]
        rPtrs[row1] = oldIRow
    }
    
    /// Swap two columns
    /// - Parameters:
    ///   - col0: index of first column
    ///   - col1: index of second column
    mutating func swapCols(_ col0: Int, _ col1: Int) {
        let oldICol = cPtrs[col0]
        cPtrs[col0] = cPtrs[col1]
        cPtrs[col1] = oldICol
    }
    
    /// Replace row0 with row0 + coef * row1
    /// - Parameters:
    ///   - row0: index of row to be changed
    ///   - row1: index of added row
    ///   - coef: coefficient on added row
    mutating func addToRow(row0: Int, row1: Int, coef: Value) {
        for k in 0..<startRows.count {
            self[row0,k] += self[row1,k]*coef
        }
    }
    
    /// Multiply all elements of a row by a constant
    /// - Parameters:
    ///   - row0: index of row to be scaled
    ///   - coef: coefficient ot scale row by
    mutating func scaleRow(row0: Int, coef: Value) {
        for k in 0..<startRows.count {
            self[row0,k] *= coef
        }
    }

}

extension DereferencedRealMatrix: MatrixRepresentable {
    var allRows: [[Value]] {
        return self.rPtrs.map { rPtr in
            self.cPtrs.map { cPtr in
                startRows[rPtr][cPtr]
            }
        }
    }
}
