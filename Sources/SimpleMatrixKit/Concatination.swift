//
//  Concatination.swift
//  
//
//  Created by Erik Heitfield on 6/20/21.
//

import Foundation

public func hCat<T: MatrixRepresentable, U: MatrixRepresentable,V>(_ m0: U, _ m1: T) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    guard m0.rows == m1.rows else {
        throw MatrixError.nonconformingMatrices
    }
    let m0rows = m0.allRows
    let m1rows = m1.allRows
    let catArray = (0..<m1.rows).map { m0rows[$0]+m1rows[$0] }
    return Matrix(array2D: catArray)
}

public func vCat<T: MatrixRepresentable, U: MatrixRepresentable, V>(_ m0: T, _ m1: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    // Convert to concrete matrix to get transpose operator
    let m0 = Matrix(array2D: m0.allRows)
    let m1 = Matrix(array2D: m1.allRows)
    return try hCat(m0.transpose, m1.transpose).transpose
}

precedencegroup MatrixConcatinationPrecedence {
    associativity: left
    higherThan: RangeFormationPrecedence
    lowerThan: AdditionPrecedence
}

infix operator <|> : MatrixConcatinationPrecedence
public func <|><T: MatrixRepresentable, U: MatrixRepresentable, V>(lhs: T, rhs: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    return try hCat(lhs,rhs)
}

infix operator <-> : MatrixConcatinationPrecedence
public func <-><T: MatrixRepresentable, U: MatrixRepresentable, V>(lhs: T, rhs: U) throws -> Matrix<V> where V == T.Value, T.Value == U.Value {
    return try vCat(lhs,rhs)
}
