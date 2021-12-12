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
enum Participate{
    case red
    case blue
    case initialization
}

class PieceComponent: Component{
    //whether the piece has been tapped
    var isTap: Bool = false
    //0为未点击，1，2为双方， 1 蓝色， 2 红色
    var participate: Participate = .initialization
    
    private let initialColor: UIColor
    // use to check who wins
    let initialPositionIn2D: SIMD2<Int>
    //color of piece
    var pieceColor: UIColor{
        get{
            switch participate{
            case .blue:
                return .systemBlue
            case .red:
                return .systemRed
            default:
                return initialColor
            }
        }
    }
    
    init(participate: Participate, initialColor: UIColor, initialPositionIn2D: SIMD2<Int>){
        self.participate = participate
        self.initialColor = initialColor
        self.initialPositionIn2D = initialPositionIn2D
    }
}

protocol HasPiece{
    var piece: PieceComponent? { get set }
}
