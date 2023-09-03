//
//  AddEditMovimientoView.swift
//  Dividendos
//
//  Created by juancarlos on 2/9/23.
//

import SwiftUI

struct AddEditMovimientoView: View {
    
    @Environment (\.presentationMode) var presentationMode
    @State var movimiento: Movimiento
    @State private var isEditing = true
    
    @State private var birthDate = Date.now
    @State var quantity: Int = 1
    
    func saveMovimiento() { //movimiento: Cartera
        let token = UserDefaults.standard.value(forKey: "token")
        print(token as Any)
        let url = URL(string: "https://hamperblock.com/django/carteras/")!
        let body = ["user": 1, "nombre": "Cartera App", "capital_inicial": 100] as [String : Any]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( token ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD", error as Any)
                return
            }
            let result = try? JSONDecoder().decode(Cartera.self, from: data)
                    if let result = result {
                        DispatchQueue.main.async {
                            print(result)
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(error as Any)
                        }
                    }
                }.resume()
    }
    
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()
    
    var body: some View {
            Form{
                if movimiento.acciones == 0 {
                        Section(header: Text("Customer Information")) {
                            TextField("Customer Name", text: $movimiento.tipo)
                            TextField("Address", text: $movimiento.fecha)
                        }
                    Section {
                        DatePicker(selection: $birthDate, in: ...Date.now, displayedComponents: .date) {
                            Text("Fecha")
                        }
                        HStack {
                            Picker("Tipo", selection: $movimiento.tipo) {
                                Text("Compra").tag("BUY")
                                Text("Venta").tag("SELL")
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                            Text(movimiento.tipo)
                        }
                        Stepper(value: $quantity, in: 1...1000) {
                            Text("Quantity: \(quantity)")
                        }
                        Text("Date is \(birthDate, formatter: dateFormatter)")
                    }
                    Button(action: {
                        print("Guardando...")
                        saveMovimiento()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Guardar")
                            Spacer()
                        }
                    })//.disabled(orderStatus)
                    
                } else {
                    Section{
                        VStack {
//                            HStack {
//                                Text("Empresa")
//                                Spacer()
//                                Text(movimiento.empresa.symbol)
//                            }
                            HStack {
                                Text("Tipo")
                                Spacer()
                                Text(movimiento.tipo)
                            }
                            HStack{
                                Text("Fecha")
                                Spacer()
                                Text(movimiento.fecha)
                            }
                        }
                    }
                }
            }
            
            Button("Cancel", action: {
                self.presentationMode.wrappedValue.dismiss()
            })
        .padding()
                .navigationTitle(isEditing ? "Editor" : "Detail")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
    }
}
