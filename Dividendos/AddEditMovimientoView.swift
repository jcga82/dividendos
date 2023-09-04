//
//  AddEditMovimientoView.swift
//  Dividendos
//
//  Created by juancarlos on 2/9/23.
//

import SwiftUI

struct AddEditMovimientoView: View {
    
    @Environment (\.presentationMode) var presentationMode
    @State var movimiento: Movimiento// = Movimiento(id: 1, tipo: "", acciones: 0, total_acciones: 0, precio: "", moneda: "", cartera: Cartera(id: 0, nombre: "", capital_inicial: ""), comision: "", cambio_moneda: "", fecha: "")
    @State private var isEditing = true
    @State var empresas: [Empresa] = [Empresa]()
    @State var selectedEmpresa:Empresa?
    
    @State private var fecha = Date.now
    @State var quantity: Int = 1
    @State var carteraObjeto: Cartera = Cartera(id: 0, nombre: "", capital_inicial: "")
    
    func saveMovimiento(movimiento: Movimiento) {
        
        do {
            let data = UserDefaults.standard.object(forKey: "carteraObjeto") as? Data
            print("entro", data as Any)
            let carteraObjeto = try JSONDecoder().decode(Cartera.self, from: data!)
            print("eee", carteraObjeto)
        } catch {
            print("Error decoding JSON carteraObjeto: \(error)")
        }
        
        let token = UserDefaults.standard.value(forKey: "token")
        let url = URL(string: "https://hamperblock.com/django/movimientos/")!
        let body = [movimiento]
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( token ?? "")", forHTTPHeaderField: "Authorization")
        print("entro 2")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD", error as Any)
                return
            }
            let result = try? JSONDecoder().decode(Movimiento.self, from: data)
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
    
    func loadDataEmpresas() async {
        let url = URL(string: "https://hamperblock.com/django/empresas/")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Empresa].self, from: data) {
                empresas = decodedResponse
                print("hay \(empresas.count) empresas")
            }
        } catch {
            print("ERROR: No hay contratos")
        }
    }
    
//    func getCarterasObjetc() -> Cartera {
//        if let carteraObj = UserDefaults.standard.object(forKey: "carteraObjeto") as? Data {
//            let decoder = JSONDecoder()
//            if let cartera = try? decoder.decode(Cartera.self, from: carteraObj) {
//                print(cartera)
//                return cartera
//            }
//        }
//    }
    
    var body: some View {
        NavigationView {
            Form {
                if movimiento.acciones == 0 {
                    Picker("Empresa:", selection: $selectedEmpresa) {
                        ForEach(empresas, id: \.symbol) { empresa in
                            Text(empresa.symbol).tag(empresa as Empresa?)
                        }
                    }.pickerStyle(.wheel)
                        .onChange(of: selectedEmpresa) {
                            print("ID Empresa select: \(selectedEmpresa?.id ?? 0)")
                            print(empresas.count, selectedEmpresa!)
                            //selectedEmpresa = selectedEmpresa
                        }
                    
                    Section(header: Text("Customer Information")) {
                        TextField("Customer Name", text: $movimiento.tipo)
                        TextField("Address", text: $movimiento.fecha)
                    }
                    Section {
                        DatePicker(selection: $fecha, in: ...Date.now, displayedComponents: .date) {
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
                        Text("Date is \(fecha, formatter: dateFormatter)")
                        Button(action: {
                            print("Guardando...", movimiento)
                            //if selectedEmpresa!.id>0 {
                            saveMovimiento(movimiento: Movimiento(id: 1, tipo: "BUY", acciones: Double(quantity), total_acciones: Double(quantity), precio: "1", moneda: "USD", empresa: selectedEmpresa!, cartera: carteraObjeto, comision: "0", cambio_moneda: "1", fecha: DateFormatter().string(from: fecha)))
                            //}
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Guardar")
                                Spacer()
                            }
                        })//.disabled(orderStatus)
                        .buttonStyle(.bordered)
                        .foregroundColor(.white)
                        .background(.green)
                        .font(.footnote)
                        .cornerRadius(22)
                    }
                    
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
//            .onAppear{
//                viewModel.executeAPI()
//            }
        }.task {
            await loadDataEmpresas()
        }
    }
}
