//
//  model.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 19/6/23.
//

import Foundation

struct Response: Codable {
    var results: [Result]
}

struct ResponseMov: Codable {
    var results: [Movimiento]
}

struct Result: Codable {
    var id: Int
    var captura: String
    var descripcion: String
    let empresa: Empresa
    let tags: String
    let fecha: String
}

struct Cartera: Codable {
    let id: Int
    var nombre: String
    var capital_inicial: String
}

struct Movimiento: Codable {
    let id: Int
    let tipo: String
    let acciones: Double
    let total_acciones: Double
    let precio: String
    let moneda: String
    let empresa: Empresa
    let cartera: Cartera
    let comision: String
    let cambio_moneda: String
    let fecha: String
}

struct Empresa: Codable {
    let id: Int
    let nombre: String
    let logo: String
    let cabecera: String
    let isin: String
    let estrategia: String
    let pais: String
    let sector: String
    let symbol: String
    let description: String
    let dividendo_desde: String
    let tipo: String
    let pub_date: String
    
    func getString() {
        print( "Name: \(nombre), Id: \(id), logo: \(logo), est: \(estrategia), pub_date: \(pub_date) ")
    }
}

struct AnalisisEmpresa: Decodable {
    let id: Int
    let captura: String
    let descripcion: String
    let empresa: Empresa
    let objetivo: String
    let tags: String
    let fecha: String
    
    init(id: Int, captura: String, descripcion: String, empresa: Empresa, objetivo: String, tags: String, fecha: String) {
        self.id = id
        self.captura = captura
        self.descripcion = descripcion
        self.empresa = empresa
        self.objetivo = objetivo
        self.tags = tags
        self.fecha = fecha
    }
    
    func getString() {
        print( "Id: \(id), captura: \(captura), descripcion: \(descripcion), fecha: \(fecha) ")
    }
}

//struct EmpresasDataModel: Decodable {
//    let empresas: [Empresa]
//
//    init(from decoder: Decoder) throws {
//        self.empresas = try decoder.container(keyedBy: Empresa.self)
//    }
//}
