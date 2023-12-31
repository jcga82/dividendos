//
//  DetalleEmpresaView.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 19/6/23.
//

import SwiftUI
import Foundation
import SwiftUIImageViewer


struct Message: Decodable, Identifiable {
    let id: Int
    let from: String
    let text: String
}

struct DetalleEmpresaView: View {
    @State private var results = [Result]()
    @State var movimientos = [Movimiento]()
    @State var dividendos = [Dividendo]()
    @State var historico = [HistoricoEmpresa]()
    var empresa: Empresa
    @State private var showingSheet = false
    @State private var showingFundamentales = false
    @State private var showingRatios = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isImagePresented = false

    func loadData(symbol: String) async {
        guard let url = URL(string: "https://hamperblock.com/django/analisis/?symbol=" + symbol ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedResponse.results
                //print(results)
            }
        } catch {
            print("ERROR: No hay datos")
        }
    }
    
    func loadDataMovimientos(symbol: String, id: Int) async {
        guard let url = URL(string: "https://hamperblock.com/django/movimientos/?symbol=" + symbol ) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( UserDefaults.standard.value(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseMov.self, from: data) {
                let all_movimientos = decodedResponse.results
                movimientos = all_movimientos.filter { item in
                    if (item.cartera.id == id) {
                        return true
                    } else {
                        return false
                    }
                }
                print("hay \(movimientos.count) movimientos en la cartera \(id)")
            }
        } catch {
            print("ERROR: No hay movimientos")
        }
    }
    
    func loadHistoricoDividendos(symbol: String) async {
        let url = URL(string: "https://hamperblock.com/django/dividendos/?symbol=" + symbol )!
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( UserDefaults.standard.value(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Dividendo].self, from: data) {
                dividendos = decodedResponse
                print("hay \(dividendos.count) dividendos")
            }
        } catch {
            print("ERROR: No hay dividendos")
        }
    }
    
    func loadFundamentales(symbol: String) async {
        let url = URL(string: "https://hamperblock.com/django/historico/?symbol=" + symbol )!
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( UserDefaults.standard.value(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseHistorico.self, from: data) {
                historico = decodedResponse.results
                print("hay \(historico.count) historico para esta empresa")
            }
        } catch {
            print("ERROR: No hay historico")
        }
    }
    
    private var closeButton: some View {
            Button {
                isImagePresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())
            .tint(.purple)
            .padding()
        }
    
        var body: some View {
            
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: empresa.cabecera)) { image in
                    image
                        .resizable()
                    
                } placeholder: {
                    Color.gray
                }
                .scaledToFill()
                .cornerRadius(20)
                .frame(height: 120, alignment: .top) //  <<: Here
                .clipped()
                .padding()

                HStack {
                    LogoView(logo: empresa.logo).padding(10).offset(y: 45)

                    Text(empresa.symbol).padding().offset(y:65).font(.largeTitle).bold()

                    Spacer()
                    VStack {
                        Image(empresa.pais)
                                .resizable()
                                .frame(width: 40, height: 30)
                            .padding(40).offset(y: 50)
                        
                        Image(systemName: "gamecontroller.fill").offset(y: 30) //empresa.sector
                    }
                    
                }
            }
            
            VStack (alignment:.leading) {
                
                Text(empresa.nombre)
                    .font(.largeTitle)
                Text(empresa.isin)
                    .font(.callout)
                Divider()
                Text(empresa.description)
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
            }.padding()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Estrategia: \(empresa.estrategia)")
                        .font(.subheadline)
                    Spacer()
                    Text(empresa.dividendo_desde)
                            .foregroundColor(.purple)
                            .font(.headline)
                            .bold()
                }
                
                Button("Histórico Dividendos") {
                    showingSheet.toggle()
                }
                .sheet(isPresented: $showingSheet) {
                    HistoricoDividendosView(dividendos: $dividendos, logo: empresa.logo, cagr5: empresa.cagr5)
                }.task {
                    await loadHistoricoDividendos(symbol: empresa.symbol)
                }
                
                HStack{
                    Text("Filtros")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(.green)
                        .font(.title)
                }
                
            }.padding(.horizontal, 25)
            
//            Button("Movimientos") {
//                showingSheet.toggle()
//            }
//            .sheet(isPresented: $showingSheet) {
//                //MovimientosView(movs: $movimientos, isVolver: true)
//            }.task {
//                await loadDataMovimientos(symbol: empresa.symbol, id: UserDefaults.standard.integer(forKey: "cartera"))
//            }
            Button("Ver Ratios Fundamentales") {
                showingRatios.toggle()
            }
            .sheet(isPresented: $showingRatios) {
                FundamentalesEmpresaView(symbol: empresa.symbol)
            }
            
            Button("Ver Fundamentales \(historico.count) años") {
                showingFundamentales.toggle()
            }
            .sheet(isPresented: $showingFundamentales) {
                if historico.count > 0 {
                    HistoricoEmpresaView(historico: $historico, logo: empresa.logo)
                }
            }.task {
                await loadFundamentales(symbol: empresa.symbol)
            }
                
            NavigationView {
                List(results, id: \.id) { item in
                    HStack {
                        VStack {
                            Text(item.fecha).font(.headline).badge(item.tags)
                            Text(item.descripcion).font(.footnote)
                        }
                        AsyncImage(url: URL(string: item.captura)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .onTapGesture {
                                        isImagePresented = true
                                    }
                                    .fullScreenCover(isPresented: $isImagePresented) {
                                        SwiftUIImageViewer(image: image)
                                            .overlay(alignment: .topTrailing) {
                                                closeButton
                                            }
                                    }
                            } else if phase.error != nil {
                                Text("There was an error loading the image.")
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 50, height: 100)
                    }
                }
            }.task {
                await loadData(symbol: empresa.symbol)
            }
//            Spacer()
            }
}

struct MovimientosView: View {
    @Binding public var movs: [Movimiento]
    var isVolver: Bool = false
    @State var selected = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var tipoSecleccionado = 0
    
    @State private var editMode: EditMode = EditMode.inactive
    @State var showingEditSheet = false
    
    var movimientosFiltratos: [Movimiento] {
        if tipoSecleccionado == 0 {
            return movs
        } else if tipoSecleccionado == 1 {
            return movs.filter { $0.tipo == "BUY" }
        } else if tipoSecleccionado == 2 {
            return movs.filter { $0.tipo == "SELL" }
        } else {
            return movs.filter { $0.tipo == "CASH IN" }
        }
    }
    
    private func deleteName(offsets: IndexSet) {
        withAnimation {
            offsets.sorted(by: > ).forEach { (index) in
                print(index)
                //movimientosFiltratos.remove(at: idx)
            }
        }
    }
    
    var body: some View {
//        VStack {
//            Button(isVolver ? "Volver" : "") {
//                presentationMode.wrappedValue.dismiss()
//            }.onAppear {
//                print(movs)
//            }
//            Picker("", selection: $tipoSecleccionado) {
//                Text("Todos").tag(0)
//                Text("Compras").tag(1)
//                Text("Ventas").tag(2)
//            }
//            .pickerStyle(.segmented).padding(.horizontal, 40)
//        }
        NavigationView {
            List {
                ForEach(movimientosFiltratos, id:\.id) { mov in
                    HStack {
                        if editMode.isEditing {
                            Image(systemName: "square.and.pencil")
                                .padding(5)
                                .onTapGesture {
                                    showingEditSheet = true
                                    selected = mov.id
                                    print(selected)
                                }
                        }
//                        NavigationLink(destination: AddEditMovimientoView($movimiento: mov)) {
//                            HStack {
//                                VStack {
//                                    Image(systemName: mov.tipo=="BUY" ? "checkmark.circle.fill" : "rectangle.fill.badge.checkmark")
//                                        .foregroundColor(mov.tipo=="BUY" ? .green : .red)
//                                        .font(.title)
//                                    
//                                    Text(getDate(fecha:mov.fecha) ?? Date(), format: Date.FormatStyle().year().month().day())
//                                        .font(.footnote)
//                                }
//                                VStack {
//                                    HStack {
//                                        Text("\(String(format: "%.0f", mov.acciones)) acc")
//                                        Text(isVolver ? "" : "@\(mov.empresa.symbol)")
//                                    }
//                                    Text("\(String(format: "%.2f", Double(mov.precio)!))€").font(.footnote)
//                                }
//                                Spacer()
//                                VStack {
//                                    Text("\(String(format: "%.2f", getCoste(acciones: mov.acciones, precio: mov.precio)!))€").font(.footnote).bold()
//                                        .foregroundColor(mov.tipo=="BUY" ? .green : .red)
//                                    Text(String(format: "%.0f", mov.total_acciones)).bold()
//                                }
//                            }
//                        }
                    }
                }
                .onDelete(perform: deleteName)
            }
            .navigationTitle("Movimientos")
//            .navigationBarItems(trailing: NavigationLink(destination: AddEditMovimientoView()) {
//                Image(systemName: "plus")
//                    .resizable()
//                    .padding(6)
//                    .frame(width: 24, height: 24)
//                    .background(Color.green)
//                    .clipShape(Circle())
//                    .foregroundColor(.white)
//            })
//            .navigationBarItems(trailing: EditButton()) {
//                                Image(systemName: "plus")
//                                    .resizable()
//                                    .padding(6)
//                                    .frame(width: 24, height: 24)
//                                    .background(Color.green)
//                                    .clipShape(Circle())
//                                    .foregroundColor(.white)
//                            })
            .environment(\.editMode, $editMode)
        }
        
    }
}

struct AnalisisView: View {
    let analisis: AnalisisEmpresa
    
    var body: some View {
        Rectangle()
            .foregroundColor(.gray)
            .frame(width: 340, height: 500, alignment: .center)
    }
}

struct CardView: View {
    let card: Empresa
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "https://logo.clearbit.com/\(card.logo ).com")) { image in
                image
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)

            } placeholder: {
                Color.gray
            }
            .frame(width: 45, height: 45)
 
            HStack {
                VStack(alignment: .leading) {
                    Text(card.symbol)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("hola")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                    Text("Written by Simon Ng".uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .layoutPriority(100)
 
                Spacer()
            }
            .padding()
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top, .horizontal])
    }
}
