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
    var size: SIMD3<Float>?
    
    init(size: SIMD3<Float>, color: UIColor, initialPositionIn2D: SIMD2<Int>){
        super.init()
        
        self.size = size
        
        let material = SimpleMaterial(color: color, isMetallic: false)
        let modelComponent = ModelComponent(mesh: MeshResource.generateBox(size: size), materials: [material])
        self.model = modelComponent
        
        let piece = Piece(participate: .initialization, initialColor: color, initialPositionIn2D: initialPositionIn2D)
        piece.position.y = 0.05
        self.addChild(piece)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
