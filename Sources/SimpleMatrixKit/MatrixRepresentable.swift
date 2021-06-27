//
//  MatrixRepresentable.swift
//  
//
//  Created by Erik Heitfield on 6/20/21.
//

import Foundation

public protocol MatrixRepresentable {
    associatedtype Value
    var allRows: [[Value]] { get } // All inner arrays must have length equal to cols
}

public extension MatrixRepresentable {
    
    // MARK: Matrix Characteristics
    
    /// Number of rows
    var rows: Int { allRows.count }
    
    /// Number of columns in the matrix
    var cols: Int {
        if self.allRows.count > 0 {
            return allRows[0].count
        } else {
            return 0
        }
    }
    
    /// Flag for square matrix
    var isSquare: Bool {
        return self.rows == self.cols
    }
    
    // MARK: Value Access
    
    /// Return matrix elements as an array of arrays by columns (2D array of matrix transpose)
    var allCols: [[Value]] {
        var colVecs: [[Value]] = Array(repeating: [Value](), count: self.cols)
        self.allRows.forEach { rowVec in
            rowVec.enumerated().forEach { j,cell in colVecs[j].append(cell) }
        }
        return colVecs
    }
    
    subscript(row: Int, col: Int) -> Value {
        get {
            guard row < rows && col < cols && row >= 0 && col >= 0 else {
                preconditionFailure("Accessed out of range matrix Value: Matrix is \(rows) x \(col). Read Value \(row),\(col).")
            }
            return getRow(row)[col]
        }
    }
    
    /// Extract a row from the matrix
    /// - Parameter row: the row to extract
    /// - Returns: a vector of element values
    func getRow(_ row: Int) -> [Value] {
        guard row < rows && row >= 0 else { return [Value]() }
        return allRows[row]
    }
    
    /// Extract a column from the matrix
    /// - Parameter col: the column to extract
    /// - Returns: a vector of element values
    func getCol(_ col: Int) -> [Value] {
        guard col < cols && col >= 0 else { return [Value]() }
        return allCols[col]
    }

    /// Return matrix elements as a vector with rows arranged end to end.
    var vectorized: [Value] {
        return self.allRows.flatMap({$0})
    }
    
    /// Return an array of elements along the main diagonal of the matrix
    var mainDiagonal: [Value] {
        return (0..<Swift.min(rows,cols)).map { getRow($0)[$0] }
    }

    // MARK: Derived Matrices
    
    var transpose: Matrix<Value> {
        return Matrix(rows: self.cols, cols: self.rows, valueArray: self.allCols.flatMap { $0 } )
    }
    
    func elementMap<MappedValue>( transform: (Value) -> MappedValue ) -> Matrix<MappedValue> {
        return Matrix<MappedValue>(rows: self.rows, cols: self.cols,
                                   valueArray: self.vectorized.map(transform))
    }
    
    // MARK: Submatrices
    
    /// Access a sub-matrix described by ranges of rows and columns
    subscript<R>(rowRange: R, colRange: R) -> Matrix<Value> where R: RangeExpression, R.Bound == Int {
        var subMatVecs: [[Value]] = []
        for rowVec in self.allRows[rowRange] {
            subMatVecs.append(Array(rowVec[colRange]))
        }
        return Matrix(array2D: subMatVecs)
    }
    
    /// Submatrix of selected rows
    /// - Parameter rowIndexes: indexes of rows to extract
    /// - Returns: Matrix with selected rows in specified order
    func subMatrix(rowIndexes: [Int]) -> Matrix<Value> {
        guard rowIndexes.allSatisfy({ $0>=0 && $0<rows})  else {
            preconditionFailure("Attempted to access out of range matrix element.")
        }
        return Matrix(array2D: rowIndexes.map{ getRow($0) } )
    }
    
    /// Submatrix of selected columns
    /// - Parameter colIndexes: indexes of columns to extract
    /// - Returns: Matrix with selected col in specified order
    func subMatrix(colIndexes: [Int]) -> Matrix<Value> {
        return self.transpose.subMatrix(rowIndexes: colIndexes).transpose
    }
    
    /// Submatrix of selected rows and columns
    /// - Parameters:
    ///   - rowIndexes: indexes of rows to extract
    ///   - colIndexes: indexes of columns to extract
    /// - Returns: Matrix with selected rows and columns in specified order
    func submatrix(rowIndexes: [Int], colIndexes: [Int]) -> Matrix<Value> {
        return self.subMatrix(rowIndexes: rowIndexes).subMatrix(colIndexes: colIndexes)
    }

}

public extension MatrixRepresentable where Value: Equatable {
    
    var isSymmetric: Bool {
        guard self.isSquare else { return false }
        for row in 0..<self.rows {
            for col in 0..<self.cols {
                if self[row,col] != self[col,row] {
                    return false
                }
            }
        }
        return true
    }

}

