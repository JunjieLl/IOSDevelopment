//
//  MapView.swift.swift
//  mapTest
//
//  Created by Junjie Li on 11/12/21.
//


import SwiftUI
import MapKit

//struct MapView: View {
//    @State
//    var region: MKCoordinateRegion
//
//    var body: some View {
//        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
//           .edgesIgnoringSafeArea(.all)
//    }
//}

struct MapView: UIViewRepresentable{
    @Binding
    //存储待渲染的overlay的坐标
    var locations: [CLLocationCoordinate2D]
    
    //是否处于后台
    var groundState = GroundState()
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        
        //delegate
        mapView.delegate = context.coordinator
        
        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        //zoom
        mapView.setRegion(MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
        
        return mapView
    }
    
    //draw line with specific frequence according to background state
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print(groundState.isBackground)
        //前后台进行渲染频率不一样
        if (!groundState.isBackground && locations.count >= 4)
            || (groundState.isBackground && locations.count >= 10){
            
            let line = MKPolyline(coordinates: locations, count: locations.count)
            uiView.addOverlay(line)
            //clear
            
            locations.removeSubrange(0...locations.count-2)
            print("draw a line")
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate{
        //render for overlay
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = .green
            render.lineWidth = 3
            
            return render
        }
        //        这里也可以直接利用mapview的位置更新来画线，但还是尝试了corelocation的坐标系转换问题 WGS -> GCL
        //        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //
        //        }
    }
}
