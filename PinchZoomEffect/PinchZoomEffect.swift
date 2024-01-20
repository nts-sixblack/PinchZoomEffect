//
//  PinchZoomEffect.swift
//  PinchZoomEffect
//
//  Created by Thanh Sau on 20/01/2024.
//

import Foundation
import SwiftUI

extension View {
    func addPincZoom() -> some View {
        return PinchZoomContext {
            self
        }
    }
}

struct PinchZoomContext<Content: View>: View {
    var content: Content
    
    @SceneStorage("isZooming") var isZooming = false
    
    @State var offset:CGPoint = .zero
    @State var scale: CGFloat = 0
    
    @State var scalePosition: CGPoint = .zero
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay {
                GeometryReader(content: { geometry in
                    let size = geometry.size
                    
                    ZoomGesture(size: size, offset: $offset, scale: $scale, scalePosition: $scalePosition)
                    
                })
            }
            .offset(x: offset.x, y: offset.y)
            .scaleEffect(1 + (scale < 0 ? 0 : scale), anchor: .init(x: scalePosition.x, y: scalePosition.y))
            .zIndex(scale != 0 ? 9999 : 0)
            .onChange(of: scale) { newValue in
                isZooming = (scale != 0 || offset != .zero)
                
                if scale == -1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                        scale = 0
                    })
                }
            }
    }
}

struct ZoomGesture: UIViewRepresentable {
    
    var size: CGSize
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    
    @Binding var scalePosition: CGPoint
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
//        pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(sender:)))
        view.addGestureRecognizer(pinchGesture)
        
//        pan gesture
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(sender:)))
        panGesture.delegate = context.coordinator
        view.addGestureRecognizer(panGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        var parent: ZoomGesture
        
        init(parent: ZoomGesture) {
            self.parent = parent
        }
        
//        making pan to recognize simultaneously...
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc
        func handlePan(sender: UIPanGestureRecognizer) {
            sender.maximumNumberOfTouches = 2
            
            if (sender.state == .began || sender.state == .changed) && parent.scale > 0 {
//            calculating translation
                if let view = sender.view {
                    let translation = sender.translation(in: view)
                    parent.offset = translation
                }
            } else {
//                setting scale to 0
                withAnimation(.easeOut(duration: 0.35)) {
                    parent.offset = .zero
                    parent.scale = -1
                }
            }
        }
        
        @objc
        func handlePinch(sender: UIPinchGestureRecognizer) {
            
//            calculating scale
            if sender.state == .began || sender.state == .changed {
                parent.scale = (sender.scale - 1)
                
//                getting the position where the user pinched and applying scale at that position...
                let scalePoint = CGPoint(x: sender.location(in: sender.view).x / sender.view!.frame.size.width, y: sender.location(in: sender.view).y / sender.view!.frame.size.height)
                parent.scalePosition = (parent.scalePosition == .zero ? scalePoint : parent.scalePosition)
            } else {
//                setting scale to 0
                withAnimation(.easeIn(duration: 0.35)) {
                    parent.scale = -1
                    parent.scalePosition = .zero
                }
            }
        }
    }
}

