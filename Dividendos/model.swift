//
//  model.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 19/6/23.
//

import Foundation

struct Request: Codable {
    let status: String
    let data: String
}

struct LoginResponse: Codable {
    var access_token: String
    var user: UserShor
}

struct UserShor: Codable {
    var id: Int
    var username: String
    var email: String
//    let groups: [Any]
}

struct Desglose {
    var name: String
    var count: Double
}

struct DesgloseBar: Identifiable {
    var id: Int    
    var date: Date
    var count: Double
}

struct Response: Codable {
    var results: [Result]
}

struct ResponseMov: Codable {
    var results: [Movimiento]
}

struct ResponsePos: Codable {
    var results: [Posicion]
}

struct ResponseCar: Codable {
    var results: [Cartera]
}

struct ResponseDiv: Codable {
    var results: [Dividendo]
}

struct ResponseViv: Codable {
    var results: [Vivienda]
}

struct ResponseRent: Codable {
    var results: [Renta]
}

struct ResponseHistorico: Codable {
    var results: [HistoricoEmpresa]
}

struct HistoricoEmpresa: Codable, Identifiable {
    var id: Int
    var empresa: Int
    var fiscalDateEnding: String
    var reportedEPS: Double
    var totalRevenue: Double
    var grossProfit: Double
    var netIncome: Double
    var ebitda: Double
    var costOfRevenue: Double
    var interests: Double
    var commonStockSharesOutstanding: Double
    var totalCurrentAssets: Double
    var totalNonCurrentAssets: Double
    var totalCurrentLiabilities: Double
    var totalNonCurrentLiabilities: Double
    var shortTermDebt: Double
    var longTermDebt: Double
    var dividendPayout: Double
    var paymentsForRepurchaseOfCommonStock: Double
    var capitalExpenditures: Double
    var operatingCashflow: Double
    
    
//                "dividendPayout": 7252000000.0,

//                "dandp": 165000000,
//                "tax": 2621000000,
    
//                "totalCurrentAssets": 22545000000,
//                "totalNonCurrentAssets": 73209000000,
//                "totalCurrentLiabilities": 19950000000,
//                "totalNonCurrentLiabilities": 50719000000,
//                "shortTermDebt": 3307000000,
//                "longTermDebt": 39454000000,
    
//                "operatingCashflow": 12625000000,
//                "cashflowFromInvestment": -2765000000,
//                "cashflowFromFinancing": -6786000000,
//                "capitalExpenditures": 1367000000,
//                "paymentsForRepurchaseOfCommonStock": 111000000,
}

struct Result: Codable {
    var id: Int
    var captura: String
    var descripcion: String
    let empresa: Empresa
    let tags: String
    let fecha: String
}

struct Cartera: Codable, Hashable {
    var id: Int
    var nombre: String
    var capital_inicial: String
    var user: User?
}

struct User: Codable, Hashable {
    var id: Int
    var password: String
//    let last_login: String
//    let is_superuser: Bool
    var username: String
    var first_name: String
    var last_name: String
    var email: String
//    let is_staff: Bool
//    let is_active: Bool
//    let date_joined: String
//    let groups: [Any]
//    let user_permissions: [Any]
    
}

struct Posicion: Codable, Identifiable {
    var id: Int
    var cartera: Cartera
    var empresa: Empresa
    var cantidad: Int
    var pmc: Double
}

struct Movimiento: Codable {
    var id: Int
    var tipo: String
    var acciones: Double
    var total_acciones: Double
    var precio: String
    var moneda: String
    var empresa: Empresa
    var cartera: Cartera
    var comision: String
    var cambio_moneda: String
    var fecha: String

}

struct Empresa: Codable, Hashable {
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
    let cagr5: Double
    
    func getString() {
        print( "Name: \(nombre), Id: \(id), logo: \(logo), est: \(estrategia), pub_date: \(pub_date) ")
    }
}

struct FundamentalesEmpresa: Codable {
    var id: Int
    var fiscalDateEnding: String
    var num_acciones: Double
    var markercap: Double
    var ebitda: Double
    var per: Double
    var beta: Double
    var dpa: Double
    var bpa: Double
    var dya: Double
    var WeekHighYear: Double
    var WeekLowYear: Double
    var DayMovingAverage50: Double
    var DayMovingAverage200: Double
}

struct Profit: Codable, Identifiable {
    let id: Int
    let cartera: Cartera
    let fecha: String
    let valor: Double
    let profit: Double
    let balance: Double
    let dividendos: Double
    let aportado_total: Double
}

struct Dividendo: Codable, Identifiable, Hashable {
    let id: Int
    let date: String
    let dividendo: Double
    let ex_dividend: String
    let payable_date: String
    let frequency: Double
    let tipo: String
    let empresa: Empresa
    
    init(id: Int, date: String, dividendo: Double, ex_dividend: String, payable_date: String, frequency: Double, tipo: String, empresa: Empresa) {
        self.id = id
        self.date = date
        self.dividendo = dividendo
        self.ex_dividend = ex_dividend
        self.payable_date = payable_date
        self.frequency = frequency
        self.tipo = tipo
        self.empresa = empresa
    }
}

struct Vivienda: Codable, Hashable {
    let id: Int
    let cartera: Cartera
    let tipo: String
    let direccion: String
    let comunidad: String
    let valor_cv: Double
    let gastos_cv: Double
    let gastos_reforma: Double
    let ingresos_mensuales: Double
    let gastos_ibi: Double
    let gastos_seguros: Double
    let gastos_comunidad: Double
    let financiacion: Bool;
    let pct_finan: Double?
    let plazo: Double?
    let interes: Double?
    let itp: Double?
    let total_compra: Double?
    let gastos_anuales: Double?
    let rent_bruta: Double?
    let rent_neta: Double?
    let valor_hipoteca: Double?
    let capital_aportar: Double?
    let cuota_hipoteca_mes: Double?
    let cash_flow: Double?
    let roce: Double?
    
    init(id: Int, cartera: Cartera, tipo: String, direccion: String, comunidad: String, valor_cv: Double, gastos_cv: Double, gastos_reforma: Double, ingresos_mensuales: Double, gastos_ibi: Double, gastos_seguros: Double, gastos_comunidad: Double, financiacion: Bool, pct_finan: Double?, plazo: Double?, interes: Double?, itp: Double?, total_compra: Double?, gastos_anuales: Double?, rent_bruta: Double?, rent_neta: Double?, valor_hipoteca: Double?, capital_aportar: Double?, cuota_hipoteca_mes: Double?, cash_flow: Double?, roce: Double?) {
        self.id = id
        self.cartera = cartera
        self.tipo = tipo
        self.direccion = direccion
        self.comunidad = comunidad
        self.valor_cv = valor_cv
        self.gastos_cv = gastos_cv
        self.gastos_reforma = gastos_reforma
        self.ingresos_mensuales = ingresos_mensuales
        self.gastos_ibi = gastos_ibi
        self.gastos_seguros = gastos_seguros
        self.gastos_comunidad = gastos_comunidad
        self.financiacion = financiacion
        self.pct_finan = pct_finan
        self.plazo = plazo
        self.interes = interes
        self.itp = itp
        self.total_compra = total_compra
        self.gastos_anuales = gastos_anuales
        self.rent_bruta = rent_bruta
        self.rent_neta = rent_neta
        self.valor_hipoteca = valor_hipoteca
        self.capital_aportar = capital_aportar
        self.cuota_hipoteca_mes = cuota_hipoteca_mes
        self.cash_flow = cash_flow
        self.roce = roce
    }
    
}

struct Renta: Codable, Hashable, Identifiable {
    let id: Int
    let cartera: Cartera
    let tipo: String
    let fecha_cobro: String
    let cantidad: Double
    let pagada: Bool
    //let vivienda: Vivienda? revisar esto crear nuevo modelo Alquiler
}

struct Contrato: Codable, Hashable {
    let id: Int
    let nif: String
    let vivienda: Vivienda
    let fecha_desde: String
    let fecha_hasta: String
    let importe_mes: Double
    let alquilado: Bool
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

struct modelo720 {
    let dni: String
    let text: String
    let status: String
    let ib_country: String
    let degiro_country: String
    let eurusd: String
    let filename: String
    let filenameDegiro: String
    let active_page: Double
    let modalShow: Bool
    let name: String
    //let forex: { [name: String]: forex }
    let participation: Double
    let declarant_condition: Double
    
    init(dni: String, text: String, ib_country: String, degiro_country: String, eurusd: String, filename: String, filenameDegiro: String, active_page: Double, modalShow: Bool, name: String, declarant_condition: Double) {
        self.dni = dni
        self.text = text
        self.status = "dark"
        self.ib_country = ib_country
        self.degiro_country = degiro_country
        self.eurusd = eurusd
        self.filename = filename
        self.filenameDegiro = filenameDegiro
        self.active_page = 1
        self.modalShow = modalShow
        self.name = name
        self.participation = 100
        self.declarant_condition = declarant_condition
    }
}

//struct EmpresasDataModel: Decodable {
//    let empresas: [Empresa]
//
//    init(from decoder: Decoder) throws {
//        self.empresas = try decoder.container(keyedBy: Empresa.self)
//    }
//}
