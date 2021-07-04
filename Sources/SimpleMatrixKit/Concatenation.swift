//
//  Concatenation.swift
//  
//
//  Created by Erik Heitfield on 6/20/21.
//

import Foundation

/// Horizontally concatenate two matrices
/// - Parameters:
///   - m0: matrix (n x k)
///   - m1: matrix (m x k)
/// - Throws: MatrixError
/// - Returns: concatenated matrix (n+m x k)
public func hCat<T: MatrixRepresentable, U: MatrixRepresentable,V>(_ m0: U, _ m1: T) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    try MatrixError.testEqualRows(m0, m1)
    let m0rows = m0.allRows
    let m1rows = m1.allRows
    let catArray = (0..<m1.rows).map { m0rows[$0]+m1rows[$0] }
    return Matrix(array2D: catArray)
}

/// Vertically concatenate two matrices
/// - Parameters:
///   - m0: matrix (n x k)
///   - m1: matrix (n x l)
/// - Throws: MatrixError
/// - Returns: concatenated matrix (n x k+l)
public func vCat<T: MatrixRepresentable, U: MatrixRepresentable, V>(_ m0: T, _ m1: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    // Convert to concrete matrix to get transpose operator
    try MatrixError.testEqualColumns(m0, m1)
    let m0 = Matrix(array2D: m0.allRows)
    let m1 = Matrix(array2D: m1.allRows)
    return try hCat(m0.transpose, m1.transpose).transpose
}

precedencegroup MatrixConcatenationPrecedence {
    associativity: left
    higherThan: RangeFormationPrecedence
    lowerThan: AdditionPrecedence
}

infix operator <|> : MatrixConcatenationPrecedence
public func <|><T: MatrixRepresentable, U: MatrixRepresentable, V>(lhs: T, rhs: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    return try hCat(lhs,rhs)
}

infix operator <-> : MatrixConcatenationPrecedence
public func <-><T: MatrixRepresentable, U: MatrixRepresentable, V>(lhs: T, rhs: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    return try vCat(lhs,rhs)
}
