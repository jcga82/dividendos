//
//  charts.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 7/8/23.
//

import SwiftUI
import Charts

struct Info: Identifiable {
    let id: String = UUID().uuidString
    let date: Date
    let views: Int
}

extension Date {
    func last(day: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: day, to: .now)!
    }
}

let youtubeVideoModel: [Info] = [
    .init(date: Date().last(day: -1), views: 700),
    .init(date: .now.last(day: -2), views: 900),
    .init(date: .now.last(day: -3), views: 690),
    .init(date: .now.last(day: -4), views: 550),
    .init(date: .now.last(day: -5), views: 700),
    .init(date: .now.last(day: -6), views: 920),
    .init(date: .now.last(day: -7), views: 1250),
    .init(date: .now.last(day: -8), views: 800),
    .init(date: .now.last(day: -9), views: 820),
    .init(date: .now.last(day: -10), views: 1200),
    .init(date: .now.last(day: -11), views: 820),
    .init(date: .now.last(day: -12), views: 600)
]

var averageOfViews: Double = {
    let totalView = youtubeVideoModel.reduce(0, { result, info in
        return result + info.views
    })
    return Double(totalView/7)
}()

struct ChartsView: View {
    let thing = "guitars"
    let div = 2225
    @State private var favoriteColor = 2023
    @State var confirmado: Bool = true
    @State var acciones: Int = 0
    
    var body: some View {
        VStack {
            Form {
                Toggle("Solo confirmados", isOn: $confirmado)
                Stepper("Acciones: \(acciones)",
                        value: $acciones,
                        in: 1...5)
            }
            Image(systemName: thing)
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Dividendos").font(.title)
            Text("PADI 2023: \(div)€").font(.headline)
            Text("Mensual: \(div/12)€")
            Text("Rentabilidad: 3,82%")
            Text("YOC: 4,52%")
            
            Chart(youtubeVideoModel) { data in
                BarMark(x: .value("Date", data.date, unit: .month),
                        y: .value("Views", data.views))
                .annotation(position: .top, alignment: .center) {
                    Text("\(data.views)")
                        .font(.footnote)
                }
                    .foregroundStyle(.yellow)
                RuleMark(y: .value("Average", averageOfViews))
                    .foregroundStyle(.orange)
                    .annotation(position: .top, alignment: .leading) {
                        Label("\(Int(averageOfViews))", systemImage: "eye.fill")
                            .foregroundColor(.orange)
                            .font(.footnote)
                            .bold()
                    }
            }.frame(width: 350, height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { day in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                        AxisTick()
                        AxisGridLine()
                    }
                }
        }
        Picker("What is your favorite color?", selection: $favoriteColor) {
            Text("2023").tag(2023)
            Text("2022").tag(2022)
            Text("2021").tag(2021)
            Text("2020").tag(2020)
        }
        .pickerStyle(.segmented)
        
        Text("Value: \(favoriteColor)")
        
        Spacer()
    }
}

