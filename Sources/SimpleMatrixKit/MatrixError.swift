//
//  File.swift
//  
//
//  Created by Erik Heitfield on 6/19/21.
//

import Foundation

enum MatrixMathError: Error {
    case nonconformingMatrices
    case squareOperationOnNonsquareMatrix
    case symmetricOperationOnNonsymmetricMatrix
    case factorizationUndefined
    case singularMatrixTreatedAsNonsingular
}

extension MatrixMathError: LocalizedError {
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

