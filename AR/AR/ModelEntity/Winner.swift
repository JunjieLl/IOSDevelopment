//
//  Winner.swift
//  AR
//
//  Created by Junjie Li on 12/12/21.
//

import Foundation
import RealityKit

class Winner: Entity, HasModel{
    init(content: String){
        super.init()
        
        let modelComponent = ModelComponent(mesh: MeshResource.generateText(content), materials: [SimpleMaterial(color: .purple, isMetallic: false)])
        self.model = modelComponent
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
