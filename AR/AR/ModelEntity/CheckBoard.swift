//
//  CheckBoard.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit
import UIKit

class CheckBoard: Entity, HasCollision, HasCheckBoardComponent{
    //data of checkBoard
    var checkBoardComponent: CheckBoradComponent?{
        get{
            return components[CheckBoradComponent.self] as? CheckBoradComponent
        }
        set{
            components[CheckBoradComponent.self] = newValue
        }
    }
    
    init(dimension: SIMD2<Int>) throws{
        super.init()
        
        self.name = "myCheckBoard"
        self.checkBoardComponent = try? CheckBoradComponent(dimension: dimension)
        
        //minimum bounds
        let minimunBounds = SIMD2<Float>(0.5, 0.5)
//        let anchorComponent = AnchoringComponent(AnchoringComponent.Target.plane(.horizontal, classification: .any, minimumBounds: minimunBounds))
//        self.anchoring = anchorComponent
        
        //for gestures with collision
        let collisionComponent = CollisionComponent(shapes: [ShapeResource.generateBox(size: [20, 0.5, 20])])
        self.collision = collisionComponent
        
        let maxDim = dimension.max()
        let minBound = minimunBounds.min()
        //scale
        self.scale = SIMD3<Float>(repeating: minBound/Float(maxDim))
        //template block with piece
        let templateBlock = Block(size: [0.2, 0.05, 0.2], player: 3, initialPositionIn2D: [0,0])
        //add pieces for game
        var count = 1
        for i in 0 ..< dimension[0]{
            count += 1
            for j in 0 ..< dimension[1]{
                let player = count % 2 == 0 ? 3 : 4
                count += 1
                
                let block = self.cloneEntity(block: templateBlock, player: player, i: i, j: j)
                self.addChild(block)
            }
        }
    }
    
    func cloneEntity(block: Block, player: Int, i: Int, j: Int) -> Block{
        let newBlock = block.clone(recursive: true)
        let dimension = self.checkBoardComponent?.dimension
        
        let pieceName = String(i) + String(j)
        newBlock.setChilePiece(player: player, initialPositionIn2D: [i, j], pieceName: pieceName)
        //coordinate space in view
        //Panning to the center
        newBlock.model?.materials = [SimpleMaterial(color: PieceComponent.getInitialColor(player: player)!, isMetallic: false)]
        newBlock.position = SIMD3<Float>(Float(j)*0.2 - Float(dimension![1])*0.2/2, 0, Float(i)*0.2 - Float(dimension![0])*0.2/2)
        //update data
        self.checkBoardComponent?.setPieceMatrix(position: [i, j], player: player)
        
        return newBlock
    }
    
    required init() {
        //        fatalError("init() has not been implemented")
        super.init()
    }
}
