//
//  FearIndexView.swift
//  Dividendos
//
//  Created by juancarlos on 15/10/23.
//

import SwiftUI
import Charts

struct FearIndexView: View {
    @State private var fear_and_greed = FearAndGreed(score: 0, rating: "fear", timestamp: "2023-10-13T23:59:53+00:00", previous_close:0, previous_1_week:0, previous_1_month:0, previous_1_year:0)
    @State var arrayData = [Data]()
    
    func getDataIndex() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string:"https://production.dataviz.cnn.io/index/fearandgreed/graphdata")!)
            if let decodedResponse = try? JSONDecoder().decode(ResponseFAG.self, from: data) {
                fear_and_greed = decodedResponse.fear_and_greed
                arrayData = decodedResponse.fear_and_greed_historical.data
            }
        } catch {
            print("ERROR: No hay datos")
        }
    }
        var body: some View {
            VStack {
                HStack {
                    Text(fear_and_greed.timestamp.prefix(10) + ": " +  fear_and_greed.rating)
                    Gauge(value:fear_and_greed.score, in: 0...100){
                        Text("Obj.").font(.footnote)
                    } currentValueLabel: {
                        Text("\( String(format: "%.0f",fear_and_greed.score))").bold().font(.body)
                            .foregroundColor(fear_and_greed.score<50 ? .red : .green)
                    } minimumValueLabel: {
                      Text("0").foregroundColor(.red)
                    } maximumValueLabel: {
                      Text("100").foregroundColor(.green)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(Gradient(colors: [.red, .blue, .green]))
                    //.frame(width: 200, height: 200)
                }
                HStack {
                    
                }
            }
            VStack{
                Chart(arrayData, id: \.x) { data in
                    BarMark(x: .value("Fecha", Date(timeIntervalSince1970: (data.x / 1000.0)), unit: .month),
                            y: .value("Beneficio", data.y)
                    )//.foregroundStyle(by: .value("Tipo", data.tipo))
                }
                .frame(width: 350, height: 200)
//                .chartXAxis {
//                        AxisMarks(values: .stride(by: .month)) { day in
//                            AxisValueLabel(format: .dateTime.month(.abbreviated))
//                            AxisTick()
//                            AxisGridLine()
//                        }
//                }
            }
            
            
            .task {
                await getDataIndex()
            }
        }
    }

    struct ResponseFAG: Codable {
        var fear_and_greed: FearAndGreed
        var fear_and_greed_historical: FearAndGreedHistorico
    }

struct FearAndGreed: Codable {
    var score: Double
    var rating: String
    var timestamp: String
    var previous_close: Double
    var previous_1_week: Double
    var previous_1_month: Double
    var previous_1_year: Double
}

struct FearAndGreedHistorico: Codable {
    var score: Double
    var rating: String
    var timestamp: String
    var data: [Data]
}

struct Data: Codable {
    var x: Double
    var y: Double
    var rating: String
}
