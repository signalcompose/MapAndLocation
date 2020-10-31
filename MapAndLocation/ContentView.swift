//
//  ContentView.swift
//  MapAndLocation
//
//  Created by hiroshi yamato on 2020/10/31.
//

import SwiftUI
import MapKit
//import CoreLocation

struct ContentView: View {
    var body: some View {
        MapView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MapView: View {
    
    // 地図に表示する緯度経度と縮尺を設定
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.510992, longitude: 139.56699), latitudinalMeters: 10000, longitudinalMeters: 10000)
    //　https://developer.apple.com/documentation/mapkit/mapusertrackingmode
    // Setting the User Tracking Mode
    // case follow - The map updates by following a user’s location.
    @State var tracking : MapUserTrackingMode = .follow
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    
    var body: some View{
        VStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: managerDelegate.pins) { pin in
                
                MapPin(coordinate: pin.location.coordinate, tint: .red)
            }
        }
        .onAppear() {
            manager.delegate = managerDelegate
        }
    }
}

// CoreLocationのdelegate
class locationDelegate : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var pins : [Pin] = []
    // Corelocationのユーザー確認
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .authorizedWhenInUse {
            print("authorized..")
            
            // reduce accuracy (おおまかな精度での位置情報）が使えるようになった。
            // https://qiita.com/satoru_pripara/items/7dbaf59dc840d679751c
            if manager.accuracyAuthorization != .fullAccuracy {
                print("reduced Accuracy")
                
                // https://developer.apple.com/documentation/corelocation/cllocationmanager/3600216-requesttemporaryfullaccuracyauth
                // Requests the user’s permission to temporarily use location services with full accuracy.
                // info.plist に　Privacy - Location Temporary Usage Description Dictionary　を追加して　Locationをkeyに追加。
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Location") {
                    (err) in
                    if err != nil {
                        print(err!)
                        return
                    }
                }
            }
            
            // 位置情報のアップデートの開始
            manager.startUpdatingLocation()
            
        } else {
            print("not authorized..")
            // info.plist に Privacy - Location When In Use Usage Description を追加する
            manager.requestWhenInUseAuthorization()
            
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        pins.append(Pin(location: locations.last!))
    }
}

// Map上のPinのアップデート
struct Pin : Identifiable {
    var id = UUID().uuidString
    var location : CLLocation
}
