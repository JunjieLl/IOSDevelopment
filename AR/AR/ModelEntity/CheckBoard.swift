//
//  CheckBoard.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit
import UIKit

class CheckBoard: Entity, HasAnchoring, HasCollision{
    //棋盘尺寸，必须是偶数
    var dimension: SIMD2<Int>?
    
    private var dim: SIMD2<Int>?{
        get{
            if dimension![0] % 2 != 0 || dimension![1] % 2 != 0{
                return [10,10]
            }
            return dimension
        }
    }
    
    var minimumBounds = SIMD2<Float>(0.5, 0.5)
    
    init(dimension: SIMD2<Int>){
        super.init()
        
        self.dimension = dimension
        //create anchor
        let anchorComponent = AnchoringComponent(AnchoringComponent.Target.plane(.horizontal, classification: .any, minimumBounds: minimumBounds))
        self.anchoring = anchorComponent
        // for gesture: scale move and rotate
        self.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [20,0.5,20])])
        
        let maxDim = dim!.max()
        let minBound = minimumBounds.min()
        // scale
        self.scale = SIMD3<Float>(repeating: minBound/Float(maxDim))
        
        //        let pieceCount = dimension[0]*dimension[1]
        
        var count = 1
        for i in 0 ..< dim![0]{
            count += 1
            for j in 0 ..< dim![1]{
                let color = count % 2 == 0 ? UIColor.white: UIColor.black
                count += 1
                
                let block = Block(size: [0.2,0.05,0.2], color: color)
                //coordinate space in view
                block.position = SIMD3<Float>(Float(j)*0.2,0,Float(i)*0.2)
                
                self.addChild(block)
            }
        }
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
