//
//  ContratosView.swift
//  Dividendos
//
//  Created by juancarlos on 27/8/23.
//

import SwiftUI

struct ContratosView: View {
    
    @State var contratos = [Contrato]()

    func loadDataContratos() async {
        guard let url = URL(string: "https://hamperblock.com/django/contratos/" ) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Contrato].self, from: data) {
                contratos = decodedResponse
                print("hay \(contratos.count) contratos")
            }
        } catch {
            print("ERROR: No hay contratos")
        }
    }
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(contratos, id: \.self) { contrato in
                    HStack{
                        VStack(alignment:.leading) {
                            Text(contrato.vivienda.direccion).bold()
                            Text("Alquiler: \(String(format: "%.2f", contrato.importe_mes))€")
                            Text("\(contrato.fecha_desde) - \(contrato.fecha_hasta)").font(.footnote)
                        }
                        Spacer()
                        VStack{
                            Image(systemName: contrato.alquilado ? "signature" : "")
                                .foregroundColor(.green)
                                .font(.system(size: 50))
                            Text(contrato.nif).font(.footnote)
                            
                        }
                    }
                    }
                
            }
            .navigationTitle("Contratos")
            .task {
                await loadDataContratos()
            }
        }
    }
}

#Preview {
    ContratosView()
}
