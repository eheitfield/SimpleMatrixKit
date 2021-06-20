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
        return Matrix<Value>(rows: rows, cols: cols, constantValue: Value(exactly: 1)!)
    }
    
    /// Identity matrix
    /// - Parameter size: row/column size
    /// - Returns: A square matrix with ones on the main diagonal and zeros elsewhere
    public static func identity(size: Int) -> Matrix<Value> {
        return Matrix<Value>(diagonal: Array<Value>(repeating: Value(1), count: size) )
    }

}

// MARK: Properties of real matrices {

extension Matrix where Value: FloatingPoint {
    
    public func determinant() throws -> Value {
        do {
            let nonsingular = try NonsingularMatrix(self)
            let nSwaps = nonsingular.p.mainDiagonal.reduce(0.0) { $0 + ($1 == 0 ? 0.5 : 0.0) }
            let detP = Int(round(nSwaps)) % 2 == 0 ? Value(1) : Value(-1)
            let detL = nonsingular.l.mainDiagonal.reduce(1) { $0*$1 }
            let detU = nonsingular.u.mainDiagonal.reduce(1) { $0*$1 }
            return detP*detL*detU
        } catch MatrixMathError.factorizationUndefined {
            return Value.zero
        }
    }
    
    public func trace() -> Value {
        return self.mainDiagonal.reduce(Value(1)) { $0*$1 }
    }

}

// MARK: Matrix math operations

public func +<Value: Numeric>(lhs: Matrix<Value>, rhs: Matrix<Value>) throws -> Matrix<Value> {
    guard lhs.rows == rhs.rows && lhs.cols == rhs.cols else {
        throw MatrixMathError.nonconformingMatrices
    }
    var result = lhs
    for row in 0..<lhs.rows {
        for col in 0..<lhs.cols {
            result[row,col] += rhs[row,col]
        }
    }
    return result
}

public func -<Value: Numeric>(lhs: Matrix<Value>, rhs: Matrix<Value>) throws -> Matrix<Value> {
    guard lhs.rows == rhs.rows && lhs.cols == rhs.cols else {
        throw MatrixMathError.nonconformingMatrices
    }
    var result = lhs
    for row in 0..<lhs.rows {
        for col in 0..<lhs.cols {
            result[row,col] -= rhs[row,col]
        }
    }
    return result
}

public func *<Value: Numeric>(lhs: Value, rhs: Matrix<Value>) -> Matrix<Value> {
    return rhs.elementMap { lhs*$0 }
}

public func *<Value: Numeric>(lhs: Matrix<Value>, rhs: Value) -> Matrix<Value> {
    return lhs.elementMap { rhs*$0 }
}

public func *<Value: Numeric>(lhs: Matrix<Value>, rhs: Matrix<Value>) throws -> Matrix<Value> {
        guard lhs.cols == rhs.rows else {
        throw MatrixMathError.nonconformingMatrices
    }
    var result: Matrix<Value> = Matrix(rows: lhs.rows, cols: rhs.cols, constantValue: 0)
    for row in 0..<lhs.rows {
        for col in 0..<rhs.cols {
            result[row,col] = dotProduct(lhs.getRow(row),rhs.getCol(col))
        }
    }
    return result
}

public func /<Value: FloatingPoint>(lhs: Matrix<Value>, rhs: Value) -> Matrix<Value> {
    return lhs.elementMap { rhs/$0 }
}


fileprivate func dotProduct<Value: Numeric>(_ v0: Array<Value>,_ v1: Array<Value>) -> Value {
    return zip(v0,v1).reduce(0) { $0 + $1.0*$1.1 }
}



