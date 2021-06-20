//
//  MatrixError.swift
//  
//
//  Created by Erik Heitfield on 6/19/21.
//

import Foundation

// MARK: Matix Manipulation Errors

/// Matrix manipulation errors
enum MatrixError: Error {
    case nonconformingMatrices
    case squareOperationOnNonsquareMatrix
    case symmetricOperationOnNonsymmetricMatrix
    case factorizationUndefined
    case singularMatrixTreatedAsNonsingular
}

// MARK: Localized Error Conformance

extension MatrixError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .nonconformingMatrices:
            return "Opertion on nonconforming matrices."
        case .squareOperationOnNonsquareMatrix:
            return "Square matrix operation on non-square matrix."
        case .symmetricOperationOnNonsymmetricMatrix:
            return "Symmetric matrix operation on non-symmetric matrix."
        case .factorizationUndefined:
            return "Matrix factorization undefined."
        case .singularMatrixTreatedAsNonsingular:
            return "Nonsingular matrix operation on singular matrix."
        }
    }
}

// MARK: Matrix Dimension Checks

extension MatrixError {

    static func testSquare<T: MatrixRepresentable>(_ m: T) throws {
        guard m.rows == m.cols else { throw Self.squareOperationOnNonsquareMatrix}
    }
    
    static func testMultiplicationConformance<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.cols == m1.rows else { throw Self.nonconformingMatrices }
    }
    
    static func testEqualSize<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.rows == m1.rows && m0.cols == m1.cols else { throw Self.nonconformingMatrices}
    }
    
    static func testEqualRows<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.rows == m1.rows else { throw Self.nonconformingMatrices}
    }
    
    static func testEqualColumns<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.cols == m1.cols else { throw Self.nonconformingMatrices}
    }

}

