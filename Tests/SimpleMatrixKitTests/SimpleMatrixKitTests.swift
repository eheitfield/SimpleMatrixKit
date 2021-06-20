    import XCTest
    @testable import SimpleMatrixKit

    final class SimpleMatrixKitTests: XCTestCase {

        let m = Matrix(rows: 3, cols: 2, valueArray: [1,2,3,4,5,6])
        let a = Matrix(array2D: [[1,2],[3,4],[5,6]])
        let b = Matrix(array2D: [[7,8],[9,10],[11,12]])
        let c = Matrix(array2D: [[1,2,7,8],[3,4,9,10],[5,6,11,12]])
        let d = Matrix(array2D: [[1,2],[3,4],[5,6],[7,8],[9,10],[11,12]])
        let aTrans = Matrix(array2D: [[1,3,5],[2,4,6]])
        let abSum = Matrix(array2D: [[8,10],[12,14],[16,18]])
        let abDif = Matrix(array2D: [[-6,-6],[-6,-6],[-6,-6]])
        let mDouble = Matrix(rows: 3, cols: 2, valueArray: [2,4,6,8,10,12])
        let aTransb = Matrix(array2D: [[89,98],[116,128]])
        let eye = Matrix(array2D: [[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]])
        let diagFP = Matrix(diagonal: [1.0,2.0,5.0])
        let squareMat = Matrix(rows: 3, cols: 3, valueArray: [1.0,2.0,3.0,4.0,1.0,6.0,7.0,8.0,9.0])
        let det24Mat = Matrix(array2D: [[6.0,2.0,3.0],[1.0,1.0,1.0],[0.0,4.0,9.0]])
        let det0Mat = Matrix(array2D: [[6.0,2.0,3.0],[0.0,0.0,0.0],[0.0,4.0,9.0]])
        let zeros4x4Mat = Matrix<Double>.zeros(rows: 4, cols: 4)
        
        func isClose(m0: Matrix<Double>, m1: Matrix<Double>) -> Bool {
            let tol = 1.0e-5
            return zip(m0.vectorized,m1.vectorized).map { abs($0.0-$0.1) }.max()! < tol
        }
        
        func isClose(v0: Double, v1: Double) -> Bool {
            let tol = 1.0e-5
            return abs(v0-v1) < tol
        }

        
        func testMatrixSubscript() {
            XCTAssertEqual(m[0,0], 1)
            XCTAssertEqual(m[0,1], 2)
            XCTAssertEqual(m[1,0], 3)
            XCTAssertEqual(m[1,1], 4)
            XCTAssertEqual(m[2,0], 5)
            XCTAssertEqual(m[2,1], 6)
        }
        
        func testMatrixInitializers() {
            let array2d = [[1,2],[3,4],[5,6]]
            let literalMatrix: Matrix<Int> = [[1,2],[3,4],[5,6]]
            XCTAssertEqual(m, literalMatrix)
            XCTAssertEqual(m, Matrix(array2D: array2d))
            XCTAssertEqual(Matrix(diagonal: [1.0,1.0,1.0]), eye)
        }
        
        func testSubMatrix() {
            let subMat = Matrix(rows: 2, cols: 2, valueArray: [3,4,5,6])
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
            XCTAssertEqual(d.count, 6)
            print(d)
            XCTAssertEqual(d.flatMap { $0 },d.vectorized)
            let dSlice = d.dropLast(4)
            print(dSlice)
            let trimD = Matrix(dSlice)
            print(trimD)
        }
        
        func testMatrixRow() {
            XCTAssertEqual(m.getRow(0), [1,2])
            XCTAssertEqual(m.getRow(1), [3,4])
            XCTAssertEqual(m.getRow(2), [5,6])
        }
        
        func testMatrixCol() {
            XCTAssertEqual(m.getCol(0), [1,3,5])
            XCTAssertEqual(m.getCol(1), [2,4,6])
        }
        
        func testCat() {
            XCTAssertEqual(try! hCat(a, b), c)
            XCTAssertEqual(try! vCat(a, b), d)
        }
        
        func testTranspose() {
            XCTAssertEqual(a.transpose, aTrans)
        }
        
        func testOperators() {
            XCTAssertEqual(try a+b, abSum)
            XCTAssertEqual(try a-b, abDif)
            XCTAssertEqual(2*m, mDouble)
            XCTAssertEqual(m*2, mDouble)
            XCTAssertEqual(try a.transpose*b, aTransb)
        }
        
        func testStandardForms() {
            XCTAssertEqual(Matrix<Double>.identity(size: 3), eye)
            XCTAssertEqual(Matrix<Double>.zeros(rows: 5, cols: 3), Matrix(rows: 5, cols: 3, constantValue: 0.0))
            XCTAssertEqual(Matrix<Double>.ones(rows: 3, cols: 5), Matrix(rows: 3, cols: 5, constantValue: 1.0))
        }
        
        func testInverse() {
            do {
                let eyeMat = Matrix<Double>.identity(size: det24Mat.rows)
                let invDet24Mat = try NonsingularMatrix(det24Mat).inverse()
                XCTAssertTrue(isClose(m0: eyeMat, m1: try! det24Mat*invDet24Mat))
            } catch {
                print(error.localizedDescription)
                XCTFail()
            }
            XCTAssertThrowsError(try NonsingularMatrix(det0Mat).inverse())
        }
        
        func testMixedTypes() {
            do {
                let nsMat = try NonsingularMatrix(det24Mat)
                let generalMat = try nsMat*eye
                XCTAssertEqual(generalMat, det24Mat)
                let _ = try nsMat <-> diagFP
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
                let beta = try NonsingularMatrix(xx).solve(xy)
                print(beta)
                let beta2 = try NonsingularMatrix(x.transpose*x).inverse() * x.transpose * y
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
