//
//  MetalView.swift
//  MetalExample
//
//  Created by Joshua Homann on 3/4/23.
//

import MetalKit
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
typealias PlatformView = NSView
typealias PlatformViewRepresentable = NSViewRepresentable
#else
typealias PlatformView = UIView
typealias PlatformViewRepresentable = UIViewRepresentable
#endif

struct MetalView: PlatformViewRepresentable {
    var device: MTLDevice

    func makeCoordinator() -> Coordinator {
        .init(device: device)
    }
#if os(macOS)
    func makeNSView(context: Context) -> PlatformView {
        context.coordinator.view
    }
    func updateNSView(_ nsView: PlatformView, context: Context) {
        context.coordinator.set(device: device)
    }
#else
    func makeUIView(context: Context) -> some PlatformView {
        context.coordinator.view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.set(device: device)
    }
#endif
}

extension MetalView {
    final class Coordinator: NSObject, MTKViewDelegate {
        let view = MTKView()
        private var device: MTLDevice
        private var commandQueue: MTLCommandQueue?
        private var library: MTLLibrary?
        private var pipelineState: MTLRenderPipelineState?
        private var vertexBuffer: MTLBuffer?
        init(device: MTLDevice) {
            self.device = device
            super.init()
            view.delegate = self
            view.device = device
            setup()
        }
        func set(device: MTLDevice) {
            guard device !== view.device else { return }
            view.device = device
            self.device = device
            setup()
        }

        private func setup() {
            view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            commandQueue = device.makeCommandQueue()
            library = device.makeDefaultLibrary()
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
            pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            let vertices = [
                Vertex(position: [-1, -1], color: [1, 0, 0, 1]),
                Vertex(position: [1, -1], color: [0, 1, 0, 1]),
                Vertex(position: [-1, 1], color: [0, 0, 1, 1]),
                Vertex(position: [1, 1], color: [0, 1, 1, 1])
            ]
            vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

        }

        func draw(in view: MTKView) {
            guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
            guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
            guard let pipelineState else { return }
            guard let vertexBuffer else { return }
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderEncoder.endEncoding()
            guard let drawable = view.currentDrawable else { return }
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
