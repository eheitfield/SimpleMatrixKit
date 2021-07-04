//
//  Math Extensions.swift
//  
//
//  Created by Erik Heitfield on 6/13/21.
//

import Foundation

// MARK: Standard matrices

extension Matrix where Value: FloatingPoint {
    
    /// A square diagonal matrix
    /// - Parameter diagonal: values on the main diagonal
    init( diagonal: [Value] ) {
        let valueArray = diagonal.enumerated().flatMap { i,v -> [Value] in
            var rowValues = Array(repeating: Value.zero, count: diagonal.count)
            rowValues[i] = v
            return rowValues
        }
        self.init(rows: diagonal.count, cols: diagonal.count, valueArray: valueArray)
    }
    
    /// A matrix of zeros
    /// - Parameters:
    ///   - type: type of matrix Value (must be Numeric)
    ///   - rows: number of rows of zeros
    ///   - cols: number of columns of zeros
    /// - Returns: A matrix of zeros of the given numeric type.
    public static func zeros(rows: Int, cols: Int) -> Matrix<Value> {
        return Matrix<Value>(rows: rows, cols: cols, constantValue: Value.zero)
    }
    
    /// A matrix of ones
    /// - Parameters:
    ///   - type: type of matrix Value (must be Numeric)
    ///   - rows: number of rows of ones
    ///   - cols: number of columns of ones
    /// - Returns: A matrix of ones of the given numeric type.
    public static func ones(rows: Int, cols: Int) -> Matrix<Value> {
        return Matrix<Value>(rows: rows, cols: cols, constantValue: Value(1))
    }
    
    /// Identity matrix
    /// - Parameter size: row/column size
    /// - Returns: A square matrix with ones on the main diagonal and zeros elsewhere
    public static func identity(size: Int) -> Matrix<Value> {
        return Matrix<Value>(diagonal: Array<Value>(repeating: Value(1), count: size) )
    }
    
    public static func permutation(order: [Int]) -> Matrix<Value> {
        guard order.allSatisfy({ $0 >= 0 && $0 < order.count }) else {
            preconditionFailure("Permutation order index out of range.")
        }
        let elements = order.map { i -> [Value] in
            var rowVec = Array(repeating: Value.zero, count: order.count)
            rowVec[i] = Value(1)
            return rowVec
        }
        return Matrix<Value>(array2D: elements)
    }

}


// MARK: Matrix math operations

/// Matrix addition
public func +<T: MatrixRepresentable, U: MatrixRepresentable, V: Numeric>(lhs: T, rhs: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    try MatrixError.testEqualSize(lhs,rhs)
    let array2D = zip(lhs.allRows,rhs.allRows).map { rowPair in
        zip(rowPair.0,rowPair.1).map { $0 + $1 }
    }
    return Matrix(array2D: array2D)
}

/// Matrix subtraction
public func -<T: MatrixRepresentable, U: MatrixRepresentable, V: Numeric>(lhs: T, rhs: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    try MatrixError.testEqualSize(lhs,rhs)
    let array2D = zip(lhs.allRows,rhs.allRows).map { rowPair in
        zip(rowPair.0,rowPair.1).map { $0 - $1 }
    }
    return Matrix(array2D: array2D)
}

/// Matrix multiplication
public func *<T: MatrixRepresentable, V: Numeric>(lhs: V, rhs: T) -> Matrix<V> where V == T.Value {
    let valueArray = rhs.allRows.flatMap { $0 }.map { $0*lhs  }
    return Matrix(rows: rhs.rows, cols: rhs.cols, valueArray: valueArray)
}

/// Left-side scalar multiplication
public func *<T: MatrixRepresentable, V: Numeric>(lhs: T, rhs: V) -> Matrix<V> where V == T.Value {
    let valueArray = lhs.allRows.flatMap { $0 }.map { $0*rhs  }
    return Matrix(rows: lhs.rows, cols: lhs.cols, valueArray: valueArray)
}

/// Right-side scalar multiplication
public func *<T: MatrixRepresentable, U: MatrixRepresentable, V: Numeric>(lhs: T, rhs: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    try MatrixError.testMultiplicationConformance(lhs,rhs)
    var result: Matrix<V> = Matrix(rows: lhs.rows, cols: rhs.cols, constantValue: V.zero)
    for (i,row) in lhs.allRows.enumerated() {
        for (j,col) in rhs.allCols.enumerated() {
            result[i,j] = dotProduct(row,col)
        }
    }
    return result
}

/// Right-side scalar division
public func /<T: MatrixRepresentable, V: FloatingPoint>(lhs: T, rhs: V) -> Matrix<V> where V == T.Value {
    let valueArray = lhs.allRows.flatMap { $0 }.map { $0/rhs  }
    return Matrix(rows: lhs.rows, cols: lhs.cols, valueArray: valueArray)
}

// Transpose


// MARK: Helper functions

fileprivate func dotProduct<Value: Numeric>(_ v0: Array<Value>,_ v1: Array<Value>) -> Value {
    return zip(v0,v1).reduce(0) { $0 + $1.0*$1.1 }
}



