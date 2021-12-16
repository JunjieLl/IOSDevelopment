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
    var piece: PieceComponent?
    
    //constructor
    init(participate: Participate, initialColor: UIColor, initialPositionIn2D: SIMD2<Int>) {
        super.init()
        
        self.piece = PieceComponent(participate: participate,initialColor: initialColor, initialPositionIn2D: initialPositionIn2D)
        //visible model
        let modelComponent = ModelComponent(mesh: MeshResource.generatePlane(width: 0.14, depth: 0.14, cornerRadius: 0.07), materials: [SimpleMaterial(color: self.piece!.pieceColor, isMetallic: false)])
        self.model = modelComponent
        // collision for tap and find
        self.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [0.14,0.05,0.14])])
    }
    
    required init() {
        super.init()
//        fatalError("init() has not been implemented")
    }
}
