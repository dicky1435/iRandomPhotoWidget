//
//  ContentView.swift
//  iRandomPhotoWidget
//
//  Created by Dicky on 1/12/2020.
//

import SwiftUI
import Combine
import PhotosUI
import WidgetKit
import ProgressHUD

class BatteryModel : ObservableObject {
    @Published var level = UIDevice.current.batteryLevel
    private var cancellableSet: Set<AnyCancellable> = []

    init () {
        UIDevice.current.isBatteryMonitoringEnabled = true
        assignLevelPublisher()
    }

    private func assignLevelPublisher() {
        UIDevice.current
            .publisher(for: \.batteryLevel)
            .assign(to: \.level, on: self)
            .store(in: &self.cancellableSet)
    }
}

struct ContentView: View {
  
    @ObservedObject var batteryModel = BatteryModel()
    @State var goToHome = false
    @State var animate = false
    @State var endSplash = false
    
    var body: some View {
            
        ZStack{
            
            ZStack {
                Rectangle()
                    .fill(Color.init(red: 34/255, green: 30/255, blue: 47/255))
                    .edgesIgnoringSafeArea(.all)
                //if goToHome{
                OnCircularView().onAppear(perform:{
                    ProgressHUD.animationType = .circleSpinFade
                    ProgressHUD.colorAnimation = UIColor(red: 34/255, green: 30/255, blue: 47/255, alpha: 1)
                })
                //                }else{
                //                    OnBoardScreen()
                //                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Success")), perform: { _ in
                withAnimation{self.goToHome = true}
            })
            
            ZStack{
                Color("bg")
                
                Image("snapchatLarge")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 85, height: 85)
                    .scaleEffect(animate ? 20 : 1)
                    .frame(width: UIScreen.main.bounds.width)
            }
            .ignoresSafeArea(.all,edges: .all)
            .onAppear(perform: animationSpalsh)
            .opacity(endSplash ? 0 : 1)
        }
    }
    
    func animationSpalsh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            withAnimation(Animation.easeOut(duration:1)){
                animate.toggle()
            }
            
            withAnimation(Animation.easeOut(duration:1)){
                endSplash.toggle()
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct OnCircularView: View  {
    @State var images : [UIImage] = [UIImage (named: "endgame")!]
    @State var picker = false
    @State var alertBox = false
    @State var setting = false
    @ObservedObject var batteryModel = BatteryModel()
    let key = "randomImage"
    
    func getImageKey(_ index:Int) -> String {
        return "\(key)\(index)"
    }
    
    func loadImages() -> [UIImage] {
        let list = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.array(forKey: key) as? [String] ?? [String]()
        var imageList = [UIImage]()
        for (index, _) in list.enumerated() {
            let imageName = getImageKey(index)
            if let shareUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dicky.iRandomPhotoWidget") {
               let imagePath = shareUrl.appendingPathComponent(imageName)
                if let image = UIImage(contentsOfFile: imagePath.path) {
                    imageList.append(image)
                }
            }
        }
        return imageList
    }
    
    var body: some View {
        
        ZStack(){
            
        }.fullScreenCover(isPresented: $setting, content: SettingTableView.init)
        
        VStack(spacing: 20){
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            
//            GeometryReader { proxy in
//                ScrollView(.horizontal, showsIndicators: false, content: {
//                    HStack() {
//                        ForEach(images.indices, id: \.self) { (index) in
//                            Image(uiImage: images[index])
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .overlay(Color.black.opacity(0.4))
//                                .frame(width: proxy.size.width, height: 300)
//                        }
//                    }
//                })
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .padding()
//                .frame(width: proxy.size.width, height: proxy.size.height / 3)
//            }.onAppear(perform: {
//                images = loadImages()
//            })
            
            GeometryReader { proxy in
                if (images.count != 0){
                    TabView{
                        ForEach(images.indices, id: \.self) { (index) in
                            Image(uiImage: images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .overlay(Color.black.opacity(0.4))
                                .frame(width: proxy.size.width, height: 300)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                    .frame(width: proxy.size.width, height: proxy.size.height / 3)
                }
            }.onAppear(perform: {
                images = loadImages()
            })
            
            Spacer()
            
            ZStack() {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .opacity(0.1)

                Circle()
                    .trim(from: 0, to: CGFloat(batteryModel.level))
                    .stroke(batteryModel.level > 0.5 ? Color.green : Color.orange, lineWidth: 3)
                    .rotationEffect(.degrees(-90))
                    .overlay(
                        VStack(spacing: 10) {
                            Text("\(Int(round(batteryModel.level * 100)))%")
                            Text("Total Images: \(images.count)")
                            Button(action: {
                                self.setting.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "gearshape.fill")
                                        .font(.title)
                                }
                                .frame(minWidth: 20, maxWidth: 20, minHeight: 20, maxHeight: 20)
                                .foregroundColor(.white)
                                .padding()
                            }
                        }
                                .foregroundColor(Color.white))
                
                Circle()
                    .fill(batteryModel.level > 0.5 ? Color.green : Color.orange)
                    .frame(width: 15 * 2, height: 15 * 2)
                    .padding(10)
                    .offset(y: -128)
                    .rotationEffect(Angle.degrees(Double(batteryModel.level * 360)))
                
            }.padding(20)
            .frame(height: 300)
            
            
            Button(action: {
                picker.toggle()
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title)
                    Text("Select Photo")
                        .fontWeight(.semibold)
                        .font(.title)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, maxHeight: 25)
                .padding()
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(40)
                .padding(.horizontal, 20)
            }
        }.sheet(isPresented: $picker) {
            ImagePicker(alertBox: $alertBox, images: $images, picker: $picker)
        }
//        .alert(isPresented: $alertBox) {
//            if (alertBox) {
//                ProgressHUD.showSucceed()
//                alertBox = false
//            }
            
//            Alert(title: Text("Photos saved!"), dismissButton: .default(Text("OK")) {
//                alertBox = false
//            })
//        }
    }
}

struct OnBoardScreen: View {
    
    @State var maxWidth = UIScreen.main.bounds.width - 100
    @State var offset : CGFloat = 0
    
    var body: some View{
        
        ZStack{
            
            Color(.black)
                .ignoresSafeArea(.all
                                 ,edges: .all)
            
            VStack {
                Image(uiImage: UIImage(named: "infinity-war")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(minHeight: 0, maxHeight: .infinity)
                    .ignoresSafeArea(.all
                                     ,edges: .all)
                
                // Slider
                
                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                    
                    Text("SWIPE TO START")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.leading,30)
                    

                    HStack{
                        Capsule()
                            .fill(Color(.red))
                            .frame(width: calculateWidth() + 65)

                        Spacer(minLength: 0)
                    }
                    
                    HStack{
                        ZStack{
                            Image(systemName: "chevron.right")
                            
                            Image(systemName: "chevron.right")
                                .offset(x:-10)
                            
                        }.foregroundColor(.white)
                        .offset(x:5)
                        .frame(width: 65, height: 65)
                        .background(Color(.red))
                        .clipShape(Circle())
                        .offset(x:offset)
                        .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
                        
                        Spacer()
                    }
                    
                    
                }
                .frame(width: maxWidth, height: 65)
                .padding(.bottom)
            }
            
        }
    }
    
    func calculateWidth() -> CGFloat {
        let percent = offset / maxWidth
        
        return percent * maxWidth
    }
    
    func onChanged(value: DragGesture.Value){
        if value.translation.width > 0 && offset <= maxWidth - 65 {
            offset = value.translation.width
        }
    }
    
    func onEnd(value: DragGesture.Value){
        
        withAnimation(Animation.easeOut(duration:0.3)) {
            if offset > 180 {
                offset = maxWidth - 65
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("Success"), object: nil
                    )
                }
            } else {
                offset = 0
            }
        }
    }
}

struct ImagePicker : UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent1: self)
    }
    
    @Binding var alertBox : Bool
    @Binding var images : [UIImage]
    @Binding var picker : Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 100
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }
    
    class Coordinator: NSObject,PHPickerViewControllerDelegate {
        
        let key = "randomImage"
        var isPresented = 0
        
        var parent : ImagePicker
        var tempImages : [UIImage]
        
        init(parent1: ImagePicker) {
            parent = parent1
            tempImages = []
        }
        
        func getImageKey(_ index:Int) -> String {
            return "\(key)\(index)"
        }

        func saveImages(_ images:[UIImage]) -> Bool{
            var saveAction = false
            var list = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.array(forKey: key) as? [String] ?? [String]()
            list.removeAll()
            var index = list.count
            
            for image in images {
                
                let imgKey = getImageKey(index)
                saveImage(imgKey, image)
                list.append(imgKey)
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set(list, forKey: key)
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.synchronize()
                index += 1
                if (index == images.count) {
                    saveAction = true;
                }
            }
            print("count: \(index)")
            
            return saveAction
        }
        
        
        func saveImage(_ imageName:String, _ image:UIImage) {
            if let shareUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dicky.iRandomPhotoWidget") {
               let imagePath = shareUrl.appendingPathComponent(imageName)
                try? image.pngData()?.write(to: imagePath)
            }
        }
        
        func removeImages() {
            let list = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.array(forKey: key) as? [String] ?? [String]()
            UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.synchronize()
            for (index, _) in list.enumerated() {
                let imageName = getImageKey(index)
                if let shareUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dicky.iRandomPhotoWidget") {
                   let imagePath = shareUrl.appendingPathComponent(imageName)
                    if let image = UIImage(contentsOfFile: imagePath.path) {
                        do {
                              if FileManager.default.fileExists(atPath: imagePath.path) {
                                  try FileManager.default.removeItem(atPath: imagePath.path)
                               }
                           } catch let error as NSError {
                               print(error.debugDescription)
                           }
                    }
                }
            }
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            picker.dismiss(animated: true, completion: nil)
            
            if(self.isPresented >= 1) {
                return
            }
            
            if (self.isPresented < 1) {
                isPresented+=1
                
                if (results.count > 0) {
                    ProgressHUD.show()
                    self.parent.images.removeAll()
                    removeImages()
                    
                    for img in results {
                        if img.itemProvider.canLoadObject(ofClass: UIImage.self) {
                            img.itemProvider.loadObject(ofClass: UIImage.self) { (image,err) in
                                DispatchQueue.main.async {
                                    guard image != nil else {
                                        return
                                    }
                                    self.parent.images.append(image as! UIImage)
                                    if (self.parent.images.count == results.count) {
                                        print("results:\(self.parent.images.count)")
                                        if self.saveImages(self.parent.images) {
                                            ProgressHUD.showSucceed("Photos Saved!")
                                            self.parent.alertBox = true
                                            WidgetCenter.shared.reloadAllTimelines()
                                        }
                                        
                                    }
                                }
                            }
                        } else {
                            
                        }
                    }
                }
                
     
            }
        }
    }
}
