//
//  ContentView.swift
//  AR
//
//  Created by Junjie Li on 12/11/21.
//

import SwiftUI
import RealityKit
import ARKit
import MultipeerConnectivity

struct ContentView : View {
    @State
    private var isStartGame = false
    
    @State
    private var role: Role = .client
    
    var body: some View {
        if isStartGame{
            ARViewContainer(role: $role)
            .edgesIgnoringSafeArea(.all)
        }
        else{
            VStack(alignment: .center, spacing: 10){
                Text("Welcome to Gobang")
                
                Button(action: {
                    isStartGame = true
                    role = .host
                }){
                    Text("Host Game")
                }
                
                Button(action: {
                    isStartGame = true
                    role = .client
                }){
                    Text("Join Game")
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding
    var role: Role
    
    func makeCoordinator() -> () {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> CheckBoardARView {
        let arView = CheckBoardARView(role: role)
        //session configuration
        let sessionConfig = ARWorldTrackingConfiguration()
        sessionConfig.planeDetection = .horizontal
        // multi peer
        sessionConfig.isCollaborationEnabled = true
        //session run
        arView.session.run(sessionConfig, options: [])
        
        arView.addARCoaching()
        
        return arView
    }
    
    func updateUIView(_ uiView: CheckBoardARView, context: Context) {}
    
    class Cordinator{
        
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
