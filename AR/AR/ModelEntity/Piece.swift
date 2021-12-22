//
//  Piece.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit
import UIKit

class Piece: Entity, HasModel, HasCollision, HasPiece{
    var piece: PieceComponent?{
        get{
            return components[PieceComponent.self] as? PieceComponent
        }
        set{
            components[PieceComponent.self] = newValue
        }
    }
    
    
    //player 1, 2, 3, 4
    init(player: Int, positionInMemory: SIMD2<Int>){
        super.init()
        //pieceComponent
        self.piece = PieceComponent(positionInMemory: positionInMemory, player: player)
        //visible model
        let material = SimpleMaterial(color: PieceComponent.getInitialColor(player: player)!, isMetallic: false)
        let modelComponent = ModelComponent(mesh: MeshResource.generatePlane(width: 0.14, depth: 0.14, cornerRadius: 0.07), materials: [material])
        self.model = modelComponent
        //collision for func entits
        self.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [0.14,0.05,0.14])])
    }
    //change piece color
    func setPlayer(player: Int){
        self.piece?.player = player
        self.model?.materials = [SimpleMaterial(color: PieceComponent.getInitialColor(player: player)!, isMetallic: false)]
        //debug
        print(PieceComponent.getInitialColor(player: player)!)
    }
    //player plays chess
    func playChess(player: Int){
        self.setPlayer(player: player)
        self.piece?.isTap = true
    }
    
    required init() {
//        fatalError("init() has not been implemented")
        super.init()
    }
}
