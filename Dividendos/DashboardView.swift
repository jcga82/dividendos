//
//  DashboardView.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 28/8/23.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @State var rentas = [Renta]()
    @State var posiciones = [Posicion]()
    @State var dividendos = [Dividendo]()
    @State private var showingSheet = false
    @State var activos: [String] = []
    
    func loadDataCartera(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/posiciones" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponsePos.self, from: data) {
                let all_posiciones = decodedResponse.results
                posiciones = all_posiciones.filter { item in
                    if (item.cartera.id == id) {
                        return true
                    } else {
                        return false
                    }
                }
                activos = posiciones.map { $0.empresa.symbol }
                print("hay \(posiciones.count) posiciones")
            }
        } catch {
            print("ERROR: No hay posiciones")
        }
    }
    
    func loadDataDividendos(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/dividendos" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Dividendo].self, from: data) {
                let dividendos2023 = decodedResponse.filter { activos.contains($0.empresa.symbol) && $0.payable_date.contains("2023") }
                //dividendos = dividendos2023
                dividendos = dividendos2023.map { item in
                    Dividendo(id: item.id, date: item.date, dividendo: findPosicionesSymbol(posiciones: posiciones, symbol: item.empresa.symbol)*item.dividendo, ex_dividend: item.ex_dividend, payable_date: item.payable_date, frequency: item.frequency, tipo: item.tipo, empresa: item.empresa)
                }
                //dividendos.forEach { print($0) }
                print("hay \(dividendos2023.count) dividendos")
            }
        } catch {
            print("ERROR: No hay dividendos")
        }
    }
    
    func loadDataRentas(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/rentas/") else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseRent.self, from: data) {
                rentas = decodedResponse.results.filter { item in
                    if (item.cartera.id == id) {
                        return true
                    } else {
                        return false
                    }
                }
                print("hay \(rentas.count) rentas")
            }
        } catch {
            print("ERROR: No hay rentas")
        }
    }
    
    func getCosteTotal() -> Double {
        return posiciones.reduce(0, { result, info in
            return result + (Double(info.cantidad)*info.pmc)
        })
    }
    
    
    var body: some View {
        
        NavigationView {
            VStack() {
                Text("Total Invertido \(String(format: "%.0f", getCosteTotal()))").bold()
                
                Text("Desglose por inversión (%)").font(.subheadline)
                
                Chart(getDesgloseRentas(rentas: rentas), id: \.name) { data in
                    SectorMark(
                        angle: .value("Ventas", data.count),
                        innerRadius: .ratio(0.55),
                        angularInset: 2.0
                    )
                    .foregroundStyle(by: .value("Empresa", data.name))
                    .annotation(position: .overlay) {
                        Text("\(String(format: "%.0f", data.count))%")
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                }.frame(height: 200).padding()
                .chartBackground { proxy in
                    Text("💼").font(.system(size: 45))
                }
                
                Text("RENTAS MENSUALES").font(.subheadline).bold()
                
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
                
                
            }
            .task {
                await loadDataCartera(id: UserDefaults.standard.integer(forKey: "cartera"))
                await loadDataRentas(id: UserDefaults.standard.integer(forKey: "cartera"))
                await loadDataDividendos(id: UserDefaults.standard.integer(forKey: "cartera"))
            }
        }
        
    }
}

#Preview {
    DashboardView()
}
