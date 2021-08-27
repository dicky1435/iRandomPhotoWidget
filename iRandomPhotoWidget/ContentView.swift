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
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var batteryModel = BatteryModel()
    @State var goToHome = false
    @State var animateAction = true
    @State private var animate = false
    @State private var endSplash = false
    @State private var imageList : [UIImage] = []
    let key = "randomImage"
    
    var body: some View {
        
        ZStack{
            
            ZStack {
                Rectangle()
                    .fill(Color.init(red: 34/255, green: 30/255, blue: 47/255))
                    .edgesIgnoringSafeArea(.all)
                if goToHome{
                    OnCircularView().onAppear(perform:{
                        ProgressHUD.animationType = .circleSpinFade
                        if colorScheme == .dark {
                            ProgressHUD.colorAnimation = UIColor(.white)
                        } else {
                            ProgressHUD.colorAnimation = UIColor(red: 34/255, green: 30/255, blue: 47/255, alpha: 1)
                        }
                    })
                } else {
                    if (imageList.count > 0) {
                        OnBoardScreen(images: imageList)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Success")), perform: { _ in
                withAnimation{
                    self.goToHome = true
                }
            })
            
            ZStack{
                Color("bg")
                
                Image("snapchatLarge")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .scaleEffect(animate ? 20 : 1)
                    .frame(width: UIScreen.main.bounds.width)
            }
            .ignoresSafeArea(.all,edges: .all)
            .onAppear(perform: {
                UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set(10, forKey: "photoLimitation")
                
                if (animateAction) {
                    animationSpalsh()
                } else {
                    endSplash = true
                }
                imageList = loadImages()
                if (imageList.count == 0) {
                    self.goToHome = true
                }
                
            })
            .opacity(endSplash ? 0 : 1)
        }
    }
    
    func animationSpalsh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            withAnimation(Animation.easeOut(duration:1.5)){
                animate.toggle()
            }
            
            withAnimation(Animation.easeOut(duration:1.5)){
                endSplash.toggle()
            }
        }
    }
    
    func loadImages() -> [UIImage] {
        //        let list = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.array(forKey: key) as? [String] ?? [String]()
        //        let imageName = list.randomElement()
        //        var imageList = [UIImage]()
        //        if let shareUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dicky.iRandomPhotoWidget") {
        //            let imagePath = shareUrl.appendingPathComponent(imageName ?? "")
        //            if let image = UIImage(contentsOfFile: imagePath.path) {
        //                imageList.append(image)
        //            }
        //        }
        //        return imageList
        let list = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.array(forKey: key) as? [String] ?? [String]()
        var imageList = [UIImage]()
        for (index, _) in list.enumerated() {
            let imageName = "\(key)\(index)"
            if let shareUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dicky.iRandomPhotoWidget") {
                let imagePath = shareUrl.appendingPathComponent(imageName)
                if let image = UIImage(contentsOfFile: imagePath.path) {
                    imageList.append(image)
                }
            }
        }
        return imageList
    }
}


struct OnCircularView: View  {
    @State var images : [UIImage] = []
    @State var picker = false
    @State var alertBox = false
    @State var setting = false
    @State var gridPage = false
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
        }.fullScreenCover(isPresented: $setting, content: {
            SettingTableView().ignoresSafeArea()
        })
        
        ZStack(){
        }.fullScreenCover(isPresented: $gridPage, content: {
            PhotoGridView(storageImageList: images, isPresented: $gridPage).ignoresSafeArea()
        })
        
        VStack(spacing: 20){
            
            if (images.count != 0){
                TabView{
                    ForEach(images.indices, id: \.self) { (index) in
                        Image(uiImage: images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(Color.black.opacity(0.4))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 400)
                            .cornerRadius(12)
                            .clipped()
                            .contentShape(Rectangle())
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 400)
            }
            
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
                            Text(localizedString(forKey: "totalPhotos")+": \(images.count)")
                            HStack(alignment: .center, spacing: 25) {
                                
                                Button(action: {
                                    self.gridPage.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.title)
                                    }
                                    .frame(minWidth: 20, maxWidth: 20, minHeight: 20, maxHeight: 20)
                                    .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    self.setting.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: "gearshape.fill")
                                            .font(.title)
                                    }
                                    .frame(minWidth: 20, maxWidth: 20, minHeight: 20, maxHeight: 20)
                                    .foregroundColor(.white)
                                }
                                
                            }.padding()
                            
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
                    Text(localizedString(forKey: "selectPhoto"))
                        .fontWeight(.semibold)
                        .font(.title)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 60)
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(100)
                .padding(.horizontal, 20)
                .padding(.bottom)
            }
        }.sheet(isPresented: $picker) {
            ImagePicker(alertBox: $alertBox, images: $images, picker: $picker)
        }.onAppear(perform: {
            images = loadImages()
        })
    }
}

struct OnBoardScreen: View {
    @State var currentIndex: Int = 1
    
    @State var titleText: [TextAnimation] = []
    
    @State var subTitleAnimation: Bool = false
    @State var endAnimation = false
    
    @State var titles = [
        "This is test Message 1",
        "This is test Message 2",
        "This is test Message 3"
    ]
    
    @State var subTitles = [
        "aaa",
        "bbb",
        "ccc"
    ]
    
    @State var images : [UIImage] = []
    @State private var maxWidth = UIScreen.main.bounds.width - 100
    @State private var offset : CGFloat = 0
    @State private var nextIndex : Int = 0
    
    var body: some View{
        
        ZStack{
            
            Color(.black)
                .ignoresSafeArea(.all
                                 ,edges: .all)
            
            GeometryReader{proxy in
                let size = proxy.size
                
                Color.black
                
                ForEach(images.indices, id: \.self) { (index) in
                    
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .opacity(nextIndex == index ? 1 : 0)
                        .tag(index)
                }
                
                LinearGradient(gradient: Gradient(colors: [
                    .clear,
                    .clear,
                    .black.opacity(0.1),
                    .black
                ]), startPoint: .top, endPoint: .bottom)
                
                
            }.ignoresSafeArea()
            
            
            VStack(spacing: 20) {
                
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(titleText) {
                        text in
                        Text(text.text)
                            .offset(y: text.offset)
                    }
                    .font(.title.bold())
                    .foregroundColor(.white)
                    
                }
                .offset(y: endAnimation ? -100 : 0)
                .opacity(endAnimation ? 0 : 1)
                
                
                Text(subTitles[currentIndex])
                    .opacity(0.7)
                    .foregroundColor(.white)
                    .offset(y: !subTitleAnimation ? 80 : 0)
                    .offset(y: endAnimation ? -100 : 0)
                    .opacity(endAnimation ? 0 : 1)
                
                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(1))
                    
                    Text(localizedString(forKey: "enterToStart"))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    //                        .padding(.leading, 30)
                    
                    
                    //                    HStack{
                    //                        Capsule()
                    //                            .fill(Color.init(red: 34/255, green: 30/255, blue: 47/255))
                    //                            .frame(width: calculateWidth() + 65)
                    //
                    //                        Spacer(minLength: 0)
                    //                    }
                    
                    //                    HStack{
                    //                        ZStack{
                    //                            Image(systemName: "chevron.right")
                    //
                    //                            Image(systemName: "chevron.right")
                    //                                .offset(x:-10)
                    //
                    //                        }.foregroundColor(.white)
                    //                        .offset(x:5)
                    //                        .frame(width: 65, height: 65)
                    //                        .background(Color.init(red: 34/255, green: 30/255, blue: 47/255))
                    //                        .clipShape(Circle())
                    //                        .offset(x:offset)
                    //                        .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
                    //
                    //                        Spacer()
                    //                    }
                    
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 65, alignment: .bottom)
                .padding(.top)
                .onTapGesture {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("Success"), object: nil
                    )
                }
            }.padding()            
        }
        .onAppear(){
            currentIndex = 0
            nextIndex = Int.random(in: 0..<images.count)
            //            WeatherApi().loadData { (weathers) in
            //                self.weathers = weathers
            //            }
        }
        .onChange(of: currentIndex) {
            newValue in
            
            getSpilitedText(text: titles[currentIndex]) {
                
                withAnimation(.easeInOut(duration: 1)) {
                    endAnimation.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    titleText.removeAll()
                    subTitleAnimation.toggle()
                    endAnimation.toggle()
                    
                    withAnimation(.easeIn(duration: 0.6)) {
                        if currentIndex < (titles.count - 1) {
                            currentIndex += 1
                        } else {
                            currentIndex = 0
                        }
                        nextIndex = Int.random(in: 0..<images.count)
                    }
                }
            }
        }
    }
    
    func getSpilitedText(text: String, completion: @escaping()->()) {
        for (index, character) in text.enumerated() {
            titleText.append(TextAnimation(text: String(character)))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    titleText[index].offset = 0
                }
                
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.02) {
            
            withAnimation(.easeInOut(duration: 0.5)) {
                subTitleAnimation.toggle()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                completion()
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
        config.selectionLimit = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.integer(forKey: "photoLimitation")
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "purchaseUnlock") != nil) {
            // userDefault has a value
            if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "purchaseUnlock") == GlobalConstants.unlockCode) {
                config.selectionLimit = 250
            }
        }
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
                index += 1
                if (image == images.last) {
                    UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.set(list, forKey: key)
                    UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.synchronize()
                    saveAction = true;
                }
            }
            print("count: \(index)")
            
            return saveAction
        }
        
        func saveImage(_ imageName:String, _ image:UIImage) {
            if let shareUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dicky.iRandomPhotoWidget") {
                let imagePath = shareUrl.appendingPathComponent(imageName)
                _ = autoreleasepool
                {
                    try? image.jpegData(compressionQuality: 0.9)?.write(to: imagePath)
                }
            }
        }
        
        func removeImages() {
            let list = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.array(forKey: key) as? [String] ?? [String]()
            UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.synchronize()
            for (index, _) in list.enumerated() {
                let imageName = getImageKey(index)
                if let shareUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dicky.iRandomPhotoWidget") {
                    let imagePath = shareUrl.appendingPathComponent(imageName)
                    if UIImage(contentsOfFile: imagePath.path) != nil {
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
                                guard image != nil else {
                                    return
                                }
                                self.parent.images.append(image as! UIImage)
                                
                                if (img == results.last) {
                                    print("results:\(self.parent.images.count)")
                                    if self.saveImages(self.parent.images) {
                                        DispatchQueue.main.async {
                                            ProgressHUD.showSucceed(localizedString(forKey: "photoSaved"))
                                            self.parent.alertBox = true
                                            WidgetCenter.shared.reloadAllTimelines()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
