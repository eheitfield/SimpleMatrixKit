//
//  NonsingularMatrix.swift
//  
//
//  Created by Erik Heitfield on 6/15/21.
//

import Foundation

/// A square real matrix.
///
/// This struct provides access to various and properties and methods associated with
/// square matrices.
///
/// Most properties and functions of this type depend on the matrix LUP factorization,
/// which can be costly to compute for large matrices.  For this reason the LUP
/// factorization is computed at the time the matrix is initialized and cached for
/// future use.  
public struct SquareRealMatrix<Value: FloatingPoint> {
    
    public typealias LUPFactors = (l: Matrix<Value>, u: Matrix<Value>, permOrder: [Int], nSwaps: Int)
    
    // MARK: Backing
    
    private let elements: [[Value]]
    private var lupCache: LUPFactors?
    
    // MARK: Public methods and functions
    
    /// LUP factorization of the matrix
    /// - Throws: MatrixError
    /// - Returns: LUPFactors, a tuple with four components
    ///     l: lower triangular matrix
    ///     u: upper tringular matrix
    ///     permOrder: an integer array describing the permutation matrix, p
    ///     nSwaps: count of the number of row swaps in the permutation matrix
    ///
    /// A true permutation matrix can be derived from `permOrder` as
    /// `Matrix<Value>.permutation(order: permOrder)`.
    ///
    /// If A is the square matrix, the LUP decomposition satisfies
    /// PA = LU.
    public func lup() throws -> LUPFactors {
        guard let lup = lupCache else {
            throw MatrixError.factorizationUndefined
        }
        return lup
    }
    
    /// Declare that a matrix is square
    /// - Parameter matrix: a MatrixRepresentable type (should be n x x)
    /// - Throws: MatrixError
    public init<T: MatrixRepresentable>(_ matrix: T) throws where Value == T.Value {
        try MatrixError.testSquare(matrix)
        self.init(array2D: matrix.allRows)
    }
    
    /// Create a square matrix from an array of arrays
    /// - Parameter array2D: array of arrays where all inner array counts must match outer count
    /// - Throws: MatrixError
    public init(array2D: [[Value]]) {
        let rows = array2D.count
        let cols = rows>0 ? array2D[0].count : 0
        guard array2D.allSatisfy({$0.count==cols}) else {
            preconditionFailure("Attempted to instantiate square matrix with non-square array.")
        }
        self.elements = array2D
        lupCache = try? lupFactors()
    }
    
    /// Determinant of the matrix
    /// - Throws: MatrixError
    /// - Returns: matrix determinant
    ///
    /// The determinant is computed using the matrix LUP factorization. If no such
    /// factorization exists the matrix must be singular with zero determinant.
    public func determinant() -> Value {
        guard let lup = lupCache else {
            // If the matrix is singular, its determinant must be zero.
            return Value.zero
        }
        let detP = lup.nSwaps % 2 == 0 ? Value(1) : Value(-1)
        let detL = lup.l.mainDiagonal.reduce(1) { $0*$1 }
        let detU = lup.u.mainDiagonal.reduce(1) { $0*$1 }
        return detP*detL*detU
    }
    
    /// Trace of the matrix
    /// - Returns: MatrixError
    public func trace() -> Value {
        return self.mainDiagonal.reduce(Value.zero) { $0+$1 }
    }

    /// Find the matrix X that satisfies AX=B where A is the
    /// nonsingular matrix.
    /// - Parameter b: matrix of equation system constants (m x n)
    /// - Throws: MatrixError
    /// - Returns: solution matrix (m x n)
    public func solve(_ b: Matrix<Value>) throws -> Matrix<Value> {
        try MatrixError.testEqualRows(self, b)
        guard let lup = lupCache else {
            throw MatrixError.singularMatrixTreatedAsNonsingular
        }
        let p = Matrix<Value>.permutation(order: lup.permOrder)
        let pb = try p*b
        let y = try forwardSolve(l: lup.l, b: pb)
        let x = try backwardSolve(u: lup.u, b: y)
        return x
    }
    
    /// Invert the matrix if it is nonsingular
    /// - Throws: MatrixError
    /// - Returns: the inverse matrix
    public func inverse() throws -> Matrix<Value> {
        return try self.solve(Matrix<Value>.identity(size: self.rows))
    }
    
    // MARK: Internal helper functions
    
    /// LU factorization with partial pivoting.
    /// - Returns:  tuple of three matrices,
    ///             l: lower triangular matrix with ones on main diagonal
    ///             u: upper triangular matrix
    ///             permOrder: permutation mapping
    ///             nSwap: number of row swaps in permutation
    ///
    /// Given a square matrix A, the LUP decomposition has the property that LU = PA.
    /// Note that P is symmetric and P'P = I, so A = PLU.
    ///
    /// The permutation matrix is expressed as permOrder to avoid wasting memory. P can
    /// be computed as `Matrix<Value>.permutation(order: permOrder)`.
    ///
    /// The partial pivoting algorithm used is based on
    /// [this](http://www.math.iit.edu/~fass/477577_Chapter_7.pdf) note.
    private func lupFactors() throws -> LUPFactors {
        
        var uRows = DereferencedRealMatrix(self.elements)
        var lRows = DereferencedRealMatrix(Matrix<Value>.identity(size: self.rows).allRows)
        var nSwaps = 0
        let rows = self.rows
        let cols = self.cols
        for i in 0..<cols-1 {
            // swap rows to maximize pivot value
            var maxIndex = i
            var maxValue = abs(uRows[i,i])
            if i < cols-1 {
                for n in i+1..<rows {
                    let testVal = abs(uRows[n,i])
                    if testVal > maxValue {
                        maxIndex = n
                        maxValue = testVal
                    }
                }
                if maxValue == Value.zero {
                    throw MatrixError.factorizationUndefined
                }
                if i != maxIndex {
                    uRows.swapRows(i,maxIndex)
                    lRows.swapRows(i,maxIndex)
                    // Swapping L columns is important for keeping L lower triangular
                    // and arises from a subtlety in the interaction between permutation
                    // and row addition operations.  It is frustratingly poorly described
                    // in most published discussions of LUP decomposition; indeed many
                    // published examples do not generalize because they ignore this step.
                    lRows.swapCols(i,maxIndex)
                    nSwaps += 1
                }
            }
            // zero out elements of U[.,i] below row i of U and record inverse
            // elementary row operations in L
            for j in i+1..<rows {
                let coef = -uRows[j,i]/uRows[i,i]
                uRows.addToRow(row0: j, row1: i, coef: coef)
                lRows[j,i] = -coef
            }
        }
        let u = Matrix(matrix: uRows)
        let l = Matrix(matrix: lRows)
        return (l,u,uRows.rPtrs,nSwaps)
        
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
        try MatrixError.testEqualRows(l, b)
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
        try MatrixError.testEqualRows(u, b)
        var x = Matrix<Element>.zeros(rows: u.rows, cols: b.cols)
        for j in 0..<b.cols {
            for i in stride(from: u.rows-1, through: 0, by: -1) {
                var sum = Element.zero
                if i < u.rows-1 {
                    for k in i+1..<u.rows {
                        sum += u[i,k]*x[k,j]
                    }
                }
                x[i,j] = (b[i,j]-sum)/u[i,i]
            }
        }
        return x
    }

    
}

// MARK: MatrixRepresentable Conformance

extension SquareRealMatrix: MatrixRepresentable {
    public var allRows: [[Value]] { self.elements }
}

