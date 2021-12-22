//
//  PureAnchor.swift
//  AR
//
//  Created by Junjie Li on 12/22/21.
//

import Foundation
import RealityKit

class PureAnchor: Entity, HasAnchoring{
    required init(){
        super.init()
    }
    
    init(name: String){
        super.init()
        self.name = name
        
        let minimunBounds = SIMD2<Float>(0.5, 0.5)
        self.anchoring = AnchoringComponent(AnchoringComponent.Target.plane(.horizontal, classification: .any, minimumBounds: minimunBounds))
    }
}
