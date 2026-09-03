import WidgetKit
import SwiftUI

// MARK: - モデルと定数
struct ClockConfig {
    static let thaiNumbers = ["๑๒", "๑", "๒", "๓", "๔", "๕", "๖", "๗", "๘", "๙", "๑๐", "๑๑"]
    
    static func getThaiWeekday(from date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let weekday = calendar.component(.weekday, from: date)
        let thaiWeekdays = ["", "อา.", "จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส."]
        if weekday >= 1 && weekday <= 7 {
            return thaiWeekdays[weekday]
        }
        return ""
    }
}

// MARK: - ウィジェットのメインビュー アナログ時計の見た目を作る部分
struct ThaiClockWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: entry.date))
        let minute = Double(calendar.component(.minute, from: entry.date))
        
        let minuteAngle = (minute * 6)
        let hourAngle = (hour * 30) + (minute * 0.5)

        let customRed = Color(red: 165/255, green: 25/255, blue: 49/255) // 🟥深みのある赤
        let customNavy = Color(red: 45/255, green: 42/255, blue: 74/255) // 💙紺色

        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                // 1. 一番後ろ：選択された背景写真
                if let uiImage = entry.backgroundImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Color.white
                }

                // 2. 文字盤（タイ数字を円状に配置）
                ForEach(0..<12) { i in
                    let angle = Double(i) * 30 * Double.pi / 180
                    
                    // 💡 【修正ポイント】固定値(-13)をやめて、割合(radius * 0.82)に変更！
                    // この 0.82 を 0.80 や 0.78 に小さくすると、さらに内側にキュッと入るよ。
                    let textX = center.x + CGFloat(sin(angle)) * (radius * 0.83)
                    let textY = center.y - CGFloat(cos(angle)) * (radius * 0.83)

                    Text(ClockConfig.thaiNumbers[i])
                        .font(.system(size: radius * 0.25, weight: .bold, design: .rounded)) // ほんの少し文字サイズ調整
                        .foregroundColor(customNavy)
                        .shadow(color: .white, radius: 4, x: 0, y: 0)
                        .shadow(color: .white, radius: 4, x: 0, y: 0)
                        .shadow(color: .white, radius: 2, x: 0, y: 0)
                        .position(x: textX, y: textY)
                }

                // 3. タイ語の曜日
                Text(ClockConfig.getThaiWeekday(from: entry.date))
                    .font(.system(size: radius * 0.22, weight: .bold, design: .rounded))
                    .foregroundColor(customRed)
                    .shadow(color: .white, radius: 4, x: 0, y: 0)
                    .shadow(color: .white, radius: 4, x: 0, y: 0)
                    .position(x: center.x, y: center.y + (radius * 0.45)) // 曜日も少し位置調整

                // 4. 時計の針（短針）
                Capsule()
                    .fill(customRed)
                    .frame(width: 5, height: radius * 0.42)
                    .shadow(color: .white, radius: 3, x: 0, y: 0)
                    .offset(y: -radius * 0.21)
                    .rotationEffect(.degrees(hourAngle))

                // 5. 時計の針（長針）
                Capsule()
                    .fill(customRed)
                    .frame(width: 4, height: radius * 0.60)
                    .shadow(color: .white, radius: 3, x: 0, y: 0)
                    .offset(y: -radius * 0.30)
                    .rotationEffect(.degrees(minuteAngle))

                // 6. 真ん中の丸（赤）
                Circle()
                    .fill(customRed)
                    .frame(width: 10, height: 10)
                    .shadow(color: .white, radius: 2, x: 0, y: 0)
            }
        }
    }
}

// MARK: - データ管理　時計の針を動かす仕組み
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), backgroundImage: nil)
    }
    // iPhoneでウィジェット追加する画面でのサンプル表示
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), backgroundImage: loadSharedImage())
        completion(entry)
    }
    //　時計の15分単位でデータ先取り1分ずつ動かす表示スケジュール
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        for minuteOffset in 0..<15 {
            if let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate) {
                let entry = SimpleEntry(date: entryDate, backgroundImage: loadSharedImage())
                entries.append(entry)
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
     // 共有フォルダから画像を読み込む関数　
    private func loadSharedImage() -> UIImage? {
            // AppDelegateが保存した、App Groupの共有フォルダを見に行くよ
            if let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.thaiclockNew") {
                // AppDelegateが保存した「widget_image.png」というファイルをピンポイントで指定！
                let fileURL = sharedContainer.appendingPathComponent("widget_image.png")
                // ファイルが無事に読み込めたら、画像にしてウィジェットに引き渡すよ
                if let data = try? Data(contentsOf: fileURL) {
                    return UIImage(data: data)
                }
            }
            return nil
        }
    // 💡 ウィジェットに表示するデータの形（時間を保持するよ）
    struct SimpleEntry: TimelineEntry {
        let date: Date
        let backgroundImage: UIImage?
    }
    
    // MARK: - 本番用ウィジェット定義
    @main
    struct ThaiClockWidget: Widget {
        let kind: String = "ThaiClockWidget"
        
        var body: some WidgetConfiguration {
            StaticConfiguration(kind: kind, provider: Provider()) { entry in
                if #available(iOS 17.0, *) {
                    ThaiClockWidgetEntryView(entry: entry)
                        .containerBackground(Color.clear, for: .widget) //　🆗20260706
                } else {
                    ThaiClockWidgetEntryView(entry: entry) //⭐️増えてるとこ OS17じゃなければこれ表示
                        .background(Color.clear) //⭐️増えてるとこOS17じゃなければこれ表示
                }
            }
            .contentMarginsDisabled() //⭐️ウィジェットの端っこの余分な白いところをなくして画面一杯に
            .configurationDisplayName("タイ語アナログ時計")
            .description("Flutterから送った写真の上で動く、タイ数字のアナログ時計ウィジェットです。")
            .supportedFamilies([.systemSmall,.systemMedium,.systemLarge,.systemExtraLarge])
        }
    }
}       
