//
//  ContentView.swift
//  AR
//
//  Created by Junjie Li on 12/11/21.
//

import SwiftUI
import RealityKit
import ARKit

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
        
        let sessionConfig = ARWorldTrackingConfiguration()
        sessionConfig.planeDetection = .horizontal
        
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
