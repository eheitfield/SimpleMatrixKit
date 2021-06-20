//
//  Matrix.swift
//  
//
//  Created by Erik Heitfield on 6/13/21.
//

import Foundation

/// A simple structure for storing two-dimensional matrixes of values.
/// This structure is similar to a simple array of arrays (2D array).
/// The main difference is that it enforces the requirement that all of
/// the inner arrays must be of the same length so that the data forms
/// a proper matrix.  Various convenience methods and properties are
/// also included.
public struct Matrix<Value> {
    
    var elements: [[Value]]
    
    /// Number of rows in the matrix
    public var rows: Int { return elements.count }
    
    /// Number of columns in the matrix
    public var cols: Int {
        if elements.count > 0 {
            return elements[0].count
        } else {
            return 0
        }
    }
    
    /// Flag for square matrix
    public var isSquare: Bool {
        return self.rows == self.cols
    }
    
    /// Flag for empty matrix
//    public var isEmpty: Bool {
//        return rows==0 || cols==0
//    }
    
    // MARK: Initializers
            
    /// Create a matrix from a balanced 2D array of values.
    /// - Parameter array2D: an array of arrays
    /// Note: Each second level array of ''array2D'' must have the same length.
    public init( array2D: [[Value]]) {
        let rows = array2D.count
        if rows <= 0 {
            self.init(rows: 0, cols: 0 , valueArray: [])
            return
        }
        let cols = array2D[0].count
        if cols <= 0 {
            self.init(rows: 0, cols: 0, valueArray: [])
            return
        }
        guard array2D.reduce(true, {$0 && $1.count==cols}) else {
            preconditionFailure("Array2D has inconsistent row lengths.")
        }
        let valueArray = array2D.flatMap({$0})
        self.init(rows: rows, cols: cols, valueArray: valueArray)
    }
        
    /// Create a constant matrix.
    /// - Parameters:
    ///   - rows: number of rows
    ///   - cols: number of columns
    ///   - constantValue: value repeated for all Values
    public init( rows: Int, cols: Int, constantValue: Value ) {
        let valueArray = Array(repeating: constantValue, count: rows*cols)
        self.init(rows: rows, cols: cols, valueArray: valueArray)
    }
    
    public init(rows: Int, cols: Int, valueArray: [Value]) {
        guard valueArray.count == rows*cols else {
            preconditionFailure("Value array does not match matrix size")
        }
        self.elements = (0..<rows).map { row in
            Array(valueArray[row*cols..<(row+1)*cols])
        }
    }
    
    // MARK: Value Access
    
    /// Access an element of the matrix
    public subscript(row: Int, col: Int) -> Value {
        get {
            guard row < rows && col < cols else {
                preconditionFailure("Accessed out of range matrix Value: Matrix is \(rows) x \(col). Read Value \(row),\(col).")
            }
            return elements[row][col]
        }
        set {
            guard row < rows && col < cols else {
                preconditionFailure("Accessed out of range matrix Value: Matrix is \(rows) x \(col). Set Value \(row),\(col).")
            }
            elements[row][col] = newValue
        }
    }
    
    /// Extract a row from the matrix
    /// - Parameter row: the row to extract
    /// - Returns: a vector of element values
    public func getRow(_ row: Int) -> [Value] {
        guard row < rows else { return [Value]() }
        return elements[row]
    }
    
    /// Extract a column from the matrix
    /// - Parameter col: the column to extract
    /// - Returns: a vector of element values
    public func getCol(_ col: Int) -> [Value] {
        guard col < cols else { return [Value]() }
        return self[0..<rows, col..<col+1].vectorized
    }
    
    /// Return matrix elements expressed as an array of arrays by rows (2D array)
    public var allRows: [[Value]] {
        return elements
    }
    
    /// Return matrix elements as an array of arrays by columns (2D array of matrix transpose)
    public var allCols: [[Value]] {
        var allCols = [[Value]]()
        for col in 0..<cols {
            allCols.append(getCol(col))
        }
        return allCols
    }
    
    /// Return an array of elements along the main diagonal of the matrix
    public var mainDiagonal: [Value] {
        return (0..<Swift.min(rows,cols)).map { self[$0,$0]}
    }
    
    /// Return matrix elements as a vector with rows arranged end to end.
    public var vectorized: [Value] {
        return self.elements.flatMap({$0})
    }
    
    // MARK: Submatrices
    
    /// Access a sub-matrix described by ranges of rows and columns
    public subscript<R>(rowRange: R, colRange: R) -> Matrix<Value> where R: RangeExpression, R.Bound == Int {
        var subMatVecs: [[Value]] = []
        for rowVec in self.elements[rowRange] {
            subMatVecs.append(Array(rowVec[colRange]))
        }
        return Matrix(array2D: subMatVecs)
    }
    
    /// Submatrix of selected rows
    /// - Parameter rowIndexes: indexes of rows to extract
    /// - Returns: Matrix with selected rows in specified order
    public func subMatrix(rowIndexes: [Int]) -> Matrix<Value> {
        guard rowIndexes.allSatisfy({ $0>=0 && $0<rows})  else {
            preconditionFailure("Accessed out of range submatrix")
        }
        return Matrix(array2D: rowIndexes.map{ elements[$0] } )
    }
    
    /// Submatrix of selected columns
    /// - Parameter colIndexes: indexes of columns to extract
    /// - Returns: Matrix with selected col in specified order
    public func subMatrix(colIndexes: [Int]) -> Matrix<Value> {
        return self.transpose.subMatrix(rowIndexes: colIndexes).transpose
    }
    
    /// Submatrix of selected rows and columns
    /// - Parameters:
    ///   - rowIndexes: indexes of rows to extract
    ///   - colIndexes: indexes of columns to extract
    /// - Returns: Matrix with selected rows and columns in specified order
    public func submatrix(rowIndexes: [Int], colIndexes: [Int]) -> Matrix<Value> {
        return self.subMatrix(rowIndexes: rowIndexes).subMatrix(colIndexes: colIndexes)
    }
    
    // MARK: Derived Matrices
    
    public var transpose: Matrix<Value> {
        return Matrix(rows: self.cols, cols: self.rows, valueArray: self.allCols.flatMap { $0 } )
    }
    
    public func elementMap<MappedValue>( transform: (Value) -> MappedValue ) -> Matrix<MappedValue> {
        return Matrix<MappedValue>(rows: self.rows, cols: self.cols,
                                   valueArray: self.vectorized.map(transform))
    }
    
    
    // MARK: Constant Matrices
    
    /// An empty matrix
    /// - Parameter type: type of matrix Value
    /// - Returns: An empty matrix of the given Value type
    public static func empty<Value>() -> Matrix<Value> {
        return Matrix<Value>(rows: 0, cols: 0, valueArray: [Value]() )
    }

}

// MARK: Array Literal Conformance

extension Matrix: ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = [Value]

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(rows: elements.count, cols: elements.first!.count, valueArray: elements.flatMap { $0 })
    }

}

// MARK: Sequence Conformance

extension Matrix: Sequence {
        
    public typealias Iterator = AnyIterator<[Value]>

    public __consuming func makeIterator() -> AnyIterator<[Value]> {
        var iterator = self.elements.makeIterator()
        return AnyIterator { iterator.next() }
    }
    
}

// MARK: Collection Conformance

extension Matrix: Collection {

    public typealias Index = Int
    
    public var startIndex: Index { 0 }
    
    public var endIndex: Index { self.rows }
    
    public func index(after i: Index) -> Index {
        i+1
    }
    
    public subscript (position: Index) -> Iterator.Element {
        guard position>=startIndex && position <= endIndex else {
            preconditionFailure("Matrix index out of bounds.")
        }
        return elements[position]
    }
    
    public init(_ slice: Slice<Matrix<Value>>) {
        self.elements = Array(slice)
    }

}

// MARK: Custom String Convertable Conformance

extension Matrix: CustomStringConvertible where Value: CustomStringConvertible {
    
    public var description: String {
        guard !isEmpty else { return "Empty Matrix" }
        let maxRows = 5
        let maxCols = 5
        let cellLength = 6
//        return elements.reduce("") { str, rowVec in
//            str + rowVec.reduce("[ ") { rowStr, element in
//                rowStr
//                    + " "
//                    + element.description.padding(toLength: cellLength, withPad: " ", startingAt: 0)
//            } + self.cols <= maxCols ? " ]\n" : " ...\n"
//        }
        var str: String = "\(self.rows) x \(self.cols) Matrix:\n"
        for row in 0..<Swift.min(self.rows,maxRows) {
            str += "[ "
            for col in 0..<Swift.min(self.cols,maxCols) {
                str += " "
                    + self[row,col].description.padding(toLength: cellLength, withPad: " ", startingAt: 0)
            }
            str += self.cols <= maxCols ? " ]\n" : " ...\n"
        }
        str += self.rows <= maxRows ? "" : "..."
        return str
    }
    
}
    
    

// MARK: Equatable Conformance and Properties

extension Matrix: Equatable where Value: Equatable {
    
    public var isSymmetric: Bool {
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

// MARK: Matrix Manipulation

public func hCat<Value>(_ m0: Matrix<Value>, _ m1: Matrix<Value>) throws -> Matrix<Value> {
    guard m0.rows == m1.rows else {
        throw MatrixMathError.nonconformingMatrices
    }
    let m0rows = m0.allRows
    let m1rows = m1.allRows
    let catArray = (0..<m1.rows).map { m0rows[$0]+m1rows[$0] }
    return Matrix(array2D: catArray)
}

public func vCat<Value>(_ m0: Matrix<Value>, _ m1: Matrix<Value>) throws -> Matrix<Value> {
    return try hCat(m0.transpose, m1.transpose).transpose
}

precedencegroup MatrixConcatinationPrecedence {
    associativity: left
    higherThan: RangeFormationPrecedence
    lowerThan: AdditionPrecedence
}

infix operator <|> : MatrixConcatinationPrecedence
public func <|><Value>(lhs: Matrix<Value>, rhs: Matrix<Value>) throws -> Matrix<Value> {
    return try hCat(lhs,rhs)
}

infix operator <-> : MatrixConcatinationPrecedence
public func <-><Value>(lhs: Matrix<Value>, rhs: Matrix<Value>) throws -> Matrix<Value> {
    return try vCat(lhs,rhs)
}

