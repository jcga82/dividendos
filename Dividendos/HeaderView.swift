//
//  HeaderView.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 19/6/23.
//

import SwiftUI

struct  HeaderView: View {

    let accentPrimary = Color(.green)
    @State private var searchText = ""

    var body: some View {
        NavigationView{
            Text("Searching for \(searchText)?")
                .searchable(text: $searchText)
                .navigationTitle("Empresas")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button {
                        print("Pressed edit button")
                    } label: {
                        Text("Edit")
                    },

                    trailing: Button {
                            print("Pressed compose button")
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                )
        }
        .frame(height: 80)

    }
}
