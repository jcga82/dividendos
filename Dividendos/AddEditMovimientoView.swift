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

    @State var empresas: [Empresa] = [Empresa]()
    @State var selectedEmpresa:Empresa?
    
    @State var idSelectedEmpresa = 0
    //@State var carteraObjeto: Cartera = Cartera(id: 0, nombre: "", capital_inicial: "")
    @State private var showingAlert = false
    
    func updateMovimiento(movimiento: Movimiento) {
        print(movimiento)
        let body = [
            "id": movimiento.id,
            "tipo": movimiento.tipo,
            "acciones": movimiento.acciones,
            "precio": movimiento.precio,
            "moneda": "USD",
            "cartera": movimiento.cartera.id,
            "empresa": movimiento.empresa.id,
            "comision": "0",
            "cambio_moneda": "1",//movimiento.cambio_moneda,
            "fecha": movimiento.fecha, //convertDateToString(date: movimiento.fecha)!
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
                    Task {
                        await getActualizaCartera(idCartera: String(movimiento.cartera.id))
                    }
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
                Section {
                    Picker("Empresa:", selection: $movimiento.empresa) {
                        ForEach(empresas, id: \.symbol) { empresa in
                            Text(empresa.symbol).tag(empresa as Empresa)
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
                    HStack {
                        Picker("Tipo", selection: $movimiento.tipo) {
                            Text("Compra").tag("BUY")
                            Text("Venta").tag("SELL")
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                        Text(movimiento.tipo)
                    }
                    
                    HStack {
                        Stepper("Cantidad", value: $movimiento.acciones).labelsHidden()
                        Spacer()
                        TextField("Cantidad", value: $movimiento.acciones, formatter: NumberFormatter())
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .frame(minWidth: 35, maxWidth: 80)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                    
                    ZStack(alignment: .trailing) {
                        Text("Precio $")
                        TextField("", text: $movimiento.precio)
                            .keyboardType(.numberPad)
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
                        updateMovimiento(movimiento: movimiento)

                    }, label: {
                        HStack {
                            Spacer()
                            Text("Actualizar")
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
                    
                
            }
            .padding()
            .navigationTitle("Editar Movimiento")
            .navigationBarTitleDisplayMode(.inline)
        }.task {
            await loadDataEmpresas()
        }
    }
}
