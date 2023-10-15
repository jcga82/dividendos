//
//  AddMovimientoView.swift
//  Dividendos
//
//  Created by juancarlos on 14/10/23.
//

import SwiftUI

struct AddMovimientoView: View {
    @Environment (\.presentationMode) var presentationMode
    @State var empresas: [Empresa] = [Empresa]()
    @State var selectedEmpresa:Empresa?
    @State private var fecha = Date.now
    @State var acciones: Int = 1
    @State var tipo = "BUY"
    @State var precio = ""
    @State var idSelectedEmpresa = 0
    @State private var showingAlert = false
    @State private var showingAlertOK = false
    
    func saveMovimiento() {
        let id_cartera = UserDefaults.standard.integer(forKey: "cartera")
        let body = [
            "tipo": tipo,
            "acciones": acciones,
            "total_acciones": acciones,
            "precio": String(precio),
            "moneda": "USD",
            "cartera": id_cartera,
            "empresa": idSelectedEmpresa,
            "comision": "0",
            "cambio_moneda": "1",
            "fecha": convertDateToString(date: fecha)!
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
            print("entro 2", body, data, response, error)
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
                Section{
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
                    DatePicker(selection: getDateBinding(fecha: convertDateToString(date: fecha)!)!, in: ...Date.now, displayedComponents: .date) {
                        Text("Fecha")
                    }
                    Picker("Tipo", selection: $tipo) {
                        Text("Compra").tag("BUY")
                        Text("Venta").tag("SELL")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Stepper(value: $acciones, in: 1...1000) {
                        Text("Cantidad: \(getStringFromBindingInt(dato:$acciones) ?? "")")
                    }
                    
                    TextField("Precio", text: $precio)
                        .keyboardType(.numberPad)
                    
//                    ZStack(alignment: .trailing) {
//                        Text("Precio $")
//                        TextField("", text: $precio)
//                            .keyboardType(.numberPad)
//                    }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
//                        return 0
//                    }
//                    ZStack(alignment: .trailing) {
//                        Text("Precio")
//                        TextField("",value: $precio, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
//                    }.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
//                        return 0
//                    }
                    
                    Button(action: {
                        if idSelectedEmpresa>0 && precio != "" {
                            saveMovimiento()
                            showingAlertOK = true
                        } else {
                            showingAlert = true
                        }
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Guardar")
                            Spacer()
                        }
                    })
                    .buttonStyle(.bordered)
                    .foregroundColor(.white)
                    .background(.green)
                    .font(.footnote)
                    .cornerRadius(22)
                    
                    Button("Volver", action: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .foregroundColor(.white)
                        .background(.red)
                        .font(.footnote)
                        .cornerRadius(22)
                    
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Movimiento"),
                          message: Text("Debes seleccionar una empresa y un precio"),
                          dismissButton: .default(Text("Vamos a ello"))
                        )
                }
//                .alert(isPresented: $showingAlertOK) {
//                    Alert(title: Text("Movimiento"),
//                          message: Text("El movimiento se ha añadido correctamente"),
//                          dismissButton: .default(Text("OK"))
//                        )
//                }
            }
            .navigationTitle("Añadir Movimiento")
            .navigationBarTitleDisplayMode(.inline)
        }.task {
            await loadDataEmpresas()
        }
    }
}
