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
    
    @State//false by default
    private var isSelfPlay = false
    
    var body: some View {
        if isStartGame{
            ARViewContainer(role: $role, isSelfPlay: $isSelfPlay, quitClosure: {
                self.isStartGame = false
            })
                .edgesIgnoringSafeArea(.all)
        }
        else{
            ZStack{
                Image("backg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
                    
                VStack(alignment: .center, spacing: 20){
                    HStack{
                        Image(systemName: "checkerboard.rectangle")
                        Text("Welcome to Gobang")
                    }
                    .font(Font.largeTitle)
                    
                    Button(action: {
                        isStartGame = true
                        role = .host
                        isSelfPlay = true
                    }){
                        Image(systemName: "checkerboard.shield")
                        Text("Play With AI")
                    }
                    .font(.title)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(Color.white)
                    .cornerRadius(50)
                    .padding(10)
                    
                    Button(action: {
                        isStartGame = true
                        role = .host
                        isSelfPlay = false
                    }){
                        Image(systemName: "checkerboard.shield")
                        Text("Host Game")
                    }
                    .font(.title)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(Color.white)
                    .cornerRadius(50)
                    .padding(10)
                    
                    Button(action: {
                        isStartGame = true
                        role = .client
                        isSelfPlay = false
                    }){
                        Image(systemName: "checkerboard.shield")
                        Text("Join Game")
                    }
                    .font(.title)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(Color.white)
                    .cornerRadius(50)
                    .padding(10)
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding
    var role: Role
    
    @Binding
    var isSelfPlay: Bool
    
    func makeCoordinator() -> () {
        Coordinator()
    }
    
    var quitClosure: (()->Void)
    
    func makeUIView(context: Context) -> CheckBoardARView {
        let arView = CheckBoardARView(role: role, isSelfPlay: isSelfPlay, quitClosure: quitClosure)
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
