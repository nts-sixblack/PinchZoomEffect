//
//  ContentView.swift
//  PinchZoomEffect
//
//  Created by Thanh Sau on 20/01/2024.
//

import SwiftUI

struct ContentView: View {
    
    @SceneStorage("isZooming") var isZooming = false
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(1...4, id: \.self) { index in
                    Image("Pic\(index)")
                        .resizable()
                        .scaledToFill()
                        .frame(width: getRect().width - 30)
                        .cornerRadius(15)
                        .addPincZoom()
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "camera.fill")
                })
                
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    Image(systemName: "camera.fill")
                })
            }
            .overlay {
                Text("Header" )
                    .font(.title3.bold())
            }
            .padding()
            .foregroundColor (.primary)
            .background(.ultraThinMaterial)
            .offset(y: isZooming ? -200 : 0)
            .animation(.easeInOut, value: isZooming)
        }
    }
}

#Preview {
    ContentView()
}

extension View {
    func getRect() -> CGRect{
        return UIScreen.main.bounds
    }
}
