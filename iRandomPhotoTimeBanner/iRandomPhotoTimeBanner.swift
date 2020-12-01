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
        SimpleEntry(date: Date(),batteryNumber: "loading",batteryState: UIDevice.current.batteryState ,configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let midnight = Calendar.current.startOfDay(for: Date())
        let entries = SimpleEntry(date: midnight,batteryNumber: String(format:"%.f%%", UIDevice.current.batteryLevel * 100), batteryState: UIDevice.current.batteryState, configuration: configuration)
        completion(entries)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let midnight = Calendar.current.startOfDay(for: Date())
        let nextMidnight = Calendar.current.date(byAdding: .minute, value: 5, to: midnight)!
        let entries = [SimpleEntry(date: midnight,batteryNumber: String(format:"%.f%%", UIDevice.current.batteryLevel * 100),  batteryState: UIDevice.current.batteryState, configuration: configuration)]
        let timeline = Timeline(entries: entries, policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var batteryNumber : String
    var batteryState : UIDevice.BatteryState
    let configuration: ConfigurationIntent
}

struct widgetEntryView : View {
    var entry: Provider.Entry
    @State var imageArray = [UIImage(named: "infinity-war"), UIImage(named: "endgame"), UIImage(named: "sun")];
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

            VStack {
                Spacer()
                LinearGradient(gradient: gradient,
                               startPoint: .top,
                               endPoint: .bottom)
                    .frame(height: 80)
            }
            
           
            
            VStack(alignment: .leading) {
                Spacer()
                HStack(alignment: .bottom) {
                    Text(entry.date,style: .timer)
                        .padding(.all, family == .systemSmall ? 7 : (family == .systemMedium ? 10 : 15))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(entry.batteryNumber)
                        .padding(.all, family == .systemSmall ? 7 : (family == .systemMedium ? 10 : 15))
                        .font(.headline)
                        .foregroundColor(.white)
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
        .configurationDisplayName("My Widget")
        .supportedFamilies([.systemSmall, .systemLarge])
        .description("This is an example widget.")
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        widgetEntryView(entry: SimpleEntry(date: Date(),batteryNumber: "loading",batteryState: UIDevice.BatteryState.unknown, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
