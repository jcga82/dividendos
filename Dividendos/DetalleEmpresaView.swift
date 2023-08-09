//
//  DetalleEmpresaView.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 19/6/23.
//

import SwiftUI

struct Message: Decodable, Identifiable {
    let id: Int
    let from: String
    let text: String
}

struct DetalleEmpresaView: View {
    @State private var results = [Result]()
    var empresa: Empresa

    func loadData(symbol: String) async {
        guard let url = URL(string: "https://hamperblock.com/django/analisis/?symbol=" + symbol ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedResponse.results
                print(results)
            }
        } catch {
            print("ERROR: No hay datos")
        }
    }
    
        var body: some View {
            
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
                            } else if phase.error != nil {
                                Text("There was an error loading the image.")
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 50, height: 100)
                        
                        
                    }
                }
//
//                CardView(card: empresa)
//                    .cornerRadius(28)
//                    .shadow(radius: 16, y: 16)
                    
                }.task {
                    await loadData(symbol: empresa.symbol)
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
