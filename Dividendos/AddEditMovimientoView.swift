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
    @State var acciones: Int = 1
    @State var precio: Int = 1
    @State var idSelectedEmpresa = 0
    @State var carteraObjeto: Cartera = Cartera(id: 0, nombre: "", capital_inicial: "")
    @State private var showingAlert = false
    
    func saveMovimiento(movimiento: Movimiento) {
        let id_cartera = UserDefaults.standard.integer(forKey: "cartera")
        //print("eee", idSelectedEmpresa)
        //print(movimiento)
        let body = [
            "tipo": movimiento.tipo,
            "acciones": movimiento.acciones,
            "total_acciones": movimiento.total_acciones,
            "precio": String(movimiento.precio),
            "moneda": "USD",
            "cartera": id_cartera,
            "empresa": idSelectedEmpresa,
            "comision": "0",
            "cambio_moneda": "1",
            "fecha": movimiento.fecha
        ] as [String : Any]
        
        let token = UserDefaults.standard.value(forKey: "token")
        let url = URL(string: "https://hamperblock.com/django/movimiento/crear")!
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
            let result = try? JSONDecoder().decode(Movimiento.self, from: data)
                    Task {
                        await getActualizaCartera(idCartera: String(id_cartera))
                    }
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
    
    func updateMovimiento(movimiento: Movimiento) {
        print(movimiento)
        let body = [
            "id": movimiento.id,
            "tipo": movimiento.tipo,
            "acciones": movimiento.acciones,
            "precio": movimiento.precio,
            "moneda": "USD",
            "cartera": movimiento.cartera.id,
            "empresa": movimiento.empresa?.id ?? 0,
            "comision": "0",
            "cambio_moneda": "1",//movimiento.cambio_moneda,
            "fecha": movimiento.fecha
        ] as [String : Any]
        
        let token = UserDefaults.standard.value(forKey: "token")
        let url = URL(string: "https://hamperblock.com/django/movimiento/update")!
        let finalBody = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Token \( token ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("entro edit", response, error)
            guard let data = data, error == nil else {
                print("hay problemas de conexión con la BBDD", error as Any)
                return
            }
            let result = try? JSONDecoder().decode(Movimiento.self, from: data)
//                    Task {
//                        await getActualizaCartera(idCartera: String(movimiento.cartera.id))
//                    }
                    if let result = result {
                        DispatchQueue.main.async {
                            print("TODO OK")
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(error as Any)
                    }
            }
        }.resume()
    }
    
    func getActualizaCartera(idCartera: String) async {
        let url = URL(string: "https://hamperblock.com/django/movimientos/"+idCartera+"/get_movimientos")!
        print(url)
        do {
            let (data, result) = try await URLSession.shared.data(from: url)
            print("Actualizando Cartera...", data, result)
        } catch {
            print("ERROR: No se puede actualizar la cartera")
        }
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
    
    var body: some View {
        NavigationView {
            Form {
                if movimiento.acciones == 0 {
                    Section {
                        Picker("Empresa:", selection: $selectedEmpresa) {
                            ForEach(empresas, id: \.symbol) { empresa in
                                Text(empresa.symbol).tag(empresa as Empresa?)
                            }
                        }.pickerStyle(.navigationLink)
                        .onChange(of: selectedEmpresa) {
                                print("ID Empresa select: \(selectedEmpresa?.id ?? 0)")
                                print(empresas.count, selectedEmpresa!)
                                idSelectedEmpresa = selectedEmpresa?.id ?? 0
                        }
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
                        Stepper(value: $acciones, in: 1...1000) {
                            Text("Cantidad: \(acciones)")
                        }
                        ZStack(alignment: .trailing) {
                            Text("Precio")
                            TextField("",value: $precio, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return 0
                        }
                        ZStack(alignment: .trailing) {
                            Text("Cambio moneda").foregroundColor(.secondary)
                            TextField("password", text:$movimiento.cambio_moneda)
                        }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return 0
                        }
                        
                        
                        Button(action: {
                            print("Guardando...", movimiento)
                            if idSelectedEmpresa>0 {
                                saveMovimiento(movimiento: Movimiento(id: 1, tipo: "BUY", acciones: Double(acciones), total_acciones: Double(acciones), precio: String(precio), moneda: "USD", cartera: carteraObjeto, comision: "0", cambio_moneda: movimiento.cambio_moneda, fecha: convertDateToString(date: fecha)!))
                            } else {
                                showingAlert = true
                            }
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
                        Button("Volver", action: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                            .buttonStyle(.bordered)
                            .foregroundColor(.white)
                            .background(.red)
                            .font(.footnote)
                            .cornerRadius(22)
                        
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Movimiento"),
                                  message: Text("Debes seleccionar una empresa antes"),
                                  dismissButton: .default(Text("Vamos a ello"))
                            )
                        }
                    }
                    
                } else {
                    Section{
                        Picker("Empresa:", selection: $movimiento.empresa) {
                            ForEach(empresas, id: \.symbol) { empresa in
                                Text(empresa.symbol).tag(empresa as Empresa?)
                            }
                        }.pickerStyle(.navigationLink)
                        .onChange(of: selectedEmpresa) {
                                print("ID Empresa select: \(selectedEmpresa?.id ?? 0)")
                                print(empresas.count, selectedEmpresa!)
                                idSelectedEmpresa = selectedEmpresa?.id ?? 0
                        }
                        DatePicker(selection: getDateBinding(fecha: movimiento.fecha)!, in: ...Date.now, displayedComponents: .date) {
                            Text("Fecha")
                        }
                        Picker("Tipo", selection: $movimiento.tipo) {
                            Text("Compra").tag("BUY")
                            Text("Venta").tag("SELL")
                        }
                            .pickerStyle(MenuPickerStyle())
                        Stepper(value: $movimiento.acciones, in: 1...1000) {
                            Text("Cantidad: \(getStringFromBinding(dato:$movimiento.acciones) ?? "")")
                        }
                        ZStack(alignment: .trailing) {
                            Text("Precio")
                            TextField("",value: $precio, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return 0
                        }
                        ZStack(alignment: .trailing) {
                            Text("Cambio moneda").foregroundColor(.secondary)
                            TextField("password", text:$movimiento.cambio_moneda)
                        }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return 0
                        }
                        Button(action: {
                            updateMovimiento(movimiento: movimiento)
                        }, label: {
                            HStack {
                                Spacer()
                                Text("Actualizar")
                                Spacer()
                            }
                        })//.disabled(orderStatus)
                            .buttonStyle(.bordered)
                            .foregroundColor(.white)
                            .background(.green)
                            .font(.footnote)
                            .cornerRadius(22)
                        
                    }
                }
            }
            .padding()
            .navigationTitle(isEditing ? "Editar" : "Detalle")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                Button(isEditing ? "Hecho" : "Editar") {
//                    isEditing.toggle()
//                }
//            }
//            .onAppear{
//                viewModel.executeAPI()
//            }
        }.task {
            await loadDataEmpresas()
        }
    }
}
