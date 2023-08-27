//
//  ProfitView.swift
//  Dividendos
//
//  Created by juancarlos on 20/8/23.
//

import SwiftUI
import Charts

struct ProfitViviendaView: View {
    @State var viviendas = [Vivienda]()
    @State var rentas = [Renta]()
    
    func loadDataAlquileres(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/rentas/") else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseRent.self, from: data) {
                print(decodedResponse)
                rentas = decodedResponse.results.filter { item in
                    if (item.vivienda.cartera.id == id) {
                        //revisar esto
                        return true
                    } else {
                        return false
                    }
                }
                print("hay \(rentas.count) rentas de alquileres")
            }
        } catch {
            print("ERROR: No hay rentas")
        }
    }
    
    func getActivosTotales() -> Double {
        return viviendas.reduce(0, { result, info in
            return result + info.valor_cv
        })
    }
    
    func getTotalAportado() -> Double {
        return viviendas.reduce(0, { result, info in
            return result + info.capital_aportar!
        })
    }
    
    
    func getRentabilidad() -> Double {
        return getTotalAportado() * 100 / getActivosTotales()
    }
    
    
    var body: some View {
        
        VStack {
            Text("Balance Viviendas").font(.title)
            Text("Valor Activos: \(String(format: "%.0f", getActivosTotales() ))€").font(.headline)
            Text("Total aportado: \(String(format: "%.0f", getTotalAportado() ))€")
            //Text("Fecha: \(profits.last?.fecha ?? "N/D")")
            Text("Rentabilidad: \(String(format: "%.2f", getRentabilidad()))%").foregroundColor(.green)
            
//            Chart(profits) { data in
//                BarMark(x: .value("Fecha", getDateShort(fecha: data.fecha)!, unit: .day),
//                        y: .value("Beneficio", data.valor))
//                RuleMark(y: .value("Media", data.aportado_total))
//                    .foregroundStyle(.red)
//            }
//            .frame(width: 350, height: 200)
//            .task {
//                await loadDataProfits(id: UserDefaults.standard.integer(forKey: "cartera"))
//            }
//            .chartXAxis {
//                    AxisMarks(values: .stride(by: .month)) { day in
//                        AxisValueLabel(format: .dateTime.month(.abbreviated))
//                        AxisTick()
//                        AxisGridLine()
//                    }
//            }
            
            List(rentas.sorted { $0.fecha_cobro > $1.fecha_cobro }, id: \.id) { renta in
                HStack {
                    VStack {
                        Text("\(String(renta.fecha_cobro))")
                        Text("\(String(format: "%.2f", renta.cantidad))€").font(.footnote)
                    }
                    Text(renta.vivienda.direccion).font(.footnote)
                    Spacer()
                    Image(systemName: renta.pagada ? "creditcard.circle" : "creditcard.circle.fill")
                        .foregroundColor( renta.pagada ? .green : .red)
                        .font(.system(size: 30))
                }
            }
            .navigationTitle("Ingresos alquileres")
            .task {
                await loadDataAlquileres(id: UserDefaults.standard.integer(forKey: "cartera"))
            }
        }
    }
}

#Preview {
    ProfitViviendaView()
}
