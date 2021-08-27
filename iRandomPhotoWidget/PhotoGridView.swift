//
//  PhotoGridView.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 24/8/2021.
//
import SwiftUI

struct PhotoGridView: View {
    @State private var selectedImageFlag : Bool = false
    @State private var selectedImage : UIImage = UIImage()
    @State private var images : [Photo] = []
    @State private var storageImageList : [UIImage] = []
    @State private var columns : Int = 2
    private var isPresented: Binding<Bool>
    
    init(storageImageList: [UIImage], isPresented: Binding<Bool>) {
        self.storageImageList = storageImageList
        self.isPresented = isPresented
        Theme.navigationBarColors(background: UIColor.init(named: "bg"), titleColor: .white)
    }
    
    var body: some View {
        NavigationView{
            
            ZStack {
                Color("bg")
                    .ignoresSafeArea()
                
                ZStack {
                    StaggeredGrid(columns: self.columns, list: images, content:  {
                        image in
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedImageFlag.toggle()
                                selectedImage = image.photo
                            }
                        }, label: {
                            ImageCardView(image: image)
                        })
                        
                    })
                    .padding(.horizontal)
                    .navigationTitle(localizedString(forKey: "allPhoto")).font(.largeTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                self.isPresented.wrappedValue.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                if (columns < 10) {
                                    columns += 1
                                }
                            } label: {
                                Image(systemName: "plus").font(.largeTitle)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                columns = max(columns - 1, 1)
                            } label: {
                                Image(systemName: "minus")
                            }
                        }
                    }
                    
                }.padding(.top)
            }

        }
        .accentColor(.init(UIColor.label))
        .onAppear() {
            for img in storageImageList {
                images.append(Photo(photo: img))
            }
        }.overlay(
            ZStack {
                if selectedImageFlag {
                    ImageViewer(image: selectedImage, isPresented: $selectedImageFlag)
                }
            }
        )
        
    }
}

struct ImageCardView: View {
    var image: Photo
    
    var body: some View {
        Image(uiImage: image.photo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
    }
}

struct Photo: Identifiable, Hashable {
    var id = UUID().uuidString
    var photo: UIImage
}

class Theme {
    static func navigationBarColors(background : UIColor?,
       titleColor : UIColor? = nil, tintColor : UIColor? = nil ){
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = background ?? .clear
        
        navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .black]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .black]
       
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance

        UINavigationBar.appearance().tintColor = tintColor ?? titleColor ?? .black
    }
}
