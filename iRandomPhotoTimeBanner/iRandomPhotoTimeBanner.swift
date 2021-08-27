//
//  iRandomPhotoTimeBanner.swift
//  iRandomPhotoTimeBanner
//
//  Created by Dicky on 1/12/2020.
//
import Combine
import WidgetKit
import SwiftUI
import Intents
//
//class BatteryModel : ObservableObject {
//    @Published var level = UIDevice.current.batteryLevel
//    private var cancellableSet: Set<AnyCancellable> = []
//
//    init () {
//        UIDevice.current.isBatteryMonitoringEnabled = true
//        assignLevelPublisher()
//    }
//
//    private func assignLevelPublisher() {
//        _ = UIDevice.current
//            .publisher(for: \.batteryLevel)
//            .assign(to: \.level, on: self)
//            .store(in: &self.cancellableSet)
//    }
//}

struct Provider: IntentTimelineProvider {
    //@ObservedObject var batteryModel = BatteryModel()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),batteryNumber: "loading",batteryState: UIDevice.current.batteryState ,configuration: ConfigurationIntent(), selectColor: UIColor.white)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let midnight = Calendar.current.startOfDay(for: Date())
        let entries = SimpleEntry(date: midnight,batteryNumber: String(format:"%.f%%", UIDevice.current.batteryLevel * 100), batteryState: UIDevice.current.batteryState, configuration: configuration, selectColor: UIColor.white)
        completion(entries)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
      
        UIDevice.current.isBatteryMonitoringEnabled = true
        var photoShadow = true
        var photoTimeNBattery = true
        var photoTimeNBatteryPosition = false
        var selectColor = UIColor.white
        
        var randomTime = 5
        
        switch configuration.RandomTime {
        case .one:
            randomTime = 1
            break
        case .five:
            randomTime = 5
            break
        case .ten:
            randomTime = 10
            break
        case .third:
            randomTime = 30
            break
        case .unknown:
            break
        }
        
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoShadow") == nil) {
            photoShadow = true
        } else {
            // userDefault has a value
            if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoShadow") == "YES") {
                photoShadow = true
            } else {
                photoShadow = false
            }
        }
        
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoTimeNBattery") == nil) {
            photoTimeNBattery = true
        } else {
            // userDefault has a value
            if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoTimeNBattery") == "YES") {
                photoTimeNBattery = true
            } else {
                photoTimeNBattery = false
            }
        }
        
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoTimeNBatteryPosition") == nil) {
            photoTimeNBatteryPosition = false
        } else {
            // userDefault has a value
            if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.string(forKey: "settingPhotoTimeNBatteryPosition") == "YES") {
                photoTimeNBatteryPosition = true
            } else {
                photoTimeNBatteryPosition = false
            }
        }
        
        if (UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.color(forKey: "textColor") == nil) {
            selectColor = UIColor.white
        } else {
            selectColor = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.color(forKey: "textColor") ?? UIColor.white
        }
        
        let midnight = Calendar.current.startOfDay(for: Date())
        let nextMidnight = Calendar.current.date(byAdding: .minute, value: randomTime, to: midnight)!
        let entries = [SimpleEntry(date: midnight,batteryNumber: String(format:"%.f%%", UIDevice.current.batteryLevel * 100),  batteryState: UIDevice.current.batteryState, configuration: configuration, shadow: photoShadow, timeNBattery: photoTimeNBattery,timeNBatteryPosition: photoTimeNBatteryPosition, selectColor: selectColor)]
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var batteryNumber : String
    var batteryState : UIDevice.BatteryState
    let configuration: ConfigurationIntent
    var shadow : Bool = true
    var timeNBattery : Bool = true
    var timeNBatteryPosition : Bool = false
    var selectColor: UIColor
}

struct widgetEntryView : View {
    var entry: Provider.Entry
    @State var imageArray = [UIImage(named: "snapchatLarge")];
    @Environment(\.widgetFamily) var family
    let key = "randomImage"
    
    var gradient: Gradient {
        Gradient(stops:
                    [Gradient.Stop(color: .clear, location: 0),
                     Gradient.Stop(color: Color.black.opacity(0.95),
                                   location: 0.6)])
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm:ss a"
        return formatter
    }()
    
    func getImageKey(_ index:Int) -> String {
        return "\(key)\(index)"
    }
    
    func loadImages() -> [UIImage] {
        let list = UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.array(forKey: key) as? [String] ?? [String]()
        UserDefaults(suiteName: "group.dicky.iRandomPhotoWidget")!.synchronize()
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
        ZStack {
            Image(uiImage: imageArray.randomElement()!!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .mask(
                    RoundedRectangle(cornerRadius: 10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(minHeight: 0, maxHeight: .infinity)
                )
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(minHeight: 0, maxHeight: .infinity)

            if (entry.shadow) {
                VStack {
                    if (!entry.timeNBatteryPosition) {
                        Spacer()
                        LinearGradient(gradient: gradient,
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .frame(height: 80)
                    }
                    if (entry.timeNBatteryPosition) {
                        LinearGradient(gradient: gradient,
                                       startPoint: .bottom,
                                       endPoint: .top)
                            .frame(height: 80)
                        Spacer()
                    }
                }
            }
            
            if (entry.timeNBattery) {
                VStack(alignment: .leading) {
                    if (!entry.timeNBatteryPosition) {
                        Spacer()
                    }
                    HStack(alignment: .bottom) {
                        Text(entry.date,style: .timer)
                            .padding(.all, family == .systemSmall ? 9 : (family == .systemMedium ? 10 : 15))
                            .font(.system(size: UIScreen.main.nativeBounds.height < 1920 ? 14 : 15.5, weight: .bold, design: .rounded))
                            .foregroundColor(Color(entry.selectColor))
                            .lineLimit(1)
                        
                        Text(entry.batteryNumber)
                            .padding(.all, family == .systemSmall ? 9 : (family == .systemMedium ? 10 : 15))
                            .font(.system(size: UIScreen.main.nativeBounds.height < 1920 ? 14 : 15.5, weight: .bold, design: .rounded))
                            .foregroundColor(Color(entry.selectColor))
                    }
                    if (entry.timeNBatteryPosition) {
                        Spacer()
                    }
                }
            }
            
        }
        .onAppear(perform: {
            if (loadImages().count != 0) {
                self.imageArray = loadImages()
            }
        })
        .background(Color.black)
    }
    
}

struct PlaceHolder : View {
    var entry: Provider.Entry
    
    var body: some View {
        
        VStack {
            HStack{
                Spacer()
                Text("Time")
                Spacer()
            }
            
            Spacer()
            
            Text("Loading")
                .padding(.horizontal, 15)
            
            Spacer()
        }
        .background(Color.black)
    }

}

@main
struct widget: Widget {
    let kind: String = "widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
            
        }
        .configurationDisplayName("iRandomPhotoWidget")
        .supportedFamilies([.systemSmall, .systemLarge])
        .description("Photo Slideshow Home Screen Widgets")
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(),batteryNumber: "loading",batteryState: UIDevice.BatteryState.unknown, configuration: ConfigurationIntent(), selectColor: UIColor.white))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension UserDefaults {

    func color(forKey key: String) -> UIColor? {

        guard let colorData = data(forKey: key) else { return nil }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }

    }

    func set(_ value: UIColor?, forKey key: String) {

        guard let color = value else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            set(data, forKey: key)
        } catch let error {
            print("error color key data not saved \(error.localizedDescription)")
        }

    }

}
