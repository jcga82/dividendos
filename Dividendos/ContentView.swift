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
            CarteraView()
                .tabItem {
                    Image(systemName: "basket.fill")
                    Text("Bolsa")
                }
            EmpresasView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Empresas")
                }
            
            ChartsView()
                .tabItem {
                    Image(systemName: "giftcard.fill")
                    Text("Dividendos")
                }
            ViviendasView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Viviendas")
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
                UserDefaults.standard.set(9, forKey: "cartera")
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
