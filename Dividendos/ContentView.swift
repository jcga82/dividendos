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
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Home")
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
                                    
                                    Text(empresa.nombre).font(.callout).badge(empresa.estrategia)
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
    var body: some View {
            NavigationView {
                List {
                    Section() {
                        VStack() {
                            Image("test")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("Test word")
                                .foregroundColor(Color.red)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 150)
                    }
                    ForEach((0..<4), id: \.self) { index in
                        Section {
                            NavigationLink(destination: Text("aaa")) {
                                Label("Buttons", systemImage: "capsule")
                            }
                            NavigationLink(destination: Text("aaa")) {
                                Label("Colors", systemImage: "paintpalette")
                            }
                            NavigationLink(destination: Text("aaa")) {
                                Label("Controls", systemImage: "slider.horizontal.3")
                            }
                        }
                    }
                }
                .navigationBarTitle("SwiftUI")
                .navigationBarTitleDisplayMode(.inline)
            }
            .accentColor(.accentColor)
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
