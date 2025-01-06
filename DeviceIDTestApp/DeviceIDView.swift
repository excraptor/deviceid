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
                .lineLimit(nil)
        }
        .padding()
        .onAppear() {
            getDeviceId() { deviceId, error in
                Task { @MainActor in
                    if let error {
                        print("An error has occurred while creating deviceId: \(error)")
                        return
                    }
                    deviceID = deviceId
                }
            }
        }
    }
}
