# SimpleMatrixKit

## Overview

SimpleMatrixKit is an easy-to-use matrix library for Swift.  The library is built around a generic `Matrix` type which provides functionality for storing and manipulating balanced, two-dimensional arrays of objects.  This struct can be used in any circumstance where you might normally use an array of array types but would like to enforce the constraint that all inner arrays have the same length.  `Matrix` includes methods for accessing individual elements,  extracting submatrices, and producing derived matrices such as the matrix transpose.  `Matrix` can be treated as a `Collection`  where each element corresponds to a row of the matrix. The library includes two operators, `<|>` and `<->`, for horizontally and vertically concatenating appropriately conformable matrices.

More functionality is available for matrices of numerical values.  The library supports the standard matrix operators `+`, `-`, and `*` for matrices of `Numeric` types, which include both integers and floating point numbers. Most other linear algebra functionality requires that matrix values conform to the `FloatingPoint` protocol, which includes `Double`, `Float`, and `CGFloat`.  The `SquareRealMatrix` type provides properties and methods for working with square matrices. `SquareRealMatrix` types can report their determinants, traces, and LUP factorizations.  If they are nonsingular, they can be inverted or used for linear system solving. 

The library's `MatrixRepresentable` protocol allows users to define their own matrix types.  In order to conform
to this protocol a type must simply be able to provide an array of its rows.  This protocol provides a number of standard matrix properties and methods, and conforming types can be used with the various matrix operators described above. Both `Matrix` and `SquareRealMatrix` conform to `MatrixRepresentable` so, for example, one can use the `*` operator to multiply a `Matrix` type by a `SquareRealMatrix` type provided that both hold the same types of values. Note, however, that most matrix operators and methods return a `Matrix` type, regardless of the types passed as inputs.   

## Handling Errors

Manipulating matrices is notoriously error prone.  Some errors, like attempting to add two differently sized matrices, are boneheaded but very common.  Other errors, such as attempting to invert a singular matrix, may not be detectable until detailed and sometimes costly calculations are performed.  Error handling is a design challenge for any API, but it is particularly important in Swift where users expect to benefit from strong type checking.  In principle, many types of matrix manipulation errors could be detected at compile time by, for example, treating each matrix of a different size as a distinct type.  In practice, however, such approaches add considerably to API and codebase complexity, and are not always practical.  This library tries to take a middle road by making ample use of Swift's run-time error handling mechanisms. Broadly, if you attempt to initialize a matrix improperly or access an out-of-range element your code will crash. This is consistent with the way Swift handles arrays.  On the other hand, if you attempt to combine two non-conformable matrices or invert a nonsingular matrix, the library with throw an error that you can then resolve as you see fit. A consequence of this approach is that your matrix manipulation code will have a lot of `try`s in it, but I regard this as a small price to pay for the flexibility and safety that run-time error checking provides.

## Usage Example

Suppose you have a dataset of five observations on three variables.  You might choose to organize these data into a matrix as follows:
```
let data: Matrix<Double> = [ 
    [   4,  5,  5   ],
    [   1,  10, 7   ],
    [   8,  9,  12  ],
    [   12, 10, 11  ],
    [   1,  2,  3   ]
]
```
A column vector of averages can then be expressed as
```
let n = data.rows
let ones = Matrix<Double>.ones(rows: n, cols: 1)
let avg = try data.transpose * ones / Double(n)
```
And residuals can be computed as
```
let resid = try data - ones * avg.transpose
```
The mean squared error is
```
let mse = try resid.transpose * resid / Double(n)
```
Here `mse` is a 1x1 element matrix.  We can use a subscript to access the underlying `Double` value.
```
let mseAsDouble = mse[0,0]
```

To illustrate operations involving nonsingular matrices, let's add a new dependent variable organized as a column vector.
```
let y = Matrix(rows: n, cols: 1, valueArray: [12.2, 14.2, 23.2, 8.0, 9.2])
```
We can now compute coefficients for a regression of `y` on our original variables plus a constant.
```
let x = try ones <|> data
let xx = try x.transpose * x
let xy = try x.transpose * y
let beta = try SquareRealMatrix(xx).solve(xy)
```
Here's a more concise but less efficient way of computing beta.
```
let beta2 = try SquareRealMatrix(x.transpose*x).inverse() * x.transpose * y
```
In general it's best to avoid calculating the matrix inverse if it isn't needed.  ``beta2`` requires about four times as many calculations as ``beta``.

Here's what the example code above might look like with error handling.
```
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
    // 389830.0
    let y = Matrix(rows: n, cols: 1, valueArray: [12.2, 14.2, 23.2, 8.0, 9.2])
    let x = try ones <|> data
    let xx = try x.transpose * x
    let xy = try x.transpose * y
    let beta = try SquareRealMatrix(xx).solve(xy)
    print(beta)
    // 4 x 1 Matrix:
    // [  4.5908 ]
    // [  -1.920 ]
    // [  -1.556 ]
    // [  3.9427 ]
    let beta2 = try SquareRealMatrix(x.transpose*x).inverse() * x.transpose * y
    print(beta2)
    // 4 x 1 Matrix:
    // [  4.5908 ]
    // [  -1.920 ]
    // [  -1.556 ]
    // [  3.9427 ]    
} catch MatrixError.singularMatrixTreatedAsNonsingular {
    print("Looks like you have have a problem with multicolinearity.")
    print("Better get some more data or drop a variable!")
} catch MatrixError.nonconformingMatrices {
    print("Check your matrix dimensions.")
} catch {
    print("Something terrible has happened and I don't know what it is.")
}
```

## A Few Words about Efficiency

There is a vast literature on the efficient use of processing cycles and storage in numerical linear analysis and SimpleMatrixKit takes advantage of almost none of it.  In designing SimpleMatrixKit, I wanted to produce a library with few dependencies, that is easy to use, and whose codebase can be understood by a typical Swift user.  All algorithms used in SimpleMatrixKit are implemented in Swift 5.3 and use of no external dependancies beyond Foundation.  I have attempted to employ algorithms that are efficient under general conditions, but I have not obsessed about optimizing them.  Likewise, the library does not distinguish between dense and sparse matrices and there are many instances in which the library uses more memory than it needs to by creating new data structures rather than mutating existing ones.  I would characterize SimpleMatrixKit as best suited to problems involving dense matrices of small or moderate size, where code clarity and flexibility may be viewed as more important than computational efficiency. For problems that don't meet these criteria, I recommend looking at other, more specialized, libraries.  Apple's [Accelerate framework](https://developer.apple.com/documentation/accelerate) is a good place to start.

## License

This project is licensed under the terms of the MIT license.
