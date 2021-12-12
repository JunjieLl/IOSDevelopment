//
//  CheckBoard.swift
//  AR
//
//  Created by Junjie Li on 12/11/21.
//

import Foundation
import RealityKit

class CheckBoard{
    static func CreateCheckModel(withName name: String) -> ModelEntity{
        if let theURL = Bundle.main.url(forResource: "CheckBoard", withExtension: "usdz") {
            let loadedModel = try! Entity.loadModel(contentsOf: theURL, withName: name)
            return loadedModel
        }
        
        return ModelEntity()
    }
}
