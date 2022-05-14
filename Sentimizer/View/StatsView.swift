//
//  StatsView.swift
//  Sentimizer
//
//  Created by Samuel Ginsberg on 27.04.22.
//

import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State var timeInterval = K.timeIntervals[0]
    
    @State var width: CGFloat = 0
    
    @State var xAxis = ["8:15", "8:31", "9:44", "12:57", "14:19", "15:35"]
    @State var values = ([0.0, 0.3, 0.5, 0.65, 0.75, 1.0], [0.4, 0.2, 0.5, 0.25, 0.75, 1.0])
    
    @FetchRequest var entries: FetchedResults<Entry>
    
    let testData2 = (["Walking", "Training", "Lunch"], [0.75, 0.6, 0.15])
    let testData3 = (["Project Work", "Gaming"], [-0.4, -0.1])
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Picker("Time Interval", selection: $timeInterval) {
                    ForEach(K.timeIntervals, id: \.self) { interval in
                        Text(interval)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(K.brandColor2)
                .padding(.vertical, 5)
                .onReceive([self.timeInterval].publisher.first()) { value in
                    (xAxis, values) = getStats(entries: entries, interval: value)
                }
                
                Text("Mood")
                    .font(.senti(size: 20))
                    .padding([.leading, .top])
                
                MoodTrendChart(xAxis: xAxis, values: values)
                    .frame(height: 200)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).foregroundColor(K.brandColor1).opacity(0.1))
                
                Text("Improved Your Mood")
                    .font(.senti(size: 20))
                    .padding([.leading, .top])
                
                
                MoodInfluence(data: testData2, width: $width)
                    .overlay {
                        GeometryReader { g in
                            Color.clear
                                .onAppear() {
                                    width = g.size.width
                                }
                        }
                    }
                
                Text("Worsened Your Mood")
                    .font(.senti(size: 20))
                    .padding([.leading, .top])
                
                MoodInfluence(data: testData3, width: $width)
                
                
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 15)
        }
    }
    
    init() {
        let f:NSFetchRequest<Entry> = Entry.fetchRequest()
        // f.fetchLimit = 200
        f.sortDescriptors = [NSSortDescriptor(key: #keyPath(Entry.date), ascending: false)]
        _entries = FetchRequest(fetchRequest: f)
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(K.brandColor2)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(K.brandColor1)
    }
}

//MARK: MoodTrendChart View
struct MoodTrendChart: View {
    let xAxis: [String]
    let values: ([Double], [Double])
    
    var body: some View {
        GeometryReader { g in
            let height = g.size.height
            let width = g.size.width
            
            ZStack(alignment: .leading) {
                ZStack {
                    GeometryReader { g2 in
                        ZStack(alignment: .bottom) {
                            Graph(values: values)
                                .shadow(radius: 10)
                                .padding(.vertical)
                            
                            // Dates
                            ForEach(0..<xAxis.count, id: \.self) { i in
                                let iFloat: CGFloat = CGFloat(i)
                                let countFloat: CGFloat = CGFloat(xAxis.count-1)
                                let x = g2.size.width * (iFloat/countFloat)
                                Text("\(String(describing: xAxis[i]))")
                                    .position(x: x, y: g2.size.height)
                            }
                        }
                    }
                    .padding(.leading, 30)
                    .padding(.horizontal)
                    
                    // Middle lines
                    Path { path in
                        path.move(to: CGPoint(x: 40, y: height - (height/5) + 8))
                        path.addLine(to: CGPoint(x: width, y: height - (height/5) + 8))
                        path.move(to: CGPoint(x: 40, y: height - (height/2)))
                        path.addLine(to: CGPoint(x: width, y: height - (height/2)))
                        path.move(to: CGPoint(x: 40, y: height/5 - 8))
                        path.addLine(to: CGPoint(x: width, y: height/5 - 8))
                    }
                    .stroke(LinearGradient(colors: [K.brandColor2.opacity(0.5), K.brandColor3.opacity(0.5)], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                }
                
                // Senti images
                VStack {
                    ForEach(K.sentimentsArray, id: \.self) { sent in
                        if sent != K.sentimentsArray[1] && sent != K.sentimentsArray[3] {
                            Image(sent)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25)
                                .rotationEffect(.degrees(180))
                                .changeColor(to: K.brandColor2)
                        } else {
                            Spacer()
                                .frame(height: 42)
                        }
                    }
                }
                .rotationEffect(.degrees(180))
            }
        }
    }
    
    struct Graph: View {
        let values: ([Double], [Double])
        
        var body: some View {
            GeometryReader { g in
                let height = g.size.height
                let width = g.size.width
                
                Path { path in
                    if values.0.count > 0 {
                        let x = width * values.0[0]
                        let y = height * (1-values.1[0])
                        path.move(to: CGPoint(x: x-3, y: y))
                        path.addArc(center: CGPoint(x: x, y: y), radius: 4, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                        
                        for i in 1..<values.0.count {
                            let x = width * values.0[i]
                            let y = height * (1-values.1[i])
                            path.addLine(to: CGPoint(x: x, y: y))
                            path.addArc(center: CGPoint(x: x, y: y), radius: 4, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                        }
                    }
                }
                .stroke(LinearGradient(colors: [K.brandColor2, K.brandColor3], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 4, lineJoin: .round))
            }
            .padding(.vertical)
        }
    }
}

//MARK: - MoodInfluence View
struct MoodInfluence: View {
    let data: ([String], [Double])
    
    @Binding var width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<data.0.count, id: \.self) { index in
                VStack(alignment: .leading) {
                    HStack {
                        Text(data.0[index])
                            .font(.senti(size: 20))
                            .padding(5)
                        Text("\(String(format: "%.0f", abs(data.1[index]) * 100))% \(data.1[index] > 0 ? "positive" : "negative")")
                            .font(.senti(size: 15))
                            .foregroundColor(data.1[index] > 0 ? .green : .red)
                    }
                    
                    HStack {
                        Spacer().frame(width: data.1[index] > 0 ? 0 : nil)
                        RoundedRectangle(cornerRadius: 50)
                            .frame(width: width * abs(data.1[index]), height: 3)
                            .gradientForeground(colors: data.1[index] > 0 ? [.green, .green.adjust(brightness: 0.95)] :
                                                    [.red, .red.adjust(brightness: 0.95)],
                                                .leading, .trailing)
                            .padding(5)
                        Spacer().frame(width: data.1[index] < 0 ? 0 : nil)
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 25).foregroundColor(K.brandColor1).opacity(0.1)
        }
    }
}

//MARK: - Stats Methods
extension StatsView {
    func getMeans(stepSize:Double, rEntries:[[Entry]], i:Int, xValues: [Double], yValues:[Double]) -> ([Double], [Double]) {
        var xValues:[Double] = xValues
        var yValues: [Double] = yValues
        
        var mean:Double = 0
        
        for entry in rEntries[i] {
            mean += DataController.getSentiScore(for: entry.feeling!)
        }
        
        if rEntries[i].count != 0 {
            yValues.append(mean / Double(rEntries[i].count))
            xValues.append(stepSize * Double(i))
        }
        
        return (xValues, yValues)
    }
    
    func getStats(entries: FetchedResults<Entry>, interval: String, stamps: Int = 5) -> ([String], ([Double], [Double])){
        var xValues:[Double] = []
        var yValues: [Double] = []
        
        var xAxis:[String] = []
        
        if interval == K.timeIntervals[0] {
            var rEntries:[Entry] = []
            
            var firstTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())?.timeIntervalSince1970
            var lastTime = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())?.timeIntervalSince1970
            
            for entry in entries {
                if Calendar.current.isDateInToday(entry.date!) {
                    rEntries.insert(entry, at:0)
                }
            }
            
            if rEntries.count >= 1 {
                firstTime = rEntries[0].date!.timeIntervalSince1970
            }
            
            if rEntries.count >= 2 {
                lastTime = rEntries.last!.date!.timeIntervalSince1970
            }
            
            let stepSize = (lastTime! - firstTime!) / Double(stamps - 1)
            
            for i in 0..<stamps {
                xAxis.append(DataController.formatDate(date: Date(timeIntervalSince1970: firstTime! + stepSize * Double(i)), format: "HH:mm"))
            }
            
            var lastValue:Double = -1
            
            for entry in rEntries {
                yValues.append(DataController.getSentiScore(for: entry.feeling!))
                var xValue = (entry.date!.timeIntervalSince1970 - firstTime!) / (lastTime! - firstTime!)
                if xValue - lastValue < 0.1 {
                    xValue = lastValue + 0.1
                }
                
                xValues.append(xValue)
                
                lastValue = xValue
            }
            
            if lastValue > 1 {
                for i in 0..<xValues.count {
                    xValues[i] = xValues[i] / lastValue
                }
            }
        } else if interval == K.timeIntervals[1] {
            var rEntries:[[Entry]] = [[], [], [], [], [], [], []]
            
            let firstTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!.timeIntervalSince1970 - (60 * 60 * 24 * 6)
            let lastTime = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!.timeIntervalSince1970
            
            for entry in entries {
                let entryDate = entry.date!.timeIntervalSince1970
                
                if firstTime < entryDate && entryDate < lastTime {
                    rEntries[Calendar.current.dateComponents([.weekday], from: entry.date!).weekday! - 1].insert(entry, at:0)
                }
            }
            
            for i in 0..<7 {
                xAxis.insert(DataController.formatDate(date: Date(timeIntervalSince1970: lastTime - Double(60 * 60 * 24 * i)), format: "EE"), at:0)
                
                (xValues, yValues) = getMeans(stepSize: 1 / 6, rEntries: rEntries, i: i, xValues: xValues, yValues: yValues)
            }
        } else if interval == K.timeIntervals[2] {
            var rEntries:[[Entry]] = []
            
            let day = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
            let firstTime = day.timeIntervalSince1970
            let lastTime = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: day)!.timeIntervalSince1970
            
            
            let stepSize = (lastTime - firstTime) / Double(stamps - 1)
            
            for i in 0..<stamps {
                rEntries.append([])
                rEntries.append([])
                xAxis.append(DataController.formatDate(date: Date(timeIntervalSince1970: firstTime + stepSize * Double(i)), format: "d MMM"))
            }
            
            for entry in entries {
                let entryDate = entry.date!.timeIntervalSince1970
                
                if firstTime < entryDate && entryDate < lastTime {
                    rEntries[Int((entryDate - firstTime) / (stepSize / 2))].append(entry)
                }
            }
            
            for i in 0..<(stamps * 2) {
                (xValues, yValues) = getMeans(stepSize: 1 / Double(((2 * stamps) - 1)), rEntries: rEntries, i: i, xValues: xValues, yValues: yValues)
            }
        } else if interval == K.timeIntervals[3] {
            var rEntries:[[Entry]] = [[], [], [], [], [], [], [], [], [], [], [], []]
            
            let year = Calendar.current.component(.year, from: Date())
            let firstTime = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))!.timeIntervalSince1970
            let lastTime = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.date(from: DateComponents(year: year + 1, month: 1, day: 1))!)!.timeIntervalSince1970
            
            
            print(Date(timeIntervalSince1970: firstTime), Date(timeIntervalSince1970: lastTime))
            print(firstTime + 60 * 60 * 24 * 31 * 12, lastTime)
            
            for entry in entries {
                let entryDate = entry.date!.timeIntervalSince1970
                
                if firstTime < entryDate && entryDate < lastTime {
                    rEntries[Calendar.current.component(.month, from: entry.date!) - 1].insert(entry, at:0)
                }
            }
            
            for i in 0..<12 {
                xAxis.insert(String(Array(DataController.formatDate(date: Date(timeIntervalSince1970: lastTime - Double(60 * 60 * 24 * 31 * i)), format: "MMM"))[0]), at:0)
                
                (xValues, yValues) = getMeans(stepSize: 1 / 11, rEntries: rEntries, i: i, xValues: xValues, yValues: yValues)
            }
        }
        
        return (xAxis, (xValues, yValues))
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .font(.senti(size: 12))
            .minimumScaleFactor(0.8)
            .foregroundColor(.gray)
    }
}
