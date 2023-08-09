//
//  services.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 19/6/23.
//

import Foundation

final class ViewModel: ObservableObject {

    @Published var empresas: [Empresa] = []
    @Published var analisis: [AnalisisEmpresa] = []
    
    func executeAPI(){
        let urlSession = URLSession.shared
        let url = URL(string: "https://hamperblock.com/django/empresas")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //let token = ""

        urlSession.dataTask(with: request) { [self] data, response, error in
            //print("Data \(String(describing: data))")
            //print("Response \(String(describing: response))")
            //print("Error \(String(describing: error))")
            if let data = data {
                _ = try? JSONSerialization.jsonObject(with: data)
                //print(String(describing: json))
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if  let object = json as? [Any] {
                        for anItem in object as! [Dictionary<String, AnyObject>] {
                            let nombre = anItem["nombre"] as! String
                            let logo = anItem["logo"] as! String
                            let id = anItem["id"] as! Int
                            let isin = anItem["isin"] as! String
                            let estrategia = anItem["estrategia"] as! String
                            let pais = anItem["pais"] as! String
                            let sector = anItem["sector"] as! String
                            let symbol = anItem["symbol"] as! String
                            let description = anItem["description"] as! String
                            let pub_date = anItem["pub_date"] as! String
                            let dividendo_desde = anItem["dividendo_desde"] as! String
                            let tipo = anItem["tipo"] as! String
                            let empresa = Empresa(id: id, nombre: nombre, logo: logo, isin: isin, estrategia: estrategia, pais: pais, sector: sector, symbol: symbol, description: description, dividendo_desde: dividendo_desde, tipo: tipo, pub_date: pub_date)
                            DispatchQueue.main.async {
                                if (empresa.estrategia == "Dividendos") {
                                    self.empresas.append(empresa)
                                }
                            }
//                            self.empresas = empresa
//                            self.empresas.getString()
                                }
                            }
                        } catch {
                            print(error)
                        }
            }
        }.resume()
    }

    
    func getAnalisis(symbol: String){
        let urlSession = URLSession.shared
        let url = URL(string: "https://hamperblock.com/django/analisis/?symbol=" + symbol )!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        urlSession.dataTask(with: request) { [self] data, response, error in
            if let data = data {
                _ = try? JSONSerialization.jsonObject(with: data)
                //print(String(describing: json))
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(String(describing: json))
                    if  let object = json as? [Any] {
                        for anItem in object as! [Dictionary<String, AnyObject>] {
                            let captura = anItem["captura"] as! String
                            let descripcion = anItem["descripcion"] as! String
                            let empresa = anItem ["empresa"] as! Empresa
                            let objetivo = anItem["objetivo"] as! String
                            let id = anItem["id"] as! Int
                            let tags = anItem["tags"] as! String
                            let fecha = anItem["fecha"] as! String
                            let analisis_empresa = AnalisisEmpresa(id: id, captura: captura, descripcion: descripcion, empresa: empresa, objetivo: objetivo, tags: tags, fecha: fecha)
                            DispatchQueue.main.async {
                                self.analisis.append(analisis_empresa)
                            }
                                }
                            }
                        } catch {
                            print(error)
                        }
            }
        }.resume()
    }
}


