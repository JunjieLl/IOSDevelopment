//
//  PieceComponent.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit
import UIKit
//player


// network synchronization
struct PieceComponent: Component, Codable{
    //whether the piece has been tapped
    var isTap: Bool = false
    
    //participate 1 blue 2 red, 3(white) and 4(black) initial color consitent with block
    var player: Int
    
    //getColor of the piece to render
    static func getInitialColor(player: Int) -> UIColor?{
        if player == 3{
            return UIColor.white
        }
        else if player == 4{
            return .black
        }
        else if player == 1{
            return .systemBlue
        }
        else if player == 2{
            return .systemRed
        }
        return nil
    }
    
    //map between memory and world
    var positionInMemory: SIMD2<Int>
    
    //initializer
    init(positionInMemory: SIMD2<Int>, player: Int){
        self.positionInMemory = positionInMemory
        self.player = player
    }
}

protocol HasPiece{
    var piece: PieceComponent?{get set}
}
