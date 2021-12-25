//
//  CheckBoradComponent.swift
//  AR
//
//  Created by Junjie Li on 12/19/21.
//

import Foundation
import RealityKit

enum MyError: Error{
    case BadDimension
}

struct CheckBoradComponent: Component, Codable{
    //the size of checkBoard, dimension should be even
    var dimension: SIMD2<Int>
    
    //the data of the model
    //1 蓝色， 2 红色, 3为白色，4为黑色
    var pieceMatrix: [[Int]]
    
    //turn to play chess 3 - onePlayer = another player
    var isTurn: Int = 1
    
    //record isGameComplete
    var isComplete: Bool = false
    
    init(dimension: SIMD2<Int>) throws{
        //dimension must be even
        if dimension[0] % 2 != 0 || dimension[1] % 2 != 0{
            throw MyError.BadDimension
        }
        self.dimension = dimension
        
        self.pieceMatrix = [[Int]](repeating: [Int](repeating: 0, count: dimension[1]), count: dimension[0])
    }
    
    mutating func setPieceMatrix(position: SIMD2<Int>, player: Int){
        self.pieceMatrix[position[0]][position[1]] = player
    }
    
    func checkWhoWinAt(point: SIMD2<Int>) -> Int{
        let x = point[0]
        let y = point[1]
        let myFlag = pieceMatrix[x][y]// 1, 2, 3, 4
        
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
                if pieceMatrix[i][j] == 1 || pieceMatrix[i][j] == 2{
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
    
    func getRandomFreePoint() -> SIMD2<Int>{
        var list = [SIMD2<Int>]()
        for i in 0 ..< self.dimension[0]{
            for j in 0 ..< self.dimension[1]{
                if self.pieceMatrix[i][j] != 1 || self.pieceMatrix[i][j] != 2{
                    list.append([i,j])
                }
            }
        }
        if list.count == 0{
            return [-1,-1]
        }
        let index = Int.random(in: 0 ..< list.count)
        return list[index]
    }
}

protocol HasCheckBoardComponent: Entity{
    var checkBoardComponent: CheckBoradComponent? { get set }
}
