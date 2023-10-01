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
    @State var viviendas = [Vivienda]()
    @State var profits = [Profit]()
    
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
                print("total carteras y mi id cartera actual", all_posiciones.count, id)
                posiciones = all_posiciones.filter { item in
                    if (item.cartera.id == id) {
                        return true
                    } else {
                        return false
                    }
                }
                activos = posiciones.map { $0.empresa.symbol }
                print("activos:", activos.count)
                print("hay \(posiciones.count) posiciones")
            }
        } catch {
            print("ERROR: No hay posiciones")
        }
    }
    
    func loadDataRentas(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/dividendos" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Dividendo].self, from: data) {
                let dividendos2023 = decodedResponse.filter { activos.contains($0.empresa.symbol) && $0.payable_date.contains("2023") }
                dividendos = dividendos2023.map { item in
                    Dividendo(id: item.id, date: item.date, dividendo: findPosicionesSymbol(posiciones: posiciones, symbol: item.empresa.symbol)*item.dividendo, ex_dividend: item.ex_dividend, payable_date: item.payable_date, frequency: item.frequency, tipo: item.tipo, empresa: item.empresa)
                }
                guard let url2 = URL(string: "https://hamperblock.com/django/rentas/") else {
                    print("Invalid URL")
                    return
                }
                do {
                    print("divs", activos.count, dividendos2023.count)
                    let (data, _) = try await URLSession.shared.data(from: url2)
                    if let decodedResponse = try? JSONDecoder().decode(ResponseRent.self, from: data) {
                        rentas = decodedResponse.results.filter { item in
                            if (item.cartera.id == id) {
                                return true
                            } else {
                                return false
                            }
                        }
                        print("hay \(rentas.count) rentas")
                        //Añado los dividendos
                        dividendos.map { div in
                            return rentas.append(Renta(id: div.id, cartera: rentas[0].cartera, tipo: "Dividendos", fecha_cobro: div.payable_date, cantidad: div.dividendo, pagada: false))
                        }
                    }
                } catch {
                    print("ERROR: No hay rentas")
                }
                print("hay \(dividendos2023.count) dividendos")
            }
        } catch {
            print("ERROR: No hay dividendos")
        }
    }
    
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
    
    func loadDataViviendas(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/viviendas" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseViv.self, from: data) {
                viviendas = decodedResponse.results.filter { item in
                    if (item.cartera.id == id) {
                        return true
                    } else {
                        return false
                    }
                }
                print("hay \(viviendas.count) viviendas")
            }
        } catch {
            print("ERROR: No hay viviendas")
        }
    }
    
    func getRentasTotal() -> Double {
        return rentas.reduce(0, { result, info in
            return result + (Double(info.cantidad))
        })
    }
    
    func getPatrimonioViviendas() -> Double {
        return viviendas.reduce(0, { result, info in
            return result + (Double(info.valor_cv))
        })
    }
    
    func getDeudaViviendas() -> Double {
        return viviendas.reduce(0, { result, info in
            return result + (Double(info.valor_hipoteca!))
        })
    }
    
    func getPatrimonioBolsa() -> Double {
        return viviendas.reduce(0, { result, info in
            return result + (Double(info.valor_cv))
        })
    }
    
    func getProfitsBolsa() -> Double {
        return profits.last?.balance ?? 0.0
    }
    
    
    var body: some View {
        
        @State var speed = 50.0
        
        NavigationView {
            VStack() {
                Text("RENTAS PASIVAS").font(.title)
                Divider()
                HStack {
                    VStack{
                        Text("RENTAS: \(String(format: "%.0f", getRentasTotal())) €/año").bold().font(.footnote)
                        if rentas.count>0 {
                            Chart(getDesgloseRentas(rentas: rentas), id: \.name) { data in
                                SectorMark(
                                    angle: .value("Ventas", data.count),
                                    innerRadius: .ratio(0.55),
                                    angularInset: 2.0
                                )
                                .foregroundStyle(by: .value("Empresa", "\(data.name): \(String(format: "%.0f",data.count))€"))
                                .annotation(position: .overlay) {
                                    Text("\(String(format: "%.0f", data.count*100/getRentasTotal()))%")
                                        .font(.footnote)
                                        .foregroundStyle(.white)
                                }
                            }.frame(height: 200).padding()
                            .chartBackground { proxy in
                                Text("💰").font(.system(size: 40))
                            }
                        }
                    }
                    Spacer()
                    VStack(alignment:.trailing) {
                        Text("Acciones: \(activos.count)").foregroundColor(.green).font(.footnote)
                        Text("Valor: \(String(format: "%.0f", profits.last?.valor ?? 0)) €").foregroundColor(.green).font(.footnote)
                        Text("P/G: \(String(format: "%.0f", profits.last?.profit ?? 0)) €").foregroundColor(.green).bold().font(.footnote)
                        Divider()
                        Text("Viviendas: \(viviendas.count)").foregroundColor(.blue).font(.footnote)
                        Text("Valor: \(String(format: "%.0f", getPatrimonioViviendas())) €").foregroundColor(.blue).font(.footnote)
                        Text("Deuda: \(String(format: "%.0f", getDeudaViviendas())) €").foregroundColor(.blue).font(.footnote)
                        Divider()
                        HStack{
                            Image(systemName: "flag.checkered")
                            Text("Patrim.\( String(format: "%.0f", (getProfitsBolsa() + getPatrimonioViviendas()) )) €").bold().font(.footnote)
                        }
                        Gauge(value:speed, in: 0...100){
                            Text("Obj.").font(.footnote)
                        } currentValueLabel: {
                            Text("\( String(format: "%.0f", (getProfitsBolsa() + getPatrimonioViviendas())*100/500000  )) %").bold().font(.body)
                        } .gaugeStyle(.accessoryCircular)
                            .tint(.green)
                        
                    }.padding(10)
                }.padding()
                
                
                
                Text("RENTAS MENSUALES").font(.subheadline).bold()
                
                Chart(rentas, id: \.id) { data in
                    BarMark(x: .value("Fecha", getDateShort(fecha: data.fecha_cobro)!, unit: .month),
                            y: .value("Beneficio", data.cantidad)
                    ).foregroundStyle(by: .value("Tipo", data.tipo))
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
                print(UserDefaults.standard.bool(forKey: "isAuthenticated"))
                print(UserDefaults.standard.integer(forKey: "cartera"))
                if (UserDefaults.standard.integer(forKey: "cartera") == 0){
                    UserDefaults.standard.set(9, forKey: "cartera")
                }
                await loadDataCartera(id: UserDefaults.standard.integer(forKey: "cartera"))
                await loadDataRentas(id: UserDefaults.standard.integer(forKey: "cartera"))
                await loadDataViviendas(id: UserDefaults.standard.integer(forKey: "cartera"))
                await loadDataProfits(id: UserDefaults.standard.integer(forKey: "cartera"))
            }
        }
        
    }
}

#Preview {
    DashboardView()
}
