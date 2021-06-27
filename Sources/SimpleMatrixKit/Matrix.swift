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
/// a proper matrix.
public struct Matrix<Value> {
    
    var elements: [[Value]]
    
    // MARK: Initializers
            
    /// Create a matrix from a balanced 2D array of values.
    /// - Parameter array2D: an array of arrays
    /// Note: Each second level array of ''array2D'' must have the same length.
    public init( array2D: [[Value]])  {
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
        guard array2D.allSatisfy({$0.count==cols}) else {
            preconditionFailure("Matrix cannot be instantiated from unbalanced array.")
        }
        let valueArray = array2D.flatMap({$0})
        self.init(rows: rows, cols: cols, valueArray: valueArray)
    }
    
    public init<T: MatrixRepresentable>(matrix: T) where Value == T.Value {
        self.init(array2D: matrix.allRows)
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
            preconditionFailure("Flat array used to instantiate matrix must contain rows*col elements.")
        }
        self.elements = (0..<rows).map { row in
            Array(valueArray[row*cols..<(row+1)*cols])
        }
    }
    
    // MARK: Value Access
    
    /// Access an element of the matrix
    public subscript(row: Int, col: Int) -> Value {
        get {
            guard row < rows && col < cols && row >= 0 && col >= 0 else {
                preconditionFailure("Accessed out of range matrix Value:\nMatrix is \(rows) x \(col). Read Value \(row),\(col).")
            }
            return elements[row][col]
        }
        set {
            guard row < rows && col < cols && row >= 0 && col >= 0 else {
                preconditionFailure("Accessed out of range matrix Value:\nMatrix is \(rows) x \(col). Set Value \(row),\(col).")
            }
            elements[row][col] = newValue
        }
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

// MARK: Matrix Representable Conformance

extension Matrix: MatrixRepresentable {
    
    /// Return matrix elements expressed as an array of arrays by rows (2D array)
    public var allRows: [[Value]] {
        return elements
    }
    
}

// MARK: Custom String Convertible Conformance

extension Matrix: CustomStringConvertible where Value: CustomStringConvertible {
    
    public var description: String {
        guard !isEmpty else { return "Empty Matrix" }
        let maxRows = 5
        let maxCols = 5
        let cellLength = 6
        /*
         
        I BELIEVE THIS CODE SHOULD WORK, BUT XCODE HAS PROBLEMS WITH TYPE INFERENCE
        
         return elements.reduce("") { str, rowVec in
            str + rowVec.reduce("[ ") { rowStr, element in
                rowStr
                    + " "
                    + element.description.padding(toLength: cellLength, withPad: " ", startingAt: 0)
            } + self.cols <= maxCols ? " ]\n" : " ...\n"
        }
         
        */
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

// MARK: Equatable Conformance

extension Matrix: Equatable where Value: Equatable {}

