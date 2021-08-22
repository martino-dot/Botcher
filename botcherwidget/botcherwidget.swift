//
//  botcherwidget.swift
//  botcherwidget
//
//  Created by Martin Velev on 8/24/20.
//

import WidgetKit
import SwiftUI
import Intents
import Foundation
import CoreData

struct Provider: IntentTimelineProvider {
    var category : NSManagedObjectContext
    
    init(context : NSManagedObjectContext) {
            self.category = context
    }
    let snackArray = ["Eat Chips", "Eat French Fries", "Eat A Fruit", "Eat A Potato", "Eat Some Jerky",
                 "Eat A Cracker", "Eat Some Popcorn", "Eat A Cookie", "Eat A Pretzel", "Eat Some Yogurt",
                 "Eat Some Hummus", "Eat A Muffin", "Eat Some Cheese", "Eat Edamame", "Eat A Fruit Snack",
                 "Eat A Marshmallow", "Eat A Croissant", "Eat Some Nachos", "Eat Fish And Chips"
    ]

    func placeholder(in context: Context) -> SimpleEntry {
        let categories = Category.fetchAll()
        let randomArray = categories.randomElement()
        guard let userArray = randomArray?.results else { return SimpleEntry(date: Date(), result: snackArray.randomElement()!) }
        return SimpleEntry(date: Date(), result: userArray.randomElement()!)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let categories = Category.fetchAll()
        let randomArray = categories.randomElement()
        guard let userArray = randomArray?.results else { return completion(SimpleEntry(date: Date(), result: snackArray.randomElement()!)) }
        let entry = SimpleEntry(date: Date(), result: userArray.randomElement()!)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let categories = Category.fetchAll()
        let randomArray = categories.randomElement()
        let date = Date()
        guard let userArray = randomArray?.results else { return completion(Timeline(entries: [SimpleEntry (date: date, result: snackArray.randomElement()!)], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: date)!))) }
        let entry = SimpleEntry (
                    date: date,
            result: userArray.randomElement()!
                )
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
        let timeline = Timeline(
                    entries:[entry],
                    policy: .after(nextUpdateDate)
                )
        completion(timeline)
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let result: String
}

struct botcherwidgetEntryView : View {
    var entry: Provider.Entry
    let randomColor = UIColor.random()
    var body: some View {
        Text(entry.result)
            .font(.title)
            .foregroundColor(Color(UIColor.setTextColor(color: randomColor)))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(randomColor))
    }
}

@main
struct botcherwidget: Widget {
    let kind: String = "botcherwidget"
    
    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider(context: persistentContainer.viewContext)) { entry in
            botcherwidgetEntryView(entry: entry)
        }
        
        .configurationDisplayName("Botcher")
        .description("A widget to give you randomness!")
    }
    
}
var persistentContainer: NSPersistentContainer = {

    let container = NSPersistentCloudKitContainer(name: "Botcher")
    container.loadPersistentStores(completionHandler: {
        (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

struct botcherwidget_Previews: PreviewProvider {
    static var previews: some View {
        botcherwidgetEntryView(entry: SimpleEntry(date: Date(), result: "Make A Category"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
    static func setTextColor(color: UIColor) -> UIColor {
        if color.isLight() == true {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
}
extension UIColor {

    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
extension String {

    var length: Int {
        return count
    }
    
    

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
extension Font {
    func titleLengthCal(title: String) -> Font {
        if title.length <= 12 {
            return .title
        } else if title.length <= 20 {
            return .title2
        } else {
            return .title3
        }
    }
}
