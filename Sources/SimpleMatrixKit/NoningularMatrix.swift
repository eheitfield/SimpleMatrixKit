//
//  NonsingularMatrix.swift
//  
//
//  Created by Erik Heitfield on 6/15/21.
//

import Foundation

/// A nonsingular real matrix
public struct NonsingularMatrix<Value: FloatingPoint> {
    
    /// The non-singular matrix expressed as a general matrix
    public let matrix: Matrix<Value>
    /// Lower triangular part of PA=LU decomposition
    public let l: Matrix<Value>
    /// Upper triangular part of PA=LU decomposition
    public let u: Matrix<Value>
    /// Permutation part of PA=LU decomposition
    public let p: Matrix<Value>
    
    init(_ matrix: Matrix<Value>) throws {
        guard matrix.isSquare else {
            throw MatrixError.squareOperationOnNonsquareMatrix
        }
        self.matrix = matrix
        do {
            let (l,u,p) = try Self.lupFactors(a: matrix)
            self.l = l
            self.u = u
            self.p = p
        } catch {
            throw MatrixError.singularMatrixTreatedAsNonsingular
        }
    }
    
    /// Find the matrix X that satisfies AX=B where A is the
    /// nonsingular matrix.
    /// - Parameter b: matrix of equation system constants (m x n)
    /// - Throws: MatrixError
    /// - Returns: solution matrix (m x n)
    public func solve(_ b: Matrix<Value>) throws -> Matrix<Value> {
        guard matrix.rows == b.rows else {
            throw MatrixError.nonconformingMatrices
        }
        let pb = try p*b
        let y = try forwardSolve(l: l, b: pb)
        let x = try backwardSolve(u: u, b: y)
        return x
    }
    
    /// Invert the nonsingular matrix
    /// - Throws: MatrixError
    /// - Returns: the inverse matrix
    public func inverse() throws -> Matrix<Value> {
        return try self.solve(Matrix<Value>.identity(size: self.matrix.rows))
    }
    
    
    // TODO: This code has not been tested and may ultimately be moved
    // to a separate class for symmetric positive definite matrices.
    /// Cholesky factorization of the symmetric matrix
    /// - Throws: MatrixError
    /// - Returns: the Cholesky factorization of the nonsingular matrix
    ///
    /// Given a symmetric positive definite matrix A, the Cholesky
    /// factorization L has the property that LL' = A
    private func cholesky() throws -> Matrix<Value> {
        guard self.matrix.isSymmetric else {
            throw MatrixError.symmetricOperationOnNonsymmetricMatrix
        }
        var l = Matrix(rows: self.matrix.rows, cols: self.matrix.rows, constantValue: Value.zero)
        for i in 0..<self.matrix.rows {
            var sum = Value.zero
            for j in 0...i {
                for k in 0..<j {
                    sum += l[i,k]*l[j,k]
                }
                if i==j {
                    l[i,j] = sqrt(self.matrix[i,i]-sum)
                } else {
                    l[i,j] = Value(1)/l[j,j]*(self.matrix[i,j]-sum)
                }
            }
        }
        return l
    }

    
    /// LU factorization with partial pivoting.
    /// - Returns:  tuple of three matrices,
    ///             l: lower triangular matrix with ones on main diagonal
    ///             u: upper triangular matrix
    ///             p: permutation matrix
    ///
    /// Given a square matrix A, the LUP decomposition has the property that LU = PA.
    /// Note that P'P = I, so A = P'LU.
    private static func lupFactors(a: Matrix<Value>) throws -> (l: Matrix<Value>, u: Matrix<Value>, p: Matrix<Value>) {
        var a = a
        var l = Matrix(rows: a.rows, cols: a.rows, constantValue: Value.zero)
        var u = Matrix(rows: a.rows, cols: a.rows, constantValue: Value.zero)
        var p = Matrix<Value>.identity(size: a.rows)
        
        // permute matrix for non-zero diagonals
        for i in 0..<a.cols {
            if a[i,i] == 0 {
                var needSwap = true
                var j = 0
                while needSwap && j<a.rows {
                    if a[j,i] != 0 && a[i,j] != 0 {
                        var order = (0..<a.rows).map { $0 }
                        order[i] = j
                        order[j] = i
                        a = a.subMatrix(rowIndexes: order)
                        p = p.subMatrix(rowIndexes: order)
                        needSwap = false
                    }
                    j += 1
                }
                if needSwap {
                    throw MatrixError.factorizationUndefined
                }
            }
        }
        
        // LU decomposition of permuted matrix
        for i in 0..<a.rows {
            for k in i..<a.rows {
                var sum = Value.zero
                for j in 0..<i {
                    sum += l[i,j] * u[j,k]
                }
                u[i,k] = a[i,k] - sum
            }
            for k in i..<a.rows {
                if i==k { l[i,k] = Value(exactly: 1)! }
                else {
                    var sum = Value.zero
                    for j in 0..<i {
                        sum += l[k,j] * u[j,i]
                    }
                    l[k,i] = (a[k,i] - sum)/u[i,i]
                }
            }
            
        }
        return (l,u,p)
    }

    /// Solve system LX=B where L is a lower triangular matrix with nonzero diagonals.
    /// - Parameters:
    ///   - l: nonsingular lower trianngular matrix (n x n)
    ///   - b: matrix of constants (n x m)
    /// - Throws: L and B must be conformable.
    /// - Returns: solution matrix (n x m)
    ///
    /// This function is mainly used as an intermediate step in solving systems of equations.
    private func forwardSolve<Element: FloatingPoint>(l: Matrix<Element>, b: Matrix<Element>) throws -> Matrix<Element> {
        guard l.isSquare else {
            throw MatrixError.squareOperationOnNonsquareMatrix
        }
        guard l.rows == b.rows && !b.isEmpty else {
            throw MatrixError.nonconformingMatrices
        }
        var x = Matrix<Element>.zeros(rows: l.rows, cols: b.cols)
        for j in 0..<b.cols {
            for i in 0..<l.rows {
                var sum = Element.zero
                if i > 0 {
                    for k in 0...i-1 {
                        sum += l[i,k]*x[k,j]
                    }
                }
                x[i,j] = (b[i,j]-sum)/l[i,i]
            }
        }
        return x
    }
    
    /// Solve system UX=B where U is an upper triangular matrix with nonzero diagonals
    /// - Parameters:
    ///   - u: nonsingular upper triangular matrix (n x n)
    ///   - b: matrix of constants (n x m)
    /// - Throws: U and B must be conformable
    /// - Returns: solution matrix (n x m)
    private func backwardSolve<Element: FloatingPoint>(u: Matrix<Element>, b: Matrix<Element>) throws -> Matrix<Element> {
        let reverseOrder = (0..<u.rows).reversed().map { $0 }
        let l = u.subMatrix(rowIndexes: reverseOrder).subMatrix(colIndexes: reverseOrder)
        let bReversed = b.subMatrix(rowIndexes: reverseOrder)
        let xReversed = try forwardSolve(l: l, b: bReversed)
        return xReversed.subMatrix(rowIndexes: reverseOrder)
    }
    
}

// MARK: MatrixRepresentable Conformance

extension NonsingularMatrix: MatrixRepresentable {
    public var allRows: [[Value]] { self.matrix.allRows }
}

