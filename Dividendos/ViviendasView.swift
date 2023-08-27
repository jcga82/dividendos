//
//  ViviendasView.swift
//  Dividendos
//
//  Created by juancarlos on 25/8/23.
//

import SwiftUI
import Charts

struct ViviendasView: View {
    
    @State var viviendas = [Vivienda]()
    @State var contratos = [Contrato]()
    @State var num_contratos = 0
    
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
    
    func loadDataContratos() async {
        guard let url = URL(string: "https://hamperblock.com/django/contratos/" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Contrato].self, from: data) {
                contratos = decodedResponse
                print("hay \(contratos.count) contratos")
            }
        } catch {
            print("ERROR: No hay contratos")
        }
    }
    
    var body: some View {
        NavigationView {
            
            VStack {
                HStack {
                    Chart(viviendas, id: \.id) { data in
                        SectorMark(
                            angle: .value("Ventas", data.valor_cv),
                            innerRadius: .ratio(0.55),
                            angularInset: 2.0
                        )
                    }.frame(height: 130)
                    .chartBackground { proxy in
                        Text("🏠").font(.system(size: 35))
                    }
                    Spacer()
                    VStack(alignment:.leading) {
                        Text("Alquilado: 1").foregroundColor(.green)
                        Text("Libre: 2")
                        Text("Total: \(contratos.count)").bold()
                    }
                }.padding()
                
                Divider()
                
                VStack(alignment:.leading) {
                    Text("Cobrado: 0").foregroundColor(.green)
                    Text("No cobrado: 0").foregroundColor(.red)
                    Text("Total: 0")
                }
                
                
                List {
                    Section(header: Text("DETALLE"), content: {
                        NavigationLink(destination: ProfitViviendaView(viviendas: viviendas)){
                            Label("Balance", systemImage: "chart.xyaxis.line")
                        }
                        NavigationLink(destination: ContratosView()){
                            Label("Contratos", systemImage: "doc.badge.clock.fill")
                        }
                    })
                    Section(header: Text("VIVIENDAS"), content: {
                        ForEach(viviendas, id: \.self) { vivienda in
                            NavigationLink(destination: ViviendaView(vivienda: vivienda, plazoSliderValue: vivienda.plazo!)) {
                                VStack(alignment:.leading) {
                                    Text(vivienda.direccion).bold()
                                    Text("Alquiler: \(String(format: "%.2f", vivienda.ingresos_mensuales))€").font(.footnote)
                                }
                            }
                        }
                    })
                }
                .navigationBarTitle("Viviendas")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(false)
            }
            
            
        }.task {
            await loadDataViviendas(id: UserDefaults.standard.integer(forKey: "cartera"))
            await loadDataContratos()
        }
    }
}

struct ViviendaView: View {
    
    @State var vivienda: Vivienda
    @State var contratos = [Contrato]()
    
    @State var financiacion: Bool = true
    @State private var showingSheet = false
    @State var volumeSliderValue: Double = 0.75
    @State var plazoSliderValue: Double = 15
    var minValue: Double = 1
    var maxValue: Double = 50
    
    func getContratosVivienda(id: String) async -> [Contrato] {
        guard let url = URL(string: "https://hamperblock.com/django/contratos/?vivienda=" + id ) else {
            print("Invalid URL")
            return contratos
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Contrato].self, from: data) {
                contratos = decodedResponse
            }
        } catch {
            print("ERROR: No hay contratos")
        }
        return contratos
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(footer:
                    HStack {
                        Spacer()
                        Button(action: {
                            showingSheet.toggle()
                        }) {
                            Text("Ver Rentabilidad")
                                //.frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: 18))
                                .padding()
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                }
                            .background(Color.green)
                            .cornerRadius(25)
                            .sheet(isPresented: $showingSheet, content: {
                                ResultadosViviendaView(vivienda: $vivienda)
                            })
                                Spacer()
                            }
                ){}
                Section(header: Text("COMPRA-VENTA"), content: {
                    HStack{
                        Image(systemName: "creditcard")
                        Text("Valor")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.valor_cv))€")
                    }
                    HStack{
                        Image(systemName: "banknote")
                        Text("Gastos")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.gastos_cv))€")
                    }
                    HStack{
                        Image(systemName: "pipe.and.drop")
                        Text("Reforma")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.gastos_reforma))€")
                    }
                })
                Section(header: Text("INGRESOS Y GASTOS"), content: {
                    HStack{
                        Image(systemName: "dollarsign.arrow.circlepath")
                        Text("Ingresos")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.ingresos_mensuales))€").foregroundStyle(.green)
                    }
                    HStack{
                        Image(systemName: "building.columns")
                        Text("IBI anual")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.gastos_ibi))€")
                    }
                    HStack{
                        Image(systemName: "lanyardcard")
                        Text("Seguro")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.gastos_seguros))€")
                    }
                    HStack{
                        Image(systemName: "key")
                        Text("Comunidad")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.gastos_comunidad))€")
                    }
                })

                Section(header: Text("FINANCIACIÓN"), content: {
                    HStack{
                        Image(systemName: "bookmark")
                        Toggle(isOn: $financiacion) {
                            Text("Financiado")
                        }
                    }
                    if financiacion {
                        HStack{
                            Text("% Financiado")
                            Spacer()
                            Text("\(String(format: "%.0f",vivienda.pct_finan!*100))%")
                            Slider(value: $volumeSliderValue, in: 0...1, step: 0.01)
                                .accentColor(Color.green)
                        }
                        HStack{
                            Text("Plazo (años)")
                            Spacer()
//                            Text("\(String(format: "%.0f",vivienda.plazo!)) años")
                            Slider(value: $plazoSliderValue, in: 0...1, step: 0.01)
                                .accentColor(Color.green)
                                .padding(.top)
                                                .overlay(GeometryReader { gp in
                                                    Text("\(vivienda.plazo!,specifier: "%.f")")
                                                        .alignmentGuide(HorizontalAlignment.leading) {
                                                            $0[HorizontalAlignment.leading] - (gp.size.width - $0.width) * vivienda.plazo! / ( maxValue - minValue)
                                                        }
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }, alignment: .top)
                        }
                        HStack{
                            Text("Interés")
                            Spacer()
                            Text("\(String(format: "%.2f",vivienda.interes!))%")
                        }
                    }

                })
            }
            .navigationBarTitle(vivienda.direccion)
            .navigationBarItems(trailing: Button(action: {
                              print("abrir contratos")
                            } ) {
                                Button(action: {}) {
                                    HStack {
                                        Text(" \(String(contratos.count))")
                                            .font(.system(size: 20))
                                            .task {
                                                contratos = await getContratosVivienda(id: String(vivienda.id))
                                            }
                                        Image(systemName: "doc.on.doc")
                                            .resizable()
                                            .font(.system(size: 15))
                                    }
                                }
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .cornerRadius(.infinity)
                        } )
        }
        
    }
}

struct ResultadosViviendaView: View {
    @Binding public var vivienda: Vivienda
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("RENTABILIDAD"), content: {
                    HStack{
                        Text("Rent. Bruta")
                        Spacer()
                        Text("\(String(format: "%.2f",vivienda.rent_bruta!))%").foregroundColor(.green)
                    }
                    HStack{
                        Text("Rent. Neta").bold()
                        Spacer()
                        Text("\(String(format: "%.2f",vivienda.rent_neta!))%").bold().foregroundColor(.green)
                    }
                    HStack{
                        Text("ROCE")
                        Spacer()
                        Text("\(String(format: "%.2f",vivienda.roce!))%")
                    }
                })
                Section(header: Text("CASH FLOW"), content: {
                    HStack{
                        Text("Cuota pago mes")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.cuota_hipoteca_mes!))€")
                    }
                    HStack{
                        Text("Cash Flow").bold()
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.cash_flow!))€").bold().foregroundColor(.green)
                    }
                })
                Section(header: Text("Resultados Operación"), content: {
                    HStack{
                        Text("Valor Hipoteca")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.valor_hipoteca!))€")
                    }
                    HStack{
                        Text("Capital Aportado")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.capital_aportar!))€")
                    }
                    HStack{
                        Text("ITP")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.itp!))€")
                    }
                    HStack{
                        Text("Gastos anuales")
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.gastos_anuales!))€")
                    }
                    HStack{
                        Text("Total compra").bold()
                        Spacer()
                        Text("\(String(format: "%.0f",vivienda.total_compra!))€").bold()
                    }
                })
            }
            .navigationTitle(vivienda.direccion)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark.circle.fill")
                    }

                }
            })
        }
    }

}

#Preview {
    ViviendasView()
}
