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
    var body: some View {
        return ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeCoordinator() -> () {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> CheckBoardARView {
        let arView = CheckBoardARView(frame: .zero)
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
