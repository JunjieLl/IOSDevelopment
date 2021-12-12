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
    //gamedata
    var model = Model(dimension: [10, 10])
    
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
    //add checkboard to the view
    func addCheckBoard(){
        let checkBoard = CheckBoard(dimension: model.dimension)
        self.scene.addAnchor(checkBoard)
        //so that we can drag, scale, rotate the checkboard to fit our view
        self.installGestures(.all, for: checkBoard)
        
        //add tap gesture
        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        self.addGestureRecognizer(tapGestureRecongnizer)
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer? = nil){
        print("tapped")
        guard let touchPosition = sender?.location(in: self) else{
            return
        }
        // tap piece !
        for touchEntity in self.entities(at: touchPosition){
            if let touchEntity = touchEntity as? Piece{
                if !touchEntity.piece!.isTap{
                    touchEntity.piece?.participate = .red
                    touchEntity.model?.materials = [SimpleMaterial(color: touchEntity.piece!.pieceColor, isMetallic: false)]
                    touchEntity.piece?.isTap = true
                    //check whther the game is completed: one of participate has won the game or none
                    let piecePositionIn2D = touchEntity.piece?.initialPositionIn2D
                    model.pieceMatrix[piecePositionIn2D![0]][piecePositionIn2D![1]] = 2
                    
                    checkIsGameComplete(point: piecePositionIn2D!)
                }
            }
        }
    }
    // check whether is the game ends
    func checkIsGameComplete(point: SIMD2<Int>){
        let result = model.checkWhoWinAt(point: point)
        switch result{
        case 1:
            print("blue wins")
        case 2:
            print("red wins")
        case 0:
            print("game not complete, continue")
        case -1:
            print("no one wins the game")
        default:
            print("error")
        }
    }
}
