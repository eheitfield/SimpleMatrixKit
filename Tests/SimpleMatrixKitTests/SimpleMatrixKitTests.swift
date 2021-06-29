    import XCTest
    @testable import SimpleMatrixKit

    final class SimpleMatrixKitTests: XCTestCase {
        
        typealias DblMatrix = Matrix<Double>
        
        func isClose(m0: Matrix<Double>, m1: Matrix<Double>) -> Bool {
            let tol = 1.0e-5
            return zip(m0.vectorized,m1.vectorized).map { abs($0.0-$0.1) }.max()! < tol
        }
        
        func isClose(v0: Double, v1: Double) -> Bool {
            let tol = 1.0e-5
            return abs(v0-v1) < tol
        }
        
        func testMatrixSubscript() {
            let m = Matrix(rows: 3, cols: 2, valueArray: [1,2,3,4,5,6])
            XCTAssertEqual(m[0,0], 1)
            XCTAssertEqual(m[0,1], 2)
            XCTAssertEqual(m[1,0], 3)
            XCTAssertEqual(m[1,1], 4)
            XCTAssertEqual(m[2,0], 5)
            XCTAssertEqual(m[2,1], 6)
        }
        
        func testMatrixInitializers() {
            let m = Matrix(rows: 3, cols: 2, valueArray: [1,2,3,4,5,6])
            let array2d = [[1,2],[3,4],[5,6]]
            let literalMatrix: Matrix<Int> = [[1,2],[3,4],[5,6]]
            let eye = Matrix(array2D: [[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]])
            XCTAssertEqual(m, literalMatrix)
            XCTAssertEqual(m, Matrix(array2D: array2d))
            XCTAssertEqual(Matrix(diagonal: [1.0,1.0,1.0]), eye)
        }
        
        func testSubMatrix() {
            let subMat = Matrix(rows: 2, cols: 2, valueArray: [3,4,5,6])
            let m = Matrix(rows: 3, cols: 2, valueArray: [1,2,3,4,5,6])
            let a = Matrix(array2D: [[1,2],[3,4],[5,6]])
            XCTAssertEqual(m[1..<3,0..<2], subMat)
            XCTAssertEqual(m[1...2,0...1], subMat)
            XCTAssertEqual(m[1..., 0...], subMat)
            XCTAssertEqual(m[0... ,0... ], m)
            XCTAssertEqual(a.subMatrix(rowIndexes: [2,1]), Matrix(array2D: [[5,6],[3,4]]))
            XCTAssertEqual(a.subMatrix(colIndexes: [1]), Matrix(array2D: [[2],[4],[6]]))
            XCTAssertEqual(a.submatrix(rowIndexes: [0,1], colIndexes: [0]), Matrix(array2D: [[1],[3]]))
            XCTAssertEqual(a.subMatrix(rowIndexes: [0,2,1]), Matrix(array2D: [[1,2],[5,6],[3,4]]))
        }
        
        func testCollection() {
            let d = Matrix(array2D: [[1,2],[3,4],[5,6],[7,8],[9,10],[11,12]])
            XCTAssertEqual(d.count, 6)
            print(d)
            XCTAssertEqual(d.flatMap { $0 },d.vectorized)
            let dSlice = d.dropLast(4)
            print(dSlice)
            let trimD = Matrix(dSlice)
            print(trimD)
        }
        
        func testMatrixRowAndCol() {
            let m = Matrix(rows: 3, cols: 2, valueArray: [1,2,3,4,5,6])
            XCTAssertEqual(m.getRow(0), [1,2])
            XCTAssertEqual(m.getRow(1), [3,4])
            XCTAssertEqual(m.getRow(2), [5,6])
            XCTAssertEqual(m.getCol(0), [1,3,5])
            XCTAssertEqual(m.getCol(1), [2,4,6])
        }
        
        func testTranspose() {
            let a = Matrix(array2D: [[1,2],[3,4],[5,6]])
            let aTrans = Matrix(array2D: [[1,3,5],[2,4,6]])
            XCTAssertEqual(a.transpose, aTrans)
        }
        
        func testOperators() {
            let m = Matrix(rows: 3, cols: 2, valueArray: [1,2,3,4,5,6])
            let mDouble = Matrix(rows: 3, cols: 2, valueArray: [2,4,6,8,10,12])
            let a =  Matrix(array2D: [[1,2],[3,4],[5,6]])
            let b =  Matrix(array2D: [[7,8],[9,10],[11,12]])
            let c =  Matrix(array2D: [[1,2,7,8],[3,4,9,10],[5,6,11,12]])
            let d =  Matrix(array2D: [[1,2],[3,4],[5,6],[7,8],[9,10],[11,12]])
            let abSum = Matrix(array2D: [[8,10],[12,14],[16,18]])
            let abDif = Matrix(array2D: [[-6,-6],[-6,-6],[-6,-6]])
            let aTransb = Matrix(array2D: [[89,98],[116,128]])
            XCTAssertEqual(try hCat(a, b), c)
            XCTAssertEqual(try vCat(a, b), d)
            XCTAssertEqual(try a+b, abSum)
            XCTAssertEqual(try a-b, abDif)
            XCTAssertEqual(2*m, mDouble)
            XCTAssertEqual(m*2, mDouble)
            XCTAssertEqual(try a.transpose*b, aTransb)
        }
        
        func testStandardForms() {
            let eye = Matrix(array2D: [[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]])
            XCTAssertEqual(Matrix<Double>.identity(size: 3), eye)
            XCTAssertEqual(Matrix<Double>.zeros(rows: 5, cols: 3), Matrix(rows: 5, cols: 3, constantValue: 0.0))
            XCTAssertEqual(Matrix<Double>.ones(rows: 3, cols: 5), Matrix(rows: 3, cols: 5, constantValue: 1.0))
        }
        
        func testSquareRealMatrix() {
            do {
                let a: Matrix<Double> = [
                    [1,2,4],
                    [4,5,6],
                    [7,8,12]
                ]
                let aDet: Double = -12
                let aInv: Matrix<Double> = [
                    [-1.00000,  -0.66667,   0.66667],
                    [ 0.50000,   1.33333,  -0.83333],
                    [ 0.25000,  -0.50000,   0.25000]
                ]
                let b: Matrix<Double> = [
                    [22,33,44,55  ],
                    [7,-11,101,12 ],
                    [0,77,14,123  ],
                    [11,-11,34,45 ]
                ]
                let bDet: Double = -8629346
                let bInv: Matrix<Double> = [
                    [ 0.0480085,  -0.0204822,  -0.0223688,   0.0079262,],
                    [ 0.0127404,   0.0031384,   0.0040498,  -0.0274779,],
                    [-0.0010058,   0.0120589,   0.0013448,  -0.0056623,],
                    [-0.0078612,  -0.0033372,   0.0054418,   0.0178461,]
                ]
                let c: DblMatrix = [
                    [1,2,3,4],
                    [5,6,7,8],
                    [9,19,11,12],
                    [14,15,16,17]
                ]
                let cDet: Double = 0
                let d: DblMatrix = [
                    [1,0,0,0,0],
                    [0,0,1,0,0],
                    [0,0,0,0,1],
                    [0,1,0,0,0],
                    [0,0,0,1,0]
                ]
                let dDet: Double = -1
                print(try SquareRealMatrix(d).determinant())
                XCTAssertTrue(isClose(v0: try SquareRealMatrix(a).determinant(), v1: aDet))
                XCTAssertTrue(isClose(m0: try SquareRealMatrix(a).inverse(), m1: aInv))
                XCTAssertTrue(isClose(v0: try SquareRealMatrix(b).determinant(), v1: bDet))
                XCTAssertTrue(isClose(m0: try SquareRealMatrix(b).inverse(), m1: bInv))
                XCTAssertTrue(isClose(v0: try SquareRealMatrix(c).determinant(), v1: cDet))
                XCTAssertTrue(isClose(v0: try SquareRealMatrix(d).determinant(), v1: dDet))
                XCTAssertTrue(isClose(m0: try SquareRealMatrix(d).inverse(), m1: d.transpose))
            } catch {
                print(error.localizedDescription)
                XCTFail()
            }
        }
        
        func testMixedTypes() {
            do {
                let det24Mat = Matrix(array2D: [[6.0,2.0,3.0],[1.0,1.0,1.0],[0.0,4.0,9.0]])
                let nsMat = try SquareRealMatrix(det24Mat)
                let eye = Matrix(array2D: [[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]])
                let diagFP = Matrix(diagonal: [1.0,2.0,5.0])
                let generalMat = try nsMat*eye
                XCTAssertEqual(generalMat, det24Mat)
                let _ = try nsMat <-> diagFP
            } catch {
                XCTFail()
            }
        }
        
        func testErrors() {
            let m = Matrix(rows: 3, cols: 2, valueArray: [1,2,3,4,5,6])
            let n = Matrix(rows: 2, cols: 3, valueArray: [1,2,3,4,5,6])
            do {
                let _ = try m <|> n
            } catch MatrixError.nonconformingMatrices(rule: let rule) {
                XCTAssertEqual(rule, .horizontalConcatenation)
            } catch {
                XCTFail()
            }
            do {
                let _ = try m <-> n
            } catch MatrixError.nonconformingMatrices(rule: let rule) {
                XCTAssertEqual(rule, .verticalConcatenation)
            } catch {
                XCTFail()
            }
            do {
                let _ = try m + n
            } catch MatrixError.nonconformingMatrices(rule: let rule) {
                XCTAssertEqual(rule, .addition)
            } catch {
                XCTFail()
            }
            do {
                let _ = try n * m
            } catch MatrixError.nonconformingMatrices(rule: let rule) {
                XCTAssertEqual(rule, .multiplication)
            } catch {
                XCTFail()
            }
        }
        
        func testExample() {
            do {
                let data: Matrix<Double> = [
                    [   4,  5,  5   ],
                    [   1,  10, 7   ],
                    [   8,  9,  12  ],
                    [   12, 10, 11  ],
                    [   1,  2,  3   ]
                ]
                let n = data.rows
                let ones = Matrix<Double>.ones(rows: n, cols: 1)
                let avg = try data.transpose * ones / Double(n)
                let resid = try data - ones * avg.transpose
                let mse = try resid.transpose * resid / Double(n)
                let mseAsDouble = mse[0,0]
                print(mseAsDouble)
                let y = Matrix(rows: n, cols: 1, valueArray: [12.2, 14.2, 23.2, 8.0, 9.2])
                let x = try ones <|> data
                let xx = try x.transpose * x
                let xy = try x.transpose * y
                let beta = try SquareRealMatrix(xx).solve(xy)
                print(beta)
                let beta2 = try SquareRealMatrix(x.transpose*x).inverse() * x.transpose * y
                print(beta2)
            } catch MatrixError.singularMatrixTreatedAsNonsingular {
                print("Looks like you have have a problem with multicolinearity.")
                print("Better get some more data or drop some variables!")
            } catch MatrixError.nonconformingMatrices {
                print("Something went wrong.")
                print("Check your matrix dimensions.")
            } catch {
                print("Something terrible has happened and I don't know what it is.")
            }
        }
        
    }
