//
//  DeviceIDView.swift
//  DeviceID
//
//  Created by Tamás Balla on 2025. 01. 03..
//


import SwiftUI
import DeviceID

struct DeviceIDView: View {
    @State var deviceID: String?
    
    var body: some View {
        VStack {
            Text("Your unique device id is:")
            Text(deviceID ?? "unknown")
            
        }
        .onAppear() {
            getDeviceId() { deviceId in
                Task { @MainActor in
                    deviceID = deviceId
                }
            }
        }
    }
}
