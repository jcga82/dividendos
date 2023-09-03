//
//  EmpresasListView.swift
//  Dividendos
//
//  Created by juancarlos on 1/9/23.
//

import SwiftUI

struct EmpresasView: View {
    
    @StateObject var viewModel: ViewModel = ViewModel()
    @State private var searchText = ""
    @State var tipoSecleccionado = 0
    
    func saveData(){
        let encoder = JSONEncoder()
        if let encodedEmpresas = try? encoder.encode(viewModel.empresas) {
            UserDefaults.standard.set(encodedEmpresas, forKey: "empresas")
        }
    }
    
    var body: some View {
        VStack(spacing: 0){
//            Picker("", selection: $tipoSecleccionado) {
//                Text("Todas").tag(0)
//                Text("EEUU").tag(1)
//                Text("UK").tag(2)
//                Text("ES").tag(3)
//                Text("Otras").tag(4)
//            }
//            .pickerStyle(.segmented).padding(.horizontal, 40)
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
    }
    
    var searchResults: [Empresa] {
        if searchText.isEmpty {
            return viewModel.empresas
        } else {
            return viewModel.empresas.filter { $0.nombre.contains(searchText) }
        }
    }
    
    var empresasFiltratas: [Empresa] {
        if tipoSecleccionado == 0 {
            return viewModel.empresas
        } else if tipoSecleccionado == 1 {
            return viewModel.empresas.filter { $0.pais == "eeuu" }
        } else if tipoSecleccionado == 2 {
            return viewModel.empresas.filter { $0.pais == "uk" }
        } else if tipoSecleccionado == 3 {
            return viewModel.empresas.filter { $0.pais == "spain" }
        } else {
            return viewModel.empresas.filter { $0.pais == "others" }
        }
    }
    
    
}

#Preview {
    EmpresasView()
}
