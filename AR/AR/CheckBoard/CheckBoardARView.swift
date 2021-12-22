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
import MultipeerConnectivity

enum Role{
    case host
    case client
}

class CheckBoardARView: ARView, ARCoachingOverlayViewDelegate, ARSessionDelegate{
    init(role: Role){
        self.role = role
        super.init(frame: .zero)
        self.session.delegate = self
    }

    @MainActor @objc required dynamic init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        //        fatalError("init(coder:) has not been implemented")
    }

    @MainActor @objc required dynamic init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        //        fatalError("init(frame:) has not been implemented")
    }
    
    //player
    var player: Int{
        if role == .host{
            return 1
        }
        else{
            return 2
        }
    }
    //host or client
    var role: Role?
    
    //checkboard entity
    //not sync through network
    var checkBoard: CheckBoard?{
        if self.scene.anchors.count > 0{
            return self.scene.anchors[0].children[0] as? CheckBoard
        }
        return nil
    }
    
    //turn
    var isTurn: Bool{
        get{
            (self.checkBoard?.checkBoardComponent?.isTurn)! == self.player
        }
    }
    //change turn
    func changeTurn(){
        self.checkBoard?.checkBoardComponent?.isTurn = 3 - (self.checkBoard?.checkBoardComponent?.isTurn)!
    }
    
    //mutex for multi thread
    var mutex = 1
    
    var devicePeerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    //McSession for colaborate
    var mcSession: MCSession?
    var mcAdvertiser: MCNearbyServiceAdvertiser?
    var mcBrowser: MCNearbyServiceBrowser?
    
    func setUpGestures(){
        //add tap gesture
        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        self.addGestureRecognizer(tapGestureRecongnizer)
    }
    
    // add coachingOverlay
    func addARCoaching(){
        //network synchronization
        self.setupSyncService()
        
        let coachingOverlay = ARCoachingOverlayView()
        
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.activatesAutomatically = true
        //setup tap gesture for the view
        self.setUpGestures()
        //start
        self.addSubview(coachingOverlay)
    }
    //callback when coachingOverlay ends
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false
        //important
        //client has no need to render a new arview, instead reveives a view from host
        if self.role == .host{
            self.addCheckBoard()
        }
    }
    //add checkboard to the view
    func addCheckBoard(){
        let pureAnchor = PureAnchor(name: "anchor")
        
        let checkBoard = try? CheckBoard(dimension: [10,10])
        pureAnchor.addChild(checkBoard!)
//        self.checkBoard = checkBoard
        self.scene.addAnchor(pureAnchor)
        //so that we can drag, scale, rotate the checkboard to fit our view
        self.installGestures(.all, for: checkBoard!)
    }
    
    func touchPiece(touchEntity: Piece){
        if !touchEntity.piece!.isTap{
            //set piece color, player, istap
            touchEntity.playChess(player: player)
            // update data
            let piecePositionIn2D = touchEntity.piece?.positionInMemory
            //by this way we can hava the synchronization
            self.checkBoard?.checkBoardComponent?.setPieceMatrix(position: piecePositionIn2D!, player: player)
            
            //check whther the game is completed: one of participate has won the game or non
            checkIsGameComplete(point: piecePositionIn2D!)
        }
    }
    
    func touchEntity(piece: Piece){
        if piece.isOwner{
            print("piece owner is self")
            touchPiece(touchEntity: piece)
            changeTurn()
        }
        else{
            piece.requestOwnership(){result in
                if result == .granted{
                    print("piece authorized")
                    self.touchPiece(touchEntity: piece)
                    self.changeTurn()
                }
                else{
                    print("piece unauthorized, retry please")
                }
            }
        }
    }
    
    func checkWhetherBeenPlaced(position: SIMD2<Int>) -> Bool{
        let chessPlayer = self.checkBoard?.checkBoardComponent?.pieceMatrix[position[0]][position[1]]
        if chessPlayer == 1 || chessPlayer == 2{
            return true
        }
        return false
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer? = nil){
        if mutex < 1{
            print("mutex")
            return
        }
        mutex -= 1//==0

        //debug
        print("tapped")
        if !isTurn{
            print("It's not my turn")
            mutex += 1
            return
        }
        
        guard let touchPosition = sender?.location(in: self) else{
            mutex += 1
            return
        }
        //debug
//        print(self.scene.anchors)
        // tap piece !
        for touchEntity in self.entities(at: touchPosition){
            if let touchEntity = touchEntity as? Piece{
                if !isTurn{
                    print("It's not my turn")
                    mutex += 1
                    return
                }
                //debug
                print(touchEntity)
                //check is whether been placed
                if checkWhetherBeenPlaced(position: touchEntity.piece!.positionInMemory){
                    print("It has been placed!")
                    mutex += 1
                    return
                }
                //request ownership of checkboard as needed
                if (self.checkBoard?.isOwner)!{
                    print("checkboard ownership is self")
                    self.touchEntity(piece: touchEntity)
                }
                else{
                    self.checkBoard?.requestOwnership {result in
                        if result == .granted{
                            print("checkboard ownership authorized")
                            self.touchEntity(piece: touchEntity)
                        }
                        else{
                            print("checkboard ownership unauthorized")
                        }
                    }
                }
            }
        }
        mutex += 1
    }
    // check whether the game ends
    func checkIsGameComplete(point: SIMD2<Int>){
        var entity: Winner
        let result = self.checkBoard?.checkBoardComponent?.checkWhoWinAt(point: point)
        switch result{
        case 1:
            entity = Winner(content: "blue wins")
            entity.scale = self.checkBoard!.scale / 7.0
            entity.position = [-Float((self.checkBoard?.checkBoardComponent?.dimension[1])!)*0.2/2, 0.2, 0]
            entity.transform.rotation = simd_quatf(angle: -.pi/6, axis: [1, 0, 0])
            self.checkBoard?.addChild(entity)
        case 2:
            entity = Winner(content: "red wins")
            entity.scale = self.checkBoard!.scale / 7.0
            entity.position = [-Float((self.checkBoard?.checkBoardComponent?.dimension[1])!)*0.2/2, 0.2, 0]
            entity.transform.rotation = simd_quatf(angle: -.pi/6, axis: [1, 0, 0])
            self.checkBoard?.addChild(entity)
        case 0:
            print("game not complete, continue")
        case -1:
            print("no one wins the game")
        default:
//            print(result!)
            print("error")
        }
    }
}
