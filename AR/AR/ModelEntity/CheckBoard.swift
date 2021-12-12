//
//  CheckBoard.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit
import UIKit

enum MyError: Error{
    case BadDimension
}

class CheckBoard: Entity, HasAnchoring, HasCollision{
    //棋盘尺寸，必须是偶数
    var dimension: SIMD2<Int>?
    
    private var dim: SIMD2<Int>?{
        get throws{
            if dimension![0] % 2 != 0 || dimension![1] % 2 != 0{
                throw MyError.BadDimension
            }
            return dimension
        }
    }
    
    var minimumBounds = SIMD2<Float>(1, 1)
    
    init(dimension: SIMD2<Int>){
        super.init()
        
        self.dimension = dimension
        //create anchor
        let anchorComponent = AnchoringComponent(AnchoringComponent.Target.plane(.horizontal, classification: .any, minimumBounds: minimumBounds))
        self.anchoring = anchorComponent
        // for gesture: scale move and rotate
        self.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [20, 0.5, 20])])
        
        let safeDim = try! dim!
        
        let maxDim = safeDim.max()
        let minBound = minimumBounds.min()
        // scale
        self.scale = SIMD3<Float>(repeating: minBound/Float(maxDim))
        
        //        let pieceCount = dimension[0]*dimension[1]
        var count = 1
        for i in 0 ..< safeDim[0]{
            count += 1
            for j in 0 ..< safeDim[1]{
                let color = count % 2 == 0 ? UIColor.white: UIColor.black
                count += 1
                
                let block = Block(size: [0.2, 0.05, 0.2], color: color, initialPositionIn2D: [i,j])
                //coordinate space in view
                //Panning to the center
                block.position = SIMD3<Float>(Float(j)*0.2 - Float(dimension[1])*0.2/2, 0, Float(i)*0.2 - Float(dimension[0])*0.2/2)
                
                self.addChild(block)
            }
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
