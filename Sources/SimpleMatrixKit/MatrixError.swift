//
//  MatrixError.swift
//  
//
//  Created by Erik Heitfield on 6/19/21.
//

import Foundation

// MARK: Matix Manipulation Errors

/// Matrix manipulation errors
public enum MatrixError: Error {

    public enum ConformanceRule {
        case addition, multiplication, horizontalConcatenation, verticalConcatenation
    }
    
    case nonconformingMatrices(rule: ConformanceRule)
    case squareOperationOnNonsquareMatrix
    case symmetricOperationOnNonsymmetricMatrix
    case factorizationUndefined
    case singularMatrixTreatedAsNonsingular
    case matrixManipulationError // generic error type for cases not covered above
    
}

// MARK: Localized Error Conformance

extension MatrixError: LocalizedError {
    public var errorDescription: String? {
        var str = ""
        switch self {
        case .nonconformingMatrices(let rule):
            str += "Operation on nonconforming matrices."
            switch rule {
            case .addition:
                str += "\nLeft and right matrices must be the same size."
            case .multiplication:
                str += "\nLeft matrix row count must match right matrix column count."
            case .horizontalConcatenation:
                str += "\nBoth matrices must have matching row counts."
            case .verticalConcatenation:
                str += "\nBoth matrices must have matching column counts."
            }
        case .squareOperationOnNonsquareMatrix:
            str += "Square matrix operation on non-square matrix."
        case .symmetricOperationOnNonsymmetricMatrix:
            str += "Symmetric matrix operation on non-symmetric matrix."
        case .factorizationUndefined:
            str += "Matrix factorization undefined."
        case .singularMatrixTreatedAsNonsingular:
            str += "Nonsingular matrix operation on singular matrix."
        default:
            str += "Matrix manipulation error."
        }
        return str
    }
}

// MARK: Matrix Dimension Checks

extension MatrixError {

    static func testSquare<T: MatrixRepresentable>(_ m: T) throws {
        guard m.rows == m.cols else { throw Self.squareOperationOnNonsquareMatrix}
    }
    
    static func testMultiplicationConformance<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.cols == m1.rows else { throw Self.nonconformingMatrices(rule: .multiplication) }
    }
    
    static func testEqualSize<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.rows == m1.rows && m0.cols == m1.cols else { throw Self.nonconformingMatrices(rule: .addition) }
    }
    
    static func testEqualRows<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.rows == m1.rows else { throw Self.nonconformingMatrices(rule: .horizontalConcatenation) }
    }
    
    static func testEqualColumns<T: MatrixRepresentable, U: MatrixRepresentable>(_ m0: T, _ m1: U) throws {
        guard m0.cols == m1.cols else { throw Self.nonconformingMatrices(rule: .verticalConcatenation) }
    }

}

