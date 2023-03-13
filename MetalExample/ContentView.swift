//
//  ContentView.swift
//  MetalExample
//
//  Created by Joshua Homann on 3/4/23.
//

import Combine
import Metal
import SwiftUI


final class ViewModel: ObservableObject {
    @Published var selectedDevice: MTLDevice?
    private var subscriptions: Set<AnyCancellable> = []

    init() {
        #if os(macOS)
        let deviceSubject = PassthroughSubject<[MTLDevice], Never>()
        let (devices, observer) = MTLCopyAllDevicesWithObserver() { (device, notification) in
            deviceSubject.send(MTLCopyAllDevices())
        }
        selectedDevice = devices.first
        AnyCancellable { MTLRemoveDeviceObserver(observer) }.store(in: &subscriptions)
        deviceSubject.map(\.first).assign(to: &$selectedDevice)
        #else
        selectedDevice = MTLCreateSystemDefaultDevice()
        #endif
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    var body: some View {
        if let device = viewModel.selectedDevice {
            MetalView(device: device)
        } else {
            Text("No metal device")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
