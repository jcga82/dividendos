//
//  CarteraView.swift
//  Dividendos
//
//  Created by juancarlos on 11/8/23.
//

import SwiftUI
import Charts

struct CarteraView: View {
    
    @State var posiciones = [Posicion]()
    @State var movimientos = [Movimiento]()
    @State private var showingSheet = false
    
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
                print("hay \(posiciones.count) posiciones")
            }
        } catch {
            print("ERROR: No hay posiciones")
        }
    }
    
    func loadDataMovimientos(id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/movimientos" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseMov.self, from: data) {
                print(decodedResponse)
                let all_movimientos = decodedResponse.results
                movimientos = all_movimientos.filter { item in
                    if (item.cartera.id == id) {
                        return true
                    } else {
                        return false
                    }
                }
                print("hay \(movimientos.count) movimientos en cartera \(id)")
            }
        } catch {
            print("ERROR: No hay movimientos")
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
                Divider()
//                Button("Mis Movimientos") {
//                    showingSheet.toggle()
//                }.sheet(isPresented: $showingSheet) {
//                    MovimientosView(movs: $movimientos, isName: true)
//                    }.task {
//                        await loadDataMovimientos(id: UserDefaults.standard.integer(forKey: "cartera"))
//                    }
                Text("Desglose por países ($)").font(.subheadline)
                
                Chart (getDesglosePorPaises(posiciones: posiciones), id: \.name) { data in
                    BarMark(
                        x: .value("Cup", data.count)
                    )
                    .foregroundStyle(by: .value("Tipo", "\(data.name): \(String(format: "%.0f",data.count))"))
                }.frame(height: 60).padding()
                
                Text("Desglose por sector (%)").font(.subheadline)
                
                Chart(getDesglosePorSectores(posiciones: posiciones), id: \.name) { data in
                    SectorMark(
                        angle: .value("Ventas", data.count),
                        innerRadius: .ratio(0.55),
                        angularInset: 2.0
                    )
                    .foregroundStyle(by: .value("Empresa", data.name))
                    .annotation(position: .overlay) {
                        Text("\(String(format: "%.0f", data.count*100/getCosteTotal()))%")
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                }.frame(height: 200).padding()
                .chartBackground { proxy in
                    Text("💼").font(.system(size: 45))
                }
                
                List {
                    Section(header: Text("DETALLE"), content: {
                        NavigationLink(destination: {
                            EmpresasView()
                        })
                        {
                            Label("Rádar Empresas", systemImage: "basket.fill")
                        }
                        NavigationLink(destination: {
                            List(posiciones, id: \.id) { pos in
                                HStack {
                                    LogoView(logo: pos.empresa.logo)
                                    VStack {
                                        Text("\(String(pos.cantidad)) acc").bold()
                                        Text("PMC: \(String(format: "%.2f", pos.pmc))$").font(.caption)
                                    }
                                    Spacer()
                                    VStack {
                                        Text("\(String(format: "%.2f", getCoste(acciones: Double(pos.cantidad), precio: String(pos.pmc))!))€")
                                            //.foregroundColor(pos.tipo=="BUY" ? .green : .red)
                                        Text("\(String(format: "%.2f", Double(pos.cantidad)*pos.pmc*100/getCosteTotal()))%").font(.caption)
                                    }
                                }
                            }
                        }
                        ) {
                            Label("Mis Posiciones", systemImage: "bag.fill")
                        }
                        NavigationLink(destination: {
                            MovimientosListView(movs: $movimientos)
                        })
                        {
                            Label("Mis Movimientos", systemImage: "folder.fill")
                        }
                        NavigationLink(destination: ProfitView()){
                            Label("Mi Balance", systemImage: "chart.xyaxis.line")
                        }
                        NavigationLink(destination: FearIndexView()){
                            Label("Índice Miedo & Codicia ", systemImage: "chart.xyaxis.line")
                        }
                    })
                    
                    
                    .task {
                        await loadDataCartera(id: UserDefaults.standard.integer(forKey: "cartera"))
                        await loadDataMovimientos(id: UserDefaults.standard.integer(forKey: "cartera"))
                    }
                }
                .navigationBarTitle("Cartera Bolsa")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(false)
                
            }
        }
        
    }
}
