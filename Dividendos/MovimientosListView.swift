//
//  MovimientosListView.swift
//  Dividendos
//
//  Created by juancarlos on 2/9/23.
//

import SwiftUI

struct MovimientosListView: View {
    
    @Binding public var movs: [Movimiento]
    var isVolver: Bool = false
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
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            for i in offsets.makeIterator() {
                //print(movimientosFiltratos[i].id)
                deleteMovimiento(id: movimientosFiltratos[i].id)
            }
        
        }
    }
    
    func deleteMovimiento(id: Int) {
        let body = [
            "id": id
        ] as [String : Any]
        
        let token = UserDefaults.standard.value(forKey: "token")
        let url = URL(string: "https://hamperblock.com/django/movimiento/delete")!
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( token ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("entro 2", data, response, error)
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD", error as Any)
                return
            }
            let result = try? JSONDecoder().decode(Request.self, from: data)
                print("Borrado correctamente")
        }.resume()
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
                                        Text(isVolver ? "" : "@\(mov.empresa?.symbol ?? "")")
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
                .onDelete(perform: delete)
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
                AddEditMovimientoView(movimiento: Movimiento(id: 1, tipo: "BUY", acciones: 0, total_acciones: 0, precio: "0", moneda: "USD", cartera: UserDefaults.standard.integer(forKey: "cartera"), comision: "0", cambio_moneda: "0", fecha: ""))
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
