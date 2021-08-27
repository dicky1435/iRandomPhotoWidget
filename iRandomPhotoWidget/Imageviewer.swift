//
//  ImageViewer.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 24/8/2021.
//

import SwiftUI

struct ImageViewer : View{

    var image : UIImage
    @Binding var isPresented : Bool
    @GestureState var draggingOffset: CGSize = .zero
    @State private var imageViewerOffset: CGSize = .zero
    @State private var bgOpacity: Double = 1
    @State private var imageScale: CGFloat = 1
    @State private var point: CGPoint = .zero
    
    var body: some View {
        
        let drag = DragGesture(minimumDistance: 0)
            .onChanged{ value in
                if imageScale < 3 {
                    point = value.location
                    print(point)
                }
                
            }
        
        let dragGesture = DragGesture().updating($draggingOffset, body: { (value, outValue, _) in
            if (imageScale == 1) {
                outValue = value.translation
                DispatchQueue.main.async {
                    imageViewerOffset = draggingOffset
                    
                    let halgHeight = UIScreen.main.bounds.height / 2
                    
                    let progress = imageViewerOffset.height / halgHeight
                    
                    withAnimation(.default) {
                        bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
                    }
                }
            }
        }).onEnded({ (value) in
            withAnimation(.easeInOut) {
                var translation = value.translation.height

                if translation < 0 {
                    translation = -translation
                }
                
                if (imageScale == 1) {
                    if translation < 250 {
                        imageViewerOffset = .zero
                        bgOpacity = 1
                    } else {
                        isPresented.toggle()
                        imageViewerOffset = .zero
                        bgOpacity = 1
                    }
                }
            }
        })
        
        let magGesture = MagnificationGesture().onChanged({ (value) in
            imageScale = value
            
        }).onEnded({(_) in
            withAnimation(.spring()) {
                imageScale = 1
            }
        })
        .simultaneously(with: TapGesture(count: 2).onEnded({
            withAnimation{
                if (imageScale > 1) {
                    imageScale = 1
                    imageViewerOffset = .zero
                    bgOpacity = 1
                } else {
                    imageScale = 3
                }
            }
        }))
        
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(bgOpacity)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(imageScale > 1 ? imageScale : 1, anchor: UnitPoint.init(x: point.x / UIScreen.main.bounds.size.width, y: point.y / UIScreen.main.bounds.size.height))
                .offset(x: imageScale > 1 ? imageViewerOffset.width : 0, y: imageViewerOffset.height)
                .gesture(
                    drag
                        .simultaneously(with: dragGesture)
                        .simultaneously(with: magGesture)
                )
            
        }.overlay(
            
            Button(action: {
                withAnimation(.default) {
                    isPresented.toggle()
                }
            }, label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.35))
                    .clipShape(Circle())
            })
            .padding(.top, UIScreen.main.nativeBounds.height < 1920 ? 20 : 50)
            .padding(.trailing, 10)
            .opacity(bgOpacity)
            ,alignment: .topTrailing
        )
        .gesture(DragGesture().updating($draggingOffset, body: { (value, outValue, _) in
            outValue = value.translation
            DispatchQueue.main.async {
                imageViewerOffset = draggingOffset
                
                if (imageScale == 1) {
                    let halgHeight = UIScreen.main.bounds.height / 2
                    
                    let progress = imageViewerOffset.height / halgHeight
                    
                    withAnimation(.default) {
                        bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
                    }
                }
            }
        }).onEnded({ (value) in
            withAnimation(.easeInOut) {
                var translation = value.translation.height
                
                if translation < 0 {
                    translation = -translation
                }
                
                if (imageScale == 1) {
                    if translation < 250 {
                        imageViewerOffset = .zero
                        bgOpacity = 1
                    } else {
                        isPresented.toggle()
                        imageViewerOffset = .zero
                        bgOpacity = 1
                    }
                }
            }
        }))
    }
    
}

