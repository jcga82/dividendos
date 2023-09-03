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
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            CarteraView()
                .tabItem {
                    Image(systemName: "basket.fill")
                    Text("Bolsa")
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


