//
//  MovimientosListView.swift
//  Dividendos
//
//  Created by juancarlos on 2/9/23.
//

import SwiftUI

struct MovimientosListView: View {
    
    @Binding public var movs: [Movimiento]
//    var isVolver: Bool = false
//    @State var selected = 0
//    @Environment(\.presentationMode) var presentationMode
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
        NavigationView {
            List {
                ForEach(movimientosFiltratos, id:\.id) { mov in
                    HStack {
                        NavigationLink(destination: AddEditMovimientoView(movimiento: mov)) {
                            HStack {
                                VStack {
                                    Image(systemName: mov.tipo=="BUY" ? "checkmark.circle.fill" : "rectangle.fill.badge.checkmark")
                                        .foregroundColor(mov.tipo=="BUY" ? .green : .red)
                                        .font(.title)

                                    Text(getDate(fecha:mov.fecha) ?? Date(), format: Date.FormatStyle().year().month().day())
                                        .font(.footnote)
                                }
                                VStack {
                                    HStack {
                                        Text("\(String(format: "%.0f", mov.acciones)) acc")
                                        //Text(isVolver ? "" : "@\(mov.empresa.symbol)")
                                    }
                                    Text("\(String(format: "%.2f", Double(mov.precio)!))€").font(.footnote)
                                }
                                Spacer()
                                VStack {
                                    Text("\(String(format: "%.2f", getCoste(acciones: mov.acciones, precio: mov.precio)!))€").font(.footnote).bold()
                                        .foregroundColor(mov.tipo=="BUY" ? .green : .red)
                                    Text(String(format: "%.0f", mov.total_acciones)).bold()
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteName)
            }
            .navigationTitle("Movimientos")
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
                AddEditMovimientoView(movimiento: Movimiento(id: 1, tipo: "BUY", acciones: 0, total_acciones: 0, precio: "0", moneda: "USD", cartera: movimientosFiltratos.first!.cartera, comision: "0", cambio_moneda: "0", fecha: ""))
            }
            .environment(\.editMode, $editMode)
        }
    }
}


//Image(systemName: "plus")
//    .resizable()
//    .padding(6)
//    .frame(width: 24, height: 24)
//    .background(Color.green)
//    .clipShape(Circle())
//    .foregroundColor(.white)
