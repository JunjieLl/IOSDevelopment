//
//  Block.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit
import UIKit

class Block: Entity, HasModel, HasCollision{
    //the size of a block which hold a piece
//    var size: SIMD3<Float>?
    
    init(size: SIMD3<Float>, player: Int, initialPositionIn2D: SIMD2<Int>){
        super.init()
        
//        self.size = size
        let material = SimpleMaterial(color: PieceComponent.getInitialColor(player: player)!, isMetallic: false)
        let modelComponent = ModelComponent(mesh: MeshResource.generateBox(size: size), materials: [material])
        self.model = modelComponent
        
        let piece = Piece(player: player, positionInMemory: initialPositionIn2D)
        piece.name = "piece"
        piece.position.y = 0.05
        self.addChild(piece)
    }
    
    func setChilePiece(player: Int, initialPositionIn2D: SIMD2<Int>){
        let piece = self.findEntity(named: "piece") as? Piece
        //set map
        piece?.piece?.positionInMemory = initialPositionIn2D
        //set color, player
        piece?.setPlayer(player: player)
    }
    
    required init() {
        super.init()
    }
}
