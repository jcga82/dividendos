//
//  FundamentalesEmpresaView.swift
//  Dividendos
//
//  Created by juancarlos on 15/10/23.
//

import SwiftUI
import Charts

struct FundamentalesEmpresaView: View {
    @State var symbol: String
    @Environment (\.presentationMode) var presentationMode
    @State var fundamentales = FundamentalesEmpresa(id: 0, fiscalDateEnding: "", num_acciones: 0, markercap: 0, ebitda: 0, per: 0, beta: 0, dpa: 0, bpa: 0, dya: 0, WeekHighYear: 0, WeekLowYear: 0, DayMovingAverage50: 0, DayMovingAverage200: 0)
    
    func loadDataFundamentales(symbol: String) async {
        let url = URL(string: "https://hamperblock.com/django/fundamentales/?symbol=" + symbol )!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([FundamentalesEmpresa].self, from: data) {
                fundamentales = decodedResponse[0]
            }
        } catch {
            print("ERROR: No hay datos")
        }
    }
    
    var body: some View {
        Text("Datos: \(fundamentales.fiscalDateEnding)").font(.title)
        VStack {
            Text("Mínimo y máximo 52 semanas").bold()
            HStack {
                VStack{
                    Gauge(value:fundamentales.DayMovingAverage50, in: fundamentales.WeekLowYear...fundamentales.WeekHighYear){
                        Text("Obj.").font(.footnote)
                    } currentValueLabel: {
                        Text("\( String(format: "%.0f",fundamentales.DayMovingAverage50))").bold().font(.body)
                    } minimumValueLabel: {
                      Text("\( String(format: "%.0f", fundamentales.WeekLowYear))").foregroundColor(.red)
                    } maximumValueLabel: {
                      Text("\( String(format: "%.0f", fundamentales.WeekHighYear))").foregroundColor(.green)
                    }
                    .gaugeStyle(.accessoryLinear)
                    .tint(Gradient(colors: [.red, .blue, .green]))
                    
                }
                VStack{
                    Text("MMA 50: \(String(format: "%.0f", fundamentales.DayMovingAverage50)) $").font(.footnote)
                    Text("MMA 200: \(String(format: "%.0f", fundamentales.DayMovingAverage200)) $").font(.footnote)
                }
            }
            VStack {
                Text("Capitalización: \(String(format: "%.0f", fundamentales.markercap/1000)) B$").bold()
                Text("BPA: \(String(format: "%.2f", fundamentales.bpa)) $/acción")
                Text("DPA: \(String(format: "%.2f", fundamentales.dpa)) $/acción")
                Text("Yield Div: \(String(format: "%.2f", fundamentales.dya)) %").foregroundColor(fundamentales.dya<2 ? .red : .green)
            }.padding()
            VStack {
                Text("Beta: \(String(format: "%.2f", fundamentales.beta))").foregroundColor(fundamentales.beta>1.5 ? .red : .green)
                Text("PER: \(String(format: "%.2f", fundamentales.per))").foregroundColor(fundamentales.per>20 ? .red : .green)
            }.padding()
        }.padding()
        
        .task {
            await loadDataFundamentales(symbol: symbol)
        }
    }
}
