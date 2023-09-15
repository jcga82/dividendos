//
//  ViviendasListView.swift
//  Dividendos
//
//  Created by juancarlos on 11/9/23.
//

import SwiftUI

struct ViviendasListView: View {
    
    @State var viviendas = [Vivienda]()
    @State private var editMode: EditMode = EditMode.inactive
    @State var showingEditSheet = false

    func loadDataViviendas(id: Int) async {
        let url = URL(string: "https://hamperblock.com/django/viviendas/")!
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
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            for i in offsets.makeIterator() {
                //deleteMovimiento(id: movimientosFiltratos[i].id)
            }
        
        }
    }
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(viviendas, id: \.self) { vivienda in
                    HStack{
                        NavigationLink(destination: AddEditViviendaView(vivienda: vivienda)) {
                            VStack(alignment:.leading) {
                                Text(vivienda.direccion).bold()
                                Text("Alquiler: \(String(format: "%.2f", vivienda.ingresos_mensuales))€").font(.footnote)
                            }
                        }
                        }
                    }.onDelete(perform: delete)
                
            }
            .navigationTitle("Viviendas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "plus")
                        .foregroundStyle(Color.green)
                            .onTapGesture {
                                showingEditSheet = true
                            }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                AddEditViviendaView()
            }
            .environment(\.editMode, $editMode)
            .task {
                await loadDataViviendas(id: UserDefaults.standard.integer(forKey: "cartera"))
            }
        }
    }
}

#Preview {
    ViviendasListView()
}
