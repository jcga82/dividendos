//
//  ProfitView.swift
//  Dividendos
//
//  Created by juancarlos on 20/8/23.
//

import SwiftUI
import Charts

struct ProfitView: View {
    @State var profits = [Profit]()
    
    func loadDataProfits(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/profit" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Profit].self, from: data) {
                profits = decodedResponse.filter { item in
                    if (item.cartera.id == id) {
                        return true
                    } else {
                        return false
                    }
                }
                print("hay \(profits.count) profits")
            }
        } catch {
            print("ERROR: No hay profits")
        }
    }
    
    
    func getRentabilidad() -> Double {
        guard let lastElement = profits.last else {
                print("You didn't provide a name!")
                return 0
            }
        return lastElement.profit * 100 / lastElement.aportado_total
    }
    
    
    var body: some View {
        
        VStack {
            Text("Balance Cartera").font(.title)
            Text("Liquidez: \(String(format: "%.0f", profits.last?.balance ?? 0))€").font(.headline)
            Text("Total aportado: \(String(format: "%.0f", profits.last?.aportado_total ?? 0))€")
            Text("Fecha: \(profits.last?.fecha ?? "N/D")")
            Text("Rentabilidad: \(String(format: "%.2f", getRentabilidad()))%")
            
            Chart(profits) { data in
                BarMark(x: .value("Fecha", getDateShort(fecha: data.fecha)!, unit: .day),
                        y: .value("Beneficio", data.valor))
                RuleMark(y: .value("Media", data.aportado_total))
                    .foregroundStyle(.red)
            }
            .frame(width: 350, height: 200)
            .task {
                await loadDataProfits(id: UserDefaults.standard.integer(forKey: "cartera"))
            }
            .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { day in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                        AxisTick()
                        AxisGridLine()
                    }
            }
            List(profits.sorted { $0.fecha > $1.fecha }, id: \.id) { profit in
                HStack {
                    Text("\(String(profit.fecha))")
                    Text("(\(String(format: "%.0f", profit.valor))€)").font(.footnote)
                    Spacer()
                    VStack {
                        Text("\(String(format: "%.2f", profit.profit))€")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfitView()
}
