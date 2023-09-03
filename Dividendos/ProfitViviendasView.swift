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
            let (data, result) = try await URLSession.shared.data(from: url)
            print(result)
            if let decodedResponse = try? JSONDecoder().decode(ResponseRent.self, from: data) {
                rentas = decodedResponse.results.filter { item in
                    if (item.cartera.id == id) {
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
            
            Chart(rentas) { data in
                BarMark(x: .value("Fecha", getDateShort(fecha: data.fecha_cobro)!, unit: .month),
                        y: .value("Beneficio", data.cantidad))
            }
            .frame(width: 350, height: 200)
            .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { day in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                        AxisTick()
                        AxisGridLine()
                    }
            }
            
            List(rentas.sorted { $0.fecha_cobro > $1.fecha_cobro }, id: \.id) { renta in
                HStack {
                    VStack {
                        Text("\(String(renta.fecha_cobro))")
                        Text("\(String(format: "%.2f", renta.cantidad))€").font(.footnote)
                    }
                    Spacer()
                    VStack {
                        Image(systemName: renta.pagada ? "creditcard.circle" : "creditcard.circle.fill")
                            .foregroundColor( renta.pagada ? .green : .red)
                            .font(.system(size: 25))
//                        Text((renta.vivienda != nil) ? "renta.vivienda?.direccion" : "Dividendo").font(.footnote) revisar esto
                    }
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
