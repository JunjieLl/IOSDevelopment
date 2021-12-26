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
    init(role: Role, isSelfPlay: Bool){
        self.role = role
        self.isSelfPlay = isSelfPlay
        super.init(frame: .zero)
        self.session.delegate = self
    }
    
    var isSelfPlay: Bool?
    
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
            if let c = self.checkBoard{
                return (c.checkBoardComponent?.isTurn)! == self.player && !((c.checkBoardComponent?.isComplete)!)
            }
            return false
        }
    }
    //change turn
    func changeTurn(){
        self.checkBoard?.checkBoardComponent?.isTurn = 3 - (self.checkBoard?.checkBoardComponent?.isTurn)!
    }
    //is win
    var isWin: Bool = false
    
    //mutex for multi thread
    var mutex = 1
    //loading game
    var isCompleteCoaching: Bool = false
    var isAddCheckBboard: Bool = false
    
    var devicePeerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    //McSession for colaborate
    var mcSession: MCSession?
    var mcAdvertiser: MCNearbyServiceAdvertiser?
    var mcBrowser: MCNearbyServiceBrowser?
    //text view
    var textView: UITextView?
    var whoTurn: String{
        if !self.isCompleteCoaching{
            return "waiting"
        }
        if self.role == .host && !self.isAddCheckBboard{
            return "put board"
        }
        if self.isWin{
            return "you won it"
        }
        else if let c = self.checkBoard{
            if (c.checkBoardComponent?.isComplete)!{
                return "you lose"
            }
        }
        if self.player == 1{
            return self.isTurn ? "blue" : "red"
        }
        return self.isTurn ? "red" : "blue"
    }
    
    func updateUITextView(timer: Timer){
        self.textView!.text = self.whoTurn
    }
    
    func setUpGestures(){
        //add tap gesture
        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        self.addGestureRecognizer(tapGestureRecongnizer)
    }
    
    // add coachingOverlay
    func addARCoaching(){
        //network synchronization
        if !self.isSelfPlay!{
            self.setupSyncService()
        }
        
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
        
        //add textView
        self.textView = UITextView()
        self.textView?.font = UIFont.systemFont(ofSize: 25)
        self.textView!.text = self.whoTurn
        self.textView?.translatesAutoresizingMaskIntoConstraints = false
        self.textView?.textColor = .systemBlue
        self.textView?.textAlignment = .center
        self.textView?.isEditable = false
        self.textView?.backgroundColor = .clear
        self.addSubview(self.textView!)
        let centerYConstraint = NSLayoutConstraint(item: self.textView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        centerYConstraint.isActive = true
        let topConstraint = NSLayoutConstraint(item: self.textView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40)
        topConstraint.isActive = true
        let heightConstraint = NSLayoutConstraint(item: self.textView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 45)
        heightConstraint.isActive = true
        let widthConstraint = NSLayoutConstraint(item: self.textView!, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 60, constant: 0)
        widthConstraint.isActive = true
        //update textView in certainInterval
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: self.updateUITextView)
    }
    //callback when coachingOverlay ends
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlayView.activatesAutomatically = false
        
        self.isCompleteCoaching = true
        self.textView!.text = self.whoTurn
        //important
        //client has no need to render a new arview, instead reveives a view from host
//        if self.role == .host && !self.isAddCheckBboard{
//            self.addCheckBoard()
//        }
    }
    //add checkboard to the view
    func addCheckBoard(transform: simd_float4x4){
        // Create ARKit ARAnchor and add to ARSession
        let arAnchor = ARAnchor(transform: transform)
        self.session.add(anchor: arAnchor)
        
        let pureAnchor = PureAnchor(name: "anchor")
        
        let checkBoard = try? CheckBoard(dimension: [10,10])
        pureAnchor.addChild(checkBoard!)
//        self.checkBoard = checkBoard
        self.scene.addAnchor(pureAnchor)
        //so that we can drag, scale, rotate the checkboard to fit our view
        self.installGestures(.all, for: checkBoard!)
    }
    
    func touchPiece(touchEntity: Piece, player: Int){
        if !touchEntity.piece!.isTap{
            //play sound
            guard let path = Bundle.main.path(forResource: "music", ofType: "mp3")
            else{
                print("no path")
                return
            }
            print(path)
            let url = URL(fileURLWithPath: path)
            let audioFile = try? AudioFileResource.load(contentsOf: url, withName: "", inputMode: .spatial, loadingStrategy: .preload, shouldLoop: false)
            touchEntity.playAudio(audioFile!)
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
    
    func randomGetEntity() -> Piece?{
        let freePoint = self.checkBoard?.checkBoardComponent?.getRandomFreePoint()
        print(freePoint!)
        if freePoint![0] == -1{
            return nil
        }
        let pieceName = String(freePoint![0]) + String(freePoint![1])
        let piece = self.scene.findEntity(named: pieceName)
        return piece as? Piece
    }
    
    func AIplayChess(timer: Timer){
        if let piece = self.randomGetEntity(){
            print("AI plays")
            self.touchPiece(touchEntity: piece, player: 3 - self.player)
            changeTurn()
            self.textView!.text = self.whoTurn
        }
    }
    
    func touchEntity(piece: Piece){
        if piece.isOwner{
            print("piece owner is self")
            touchPiece(touchEntity: piece, player: self.player)
            changeTurn()
            self.textView!.text = self.whoTurn
            //self Play
            if self.isSelfPlay!{
                //play in 2s
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: self.AIplayChess)
            }
        }
        else{
            piece.requestOwnership(){result in
                if result == .granted{
                    print("piece authorized")
                    self.touchPiece(touchEntity: piece, player: self.player)
                    self.changeTurn()
                    self.textView!.text = self.whoTurn
                    //这里必然不是selfplay
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
        self.textView!.text = self.whoTurn
        if !self.isCompleteCoaching{
            print("not complete coaching")
            return
        }
        
        if mutex < 1{
            print("mutex")
            return
        }
        mutex -= 1//==0
        //may addCheckBoard
        if self.role == .host && !self.isAddCheckBboard{
            guard let result = self.raycast(from: (sender?.location(in: self))!, allowing: .existingPlaneGeometry, alignment: .horizontal).first else{
                mutex += 1
                return
            }
            self.addCheckBoard(transform: result.worldTransform)
            self.isAddCheckBboard = true
            mutex += 1
            self.textView!.text = self.whoTurn
            return
        }

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
            entity.scale = self.checkBoard!.scale/2
            entity.position = [-Float((self.checkBoard?.checkBoardComponent?.dimension[1])!)*0.2/2, 0.2, 0]
            entity.transform.rotation = simd_quatf(angle: -.pi/6, axis: [1, 0, 0])
            self.checkBoard?.addChild(entity)
            self.checkBoard?.checkBoardComponent?.isComplete = true
            if self.player == 1{
                self.isWin = true
            }
        case 2:
            entity = Winner(content: "red wins")
            entity.scale = self.checkBoard!.scale/2
            entity.position = [-Float((self.checkBoard?.checkBoardComponent?.dimension[1])!)*0.2/2, 0.2, 0]
            entity.transform.rotation = simd_quatf(angle: -.pi/6, axis: [1, 0, 0])
            self.checkBoard?.addChild(entity)
            self.checkBoard?.checkBoardComponent?.isComplete = true
            if self.player == 2{
                self.isWin = true
            }
        case 0:
            print("game not complete, continue")
        case -1:
            print("no one wins the game")
            self.checkBoard?.checkBoardComponent?.isComplete = true
        default:
//            print(result!)
            print("error")
        }
    }
}
