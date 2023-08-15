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
    
    func loadDataCartera() async {
        guard let url = URL(string: "https://hamperblock.com/django/posiciones" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponsePos.self, from: data) {
                let all_posiciones = decodedResponse.results
                posiciones = all_posiciones.filter { item in
                    if (item.cartera.nombre == "Div JC") {
                        return true
                    } else {
                        return false
                    }
                }
                posiciones.forEach { item in
                    print(item)
                    getEmpresa(symbol: item.symbol)
                }
                print("hay \(posiciones.count) posiciones")
            }
        } catch {
            print("ERROR: No hay posiciones")
        }
    }
    
    func loadDataMovimientos() async {
        guard let url = URL(string: "https://hamperblock.com/django/movimientos" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseMov.self, from: data) {
                let all_movimientos = decodedResponse.results
                movimientos = all_movimientos.filter { item in
                    if (item.cartera.nombre == "Div JC") {
                        return true
                    } else {
                        return false
                    }
                }
                print("hay \(movimientos.count) movimientos")
            }
        } catch {
            print("ERROR: No hay movimientos")
        }
    }
    
    func getEmpresa(symbol: String) -> Void  {
        let empresas = UserDefaults.standard.array(forKey: "empresas")
        if let savedUserData = UserDefaults.standard.object(forKey: "empresas") as? Data {
            let decoder = JSONDecoder()
            if let savedUser = try? decoder.decode([Empresa].self, from: savedUserData) {
                print("Saved user: \(savedUser)")
            }
        }
        //print("ya", empresas.forEach {$0})
    }
    private var paises = [
        (name: "EEUU", count: 70),
        (name: "UK", count: 15),
        (name: "España", count: 4),
        (name: "Canadá", count: 2)
    ]
    
    
    var body: some View {
        
        VStack {
            Button("Movimientos") {
                showingSheet.toggle()
            }
            .sheet(isPresented: $showingSheet) {
                MovimientosView(movs: $movimientos, isName: true)
            }.task {
                await loadDataMovimientos()
            }
            
            Chart (paises, id: \.name) { data in
                BarMark(
                    x: .value("Cup", data.count)
                )
                .foregroundStyle(by: .value("Type", data.name))
            }.frame(height: 60).padding()
            
            Text("% por países").font(.subheadline)
            
            Chart(posiciones) { data in
                SectorMark(
                    angle: .value("Ventas", Double(data.cantidad)*data.pmc),
                    innerRadius: .ratio(0.55),
                    angularInset: 2.0
                )
                .foregroundStyle(by: .value("Empresa", data.symbol))
                .annotation(position: .overlay) {
                    Text("\(String(format: "%.0f", Double(data.cantidad)*data.pmc))")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .chartBackground { proxy in
                Text("💹").font(.system(size: 50))
            }
            Text("% Invertido").font(.subheadline)
            
            List(posiciones, id: \.id) { pos in
                HStack {
                    VStack {
                        Text(pos.symbol)
                        Text("\(String(format: "%.2f", pos.pmc))$").font(.caption)
                    }
                    Spacer()
                    
                    VStack {
                        Text("\(String(pos.cantidad))").bold()
                        Text("\(String(format: "%.2f", getCoste(acciones: Double(pos.cantidad), precio: String(pos.pmc))!))€").font(.caption)
                            //.foregroundColor(pos.tipo=="BUY" ? .green : .red)
                    }
                }
            }
            .task {
                await loadDataCartera()
            }
            
        }
        
        
    }
}
