//
//  ContentView.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 19/6/23.
// Prueba commit

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            EmpresasView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            CarteraView()
                .tabItem {
                    Image(systemName: "basket.fill")
                    Text("Cartera")
                }
            ProfitView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Balance")
                }
            ChartsView()
                .tabItem {
                    Image(systemName: "giftcard.fill")
                    Text("Dividendos")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "pencil.circle.fill")
                    Text("Opciones")
                }
        }.accentColor(.green)
    }
}

struct EmpresasView: View {
    
    @StateObject var viewModel: ViewModel = ViewModel()
    @State private var searchText = ""
    @State private var selectedColor = "Red"
    @State private var colors = ["Red", "Green", "Blue"]
    @State private var enableLogging = false
    
    func saveData(){
        let encoder = JSONEncoder()
        if let encodedEmpresas = try? encoder.encode(viewModel.empresas) {
            UserDefaults.standard.set(encodedEmpresas, forKey: "empresas")
        }
    }
    
    var body: some View {
        VStack(spacing: 0){
            
            NavigationView {
                List {
                    ForEach(searchResults, id: \.nombre) { empresa in
                        HStack {
                            LogoView(logo: empresa.logo)
                            
                            NavigationLink(destination: DetalleEmpresaView(empresa: empresa)){
                                VStack{
                                    HStack{
                                        VStack(alignment: .leading) {
                                            Text(empresa.symbol).bold()
                                            Text(empresa.nombre).font(.callout)
                                        }
                                        Spacer()
                                        VStack {
                                            Image(empresa.pais)
                                                    .resizable()
                                                .frame(width: 25, height: 20)
                                            ZStack {
                                                Image(empresa.tipo == "aristocrata" ? "aristocrata" : empresa.tipo == "vaca" ? "vaca" : "flecha")
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                Text(String(getYearsDividend(year: Int(empresa.dividendo_desde)!)))
                                                    .font(.footnote)
                                                    .bold()
                                                    .foregroundColor(.white)
                                                    .background(
                                                        Circle().foregroundColor(.green).frame(width: 20, height: 25)
                                                    )
                                                    .offset(x: 10, y: -10)
                                            }
                                                
//                                                .overlay(HStack(alignment: .top) {
//                                                    Image(systemName: "1")
//                                                        .foregroundColor(.green).frame(maxWidth: .infinity)
//                                                }
//                                                    .frame(maxHeight: .infinity)
//                                                        .symbolVariant(.fill)
//                                                        .symbolVariant(.circle)
//                                                        .allowsHitTesting(false)
//                                                        .offset(x: 10, y: -10)
//                                                )
                                        }
                                    }
                                    
                                    //.badge(empresa.tipo)
                                }
                            }
                        }
                        
                        
                    }
                }.listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Busca por nombre")
//                .navigationBarItems(trailing: Button("Añadir", action: {
//                                print("Right Button")
//                            }))
                            .navigationTitle("Empresas")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarHidden(false)
            }.onAppear{
                viewModel.executeAPI()
                //saveData()
            }
        }
//        .tabItem {
//            Image(systemName: "house.fill")
//            Text("Home")
//        }
    }
    
    var searchResults: [Empresa] {
            if searchText.isEmpty {
                return viewModel.empresas
            } else {
                return viewModel.empresas.filter { $0.nombre.contains(searchText) }
            }
        }
}


struct ProfileView: View {
    
    @State private var carteras = [Cartera]()
    @State private var selectedCartera:Cartera?
    
    func loadCarteras() async {
        
        UserDefaults.standard.set(9, forKey: "cartera")
        
        guard let url = URL(string: "https://hamperblock.com/django/carteras" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(ResponseCar.self, from: data) {
                carteras = decodedResponse.results
                print(carteras)
            }
        } catch {
            print("ERROR: No hay carteras")
        }
    }
    
    var body: some View {
            NavigationView {
                List {
                    Section() {
                        VStack() {
                            Image("logo")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("HBLOCK50")
                            Text("v0.1 beta").font(.footnote)
                            Form {
                                Picker("Cartera:", selection: $selectedCartera) {
                                            ForEach(carteras, id: \.self) {
                                                Text($0.nombre).tag($0 as Cartera?)
                                            }
                                        }
                                        .onChange(of: selectedCartera) {
                                            print("ID Cartera select: \(selectedCartera?.id ?? 0)")
                                            UserDefaults.standard.set(selectedCartera?.id, forKey: "cartera")
                                        }
                                    }
                            NavigationLink(destination: Text("Pendiente...")) {
                                Label("Avanzado", systemImage: "slider.horizontal.3")
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 250)
                        Section() {
                            NavigationLink(destination: Text("Pendiente...")) {
                                Label("Modo oscuro", systemImage: "paintpalette")
                            }
                        }
                    }
//                            NavigationLink(destination: Text("aaa")) {
//                                Label("Colors", systemImage: "paintpalette")
//                            }
                }
                .navigationBarTitle("Opciones")
                .navigationBarTitleDisplayMode(.inline)
            }
            .accentColor(.accentColor)
            .task {
                await loadCarteras()
            }
        }
    }

struct StakingCard: View {
    var message: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
            Text("Stake tokens and get rewards")
                .foregroundColor(.white)
        }
//        .padding(.horizontal) // #1 - Texts padding
//        .frame(maxHeight: 100) // #4 - no maxWidth: .infinity
//        .background(
//            Image("blac")
//                .resizable()
//                .scaledToFill())
//        .cornerRadius(10)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LogoView: View {
    var logo: String
    var body: some View {
        AsyncImage(url: URL(string: "https://logo.clearbit.com/\(logo).com")) { image in
            image
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
            
        } placeholder: {
            Color.gray
        }
        .frame(width: 45, height: 45)
    }
}
