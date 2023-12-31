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
    let empresa: Int
    let acciones: Int
}

extension Date {
    func last(day: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: day, to: .now)!
    }
}

//let dividendos = portfolio.filter() {portfolio.contains([$0.empresa:$0.empresa])}

struct ChartsView: View {
    
    @State var posiciones = [Posicion]()
    @State var dividendos = [Dividendo]()
    @State var activos: [String] = []
    
    func loadDataCartera(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/posiciones" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, result) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponsePos.self, from: data) {
                let all_posiciones = decodedResponse.results
                print(result, all_posiciones.count)
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
    
    func loadDataDividendos() async {
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
    
    //let result = Dictionary(grouping: dividendos.filter({ $0.empresa.id}), by: { $0.dividendo })
    
    
    @State private var yearSelected = 2023
    @State var div = 1500
    
    func getDiv() -> Double {
        dividendos.reduce(0, { result, info in
            return result + info.dividendo
        })
    }
    
    func mediaDividendos() -> Double {
        return Double(getDiv()/12)
    }
    
    func getRentabilidad() -> Double {
        let padi = getDiv()
        let coste = posiciones.reduce(0, { result, info in
            return result + (Double(info.cantidad)*info.pmc)
        })
        return padi * 100 / coste
    }
    
//    @State var confirmado: Bool = true
//    @State var acciones: Int = 0
    
    enum SortOption {
            case name, dueDate, priority
        }
        @State private var sortOption: SortOption = .name
        var sortedTasks: [Dividendo] {
            switch sortOption {
            case .name:
                return dividendos.sorted { $0.empresa.symbol < $1.empresa.symbol }
            case .dueDate:
                return dividendos.sorted { $0.payable_date < $1.payable_date }
            case .priority:
                return dividendos.sorted { $0.dividendo > $1.dividendo }
            }
        }
    
    var body: some View {
        VStack {
            Image(systemName: "dollarsign.circle.fill")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Dividendos").font(.title)
            Text("PADI 2024: \(String(format: "%.2f", getDiv()))€").font(.headline)
            Text("Mensual: \(String(format: "%.2f", getDiv()/12))€")
            Text("YOC: \(String(format: "%.2f", getRentabilidad()))%").foregroundStyle(.green)
            
            Chart(getDesgloseDividendosMensual(dividendos: dividendos)) { data in
                BarMark(x: .value("Fecha", data.date, unit: .month),
                        y: .value("Dividendos", data.count))
                .annotation(position: .top, alignment: .center) {
                    Text("\(String(format: "%.0f", data.count))")
                        .font(.system(size: 10))
                }
                    .foregroundStyle(.yellow)
                RuleMark(y: .value("Media", getDiv()/12))
                    .foregroundStyle(.gray)
                    .annotation(position: .top, alignment: .leading) {
                        Label("\(Int(getDiv()/12))", systemImage: "flag.checkered")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .bold()
                    }
            }.frame(width: 350, height: 200)
            .task {
                await loadDataDividendos()
            }
            .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { day in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                        AxisTick()
                        AxisGridLine()
                    }
            }
            
            Picker("Año", selection: $yearSelected) {
                Text("2023").tag(2023)
                Text("2022").tag(2022)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Text("Nº Dividendos anuales: \(dividendos.count)").font(.footnote)
            
            VStack {
//                Picker("Sort By", selection: $sortOption) {
//                    Text("Name").tag(SortOption.name)
//                    Text("Due Date").tag(SortOption.dueDate)
//                    Text("Priority").tag(SortOption.priority)
//                }.pickerStyle(SegmentedPickerStyle())
                
                List(dividendos.sorted { $0.payable_date < $1.payable_date }, id: \.id) { div in
                    HStack {
                        LogoView(logo: div.empresa.logo)
                        VStack{
                            Text("\(String(div.payable_date))")
                            Text("Ex: \(String(div.ex_dividend))").font(.footnote)
                        }
                        Spacer()
                        VStack {
                            Text("\(String(format: "%.2f", div.dividendo))$")
                            Text("Ret. \(String(format: "%.2f", div.dividendo*0.19))$").font(.footnote).foregroundStyle(.gray)
                        }
                    }
                }
                .task {
                    let id_cartera = UserDefaults.standard.integer(forKey: "cartera")
                    print(id_cartera)
                    await loadDataCartera(id: id_cartera)
                }
                .navigationTitle("Siguientes pagos")
            }
            
        }

    }
}

