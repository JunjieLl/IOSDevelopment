//
//  CheckBoardARView.swift
//  AR
//
//  Created by Junjie Li on 12/11/21.
//

import Foundation
import RealityKit
import CoreGraphics
import CoreFoundation
import UIKit
import ARKit

class CheckBoardARView: ARView, ARCoachingOverlayViewDelegate{        
    // add coachingOverlay
    func addARCoaching(){
        let coachingOverlay = ARCoachingOverlayView()
        
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.activatesAutomatically = true
        
        self.addSubview(coachingOverlay)
    }
    //callback when coachingOverlay ends
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false
        
        self.addCheckBoard()
    }
    
    func addCheckBoard(){
        let checkBoard = CheckBoard(dimension: [10,10])
        self.scene.addAnchor(checkBoard)
        
        self.installGestures(.all, for: checkBoard)
        
        //tap gesture
        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        self.addGestureRecognizer(tapGestureRecongnizer)
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer? = nil){
        print("tapped")
        guard let touchPosition = sender?.location(in: self) else{
            return
        }
        
        for touchEntity in self.entities(at: touchPosition){
            if let touchEntity = touchEntity as? Piece{
                if !touchEntity.piece!.isTap{
                    touchEntity.piece?.participate = .red
                    touchEntity.model?.materials = [SimpleMaterial(color: touchEntity.piece!.pieceColor, isMetallic: false)]
                    touchEntity.piece?.isTap = false
                }
            }
        }
    }
}
