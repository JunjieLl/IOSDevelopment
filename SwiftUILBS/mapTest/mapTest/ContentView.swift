//
//  ContentView.swift
//  mapTest
//
//  Created by Junjie Li on 11/12/21.
//

import SwiftUI
import MapKit
import CoreLocation

//for reference
class GroundState{
    //是否处于后台
    var isBackground: Bool = false //false default
}

struct ContentView: View {
    @EnvironmentObject
    var location: Location
    //是否处于后台
    var groundState = GroundState()
    
    var body: some View {
        if location.permission == .authorizedWhenInUse || location.permission == .authorizedAlways{
            MapView(locations: $location.locations, groundState: groundState)
            //根据前、后台对精度进行切换
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)){_ in
                    location.changeDesiredAccuracy(distanceFilte: 4)
                    //print("background")
                    groundState.isBackground = true
                }
            //根据前、后台对精度进行切换
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)){_ in
                    location.changeDesiredAccuracy(distanceFilte: 2)
                    //print("forgeround")
                    groundState.isBackground = false
                }
        }
        else{
            VStack{
                Text("Please grant permission to always use location, otherwise location update cannot be performed when the app is in the background.")
                Button(action: {
                    location.requestPermission()
                }) {
                    Text("Authorize")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Location())
    }
}
