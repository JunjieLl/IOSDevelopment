//
//  Model.swift.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation

class Model{
    //dimension should be even
    var dimension: SIMD2<Int>
    //0为未点击，1，2为双方， 1 蓝色， 2 红色
    var pieceMatrix: [[Int]]
    
    init(dimension: SIMD2<Int>){
        self.dimension = dimension
        pieceMatrix = [[Int]](repeating: [Int](repeating: 0, count: dimension[1]), count: dimension[0])
    }
    // 1 for blue, 2 for red, 0 for not complete, -1 for peer
    func checkWhoWinAt(point: SIMD2<Int>) -> Int{
        let x = point[0]
        let y = point[1]
        let myFlag = pieceMatrix[x][y]// 0, 1, 2
        
        var myFlagCount = 0
        // |
        // find the most up
        var i = 0
        while i + x < dimension[0] && myFlag == pieceMatrix[i+x][y]{
            i += 1
        }
        i -= 1
        while i + x >= 0 && myFlag == pieceMatrix[i+x][y]{
            myFlagCount += 1
            i -= 1
        }
        if myFlagCount >= 5{
            return myFlag
        }
        
        // --
        i = 0
        myFlagCount = 0
        while i + y < dimension[1] && myFlag == pieceMatrix[x][y+i]{
            i += 1
        }
        i -= 1
        while i + y >= 0 && myFlag == pieceMatrix[x][y+i]{
            myFlagCount += 1
            i -= 1
        }
        if myFlagCount >= 5{
            return myFlag
        }
        
        // /
        i = 0
        myFlagCount = 0
        while i + x < dimension[0] && i + y < dimension[1] && myFlag == pieceMatrix[x+i][y+i]{
            i += 1
        }
        i -= 1
        while i + x >= 0 && i + y >= 0 && myFlag == pieceMatrix[x+i][y+i]{
            myFlagCount += 1
            i -= 1
        }
        if myFlagCount >= 5{
            return myFlag
        }
        
        // \
        i = 0
        myFlagCount = 0
        while i + x < dimension[0] && y - i >= 0 && myFlag == pieceMatrix[x+i][y-i]{
            i += 1
        }
        i -= 1
        while x + i >= 0 && y - i < dimension[1] && myFlag == pieceMatrix[x+i][y-i]{
            myFlagCount += 1
            i -= 1
        }
        if myFlagCount >= 5{
            return myFlag
        }
        
        // total piece in checkboard
        var count = 0
        for i in 0 ..< dimension[0]{
            for j in 0 ..< dimension[1]{
                if pieceMatrix[i][j] > 0{
                    count += 1
                }
            }
        }
        // no one wins
        if count == dimension[0]*dimension[1]{
            return -1
        }
        // not complete
        return 0
    }
}
