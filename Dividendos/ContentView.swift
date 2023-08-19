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
            
//            Form {
////                Section(footer: Text("Note: Enabling logging may slow down the app")) {
//                    Picker("Select a color", selection: $selectedColor) {
//                        ForEach(colors, id: \.self) {
//                            Text($0)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//
//                    Toggle("Enable Logging", isOn: $enableLogging)
////                }
//            }.frame(height: 130)
            
            NavigationView {
                List {
                    ForEach(searchResults, id: \.nombre) { empresa in
                        HStack {
                            LogoView(logo: empresa.logo)
                            
                            NavigationLink(destination: DetalleEmpresaView(empresa: empresa)){
                                VStack{
                                    HStack{
                                        Text(empresa.symbol)
                                        Spacer()
                                        Image(empresa.pais)
                                                .resizable()
                                                .frame(width: 20, height: 15)
                                    }
                                    
                                    Text(empresa.nombre).font(.callout).badge(empresa.tipo)
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
                                        .onChange(of: selectedCartera, perform: {cartera in
                                            print("ID Cartera select: \(cartera?.id ?? 0)")
                                            UserDefaults.standard.set(cartera?.id, forKey: "cartera")
                                        })
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
