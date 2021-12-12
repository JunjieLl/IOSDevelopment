//
//  Piece.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit
import UIKit

enum Participate{
    case red
    case blue
    case initialization
}

class PieceComponent: Component{
    //whether the piece has been tapped
    var isTap: Bool = false
    //2为透明，0，1为双方棋子
    var participate: Participate = .initialization
    //color of piece
    var pieceColor: UIColor{
        get{
            switch participate{
            case .blue:
                return .systemBlue
            case .red:
                return .systemRed
            default:
                return .clear
            }
        }
    }
    
    init(participate: Participate){
        self.participate = participate
    }
}

protocol HasPiece{
    var piece: PieceComponent? { get set }
}

class Piece: Entity, HasModel, HasCollision, HasPiece{
    var piece: PieceComponent?
    
    //constructor
    init(participate: Participate) {
        super.init()
        
        self.piece = PieceComponent(participate: participate)
        //visible model
        let modelComponent = ModelComponent(mesh: MeshResource.generatePlane(width: 0.14, depth: 0.14, cornerRadius: 0.07), materials: [SimpleMaterial(color: self.piece!.pieceColor, isMetallic: false)])
        self.model = modelComponent
        // collision for tap and find
        self.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [0.14,0.05,0.14])])
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
