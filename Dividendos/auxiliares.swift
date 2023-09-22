//
//  auxiliares.swift
//  Dividendos
//
//  Created by juancarlos on 11/8/23.
//

import Foundation
import SwiftUI

func getDate(fecha: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+02:00"
    return dateFormatter.date(from: fecha)
}

func getDateBinding(fecha: String) -> Binding<Date>? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+02:00"
    return Binding(get: {dateFormatter.date(from: fecha)!},
                   set: {_ in dateFormatter.date(from: fecha)
                    })
}

func getStringFromBinding(dato: Binding<Double>) -> String? {
    return String("\(dato.wrappedValue)")
}

func getDateShort(fecha: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: fecha)
}

func getDateOnlyYear(fecha: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.date(from: fecha)
}

func convertDateToString(date: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+02:00"
    return dateFormatter.string(from: date)
}

func getCoste(acciones: Double, precio: String) -> Double? {
    return acciones*Double(precio)!
}

func getYearsDividend(year: Int) -> Int {
    let currentYear = Calendar.current.component(.year, from: Date())
    return currentYear - year
}

func findPosicionesSymbol(posiciones: [Posicion], symbol: String) -> Double {
    let amount = posiciones.first{$0.empresa.symbol == symbol}
    //print("eee", amount as Any)
    return Double(amount!.cantidad)
}

func getDesglosePorPaises(posiciones: [Posicion]) -> [Desglose] {
    let eeuu = posiciones.reduce(0, { result, info in
        if (info.empresa.pais == "eeuu") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    let uk = posiciones.reduce(0, { result, info in
        if (info.empresa.pais == "uk") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    let spain = posiciones.reduce(0, { result, info in
        if (info.empresa.pais == "spain") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    let otros = posiciones.reduce(0, { result, info in
        if (info.empresa.pais == "otros") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    return [ Desglose(name: "EEUU", count: eeuu), Desglose(name: "UK", count: uk),
             Desglose(name: "ES", count: spain), Desglose(name: "Otros", count: otros)]
}

func getDesglosePorSectores(posiciones: [Posicion]) -> [Desglose] {
    let defensivo = posiciones.reduce(0, { result, info in
        if (info.empresa.sector == "ConsumoDef") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    let industrial = posiciones.reduce(0, { result, info in
        if (info.empresa.sector == "industrial") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    let tecnologia = posiciones.reduce(0, { result, info in
        if (info.empresa.sector == "tecno") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    let salud = posiciones.reduce(0, { result, info in
        if (info.empresa.sector == "salud") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    let consumoCic = posiciones.reduce(0, { result, info in
        if (info.empresa.sector == "consumoCic") {
            return result + (Double(info.cantidad)*info.pmc)
        } else { return result }
    })
    return [ Desglose(name: "Defensivo", count: defensivo), Desglose(name: "Industrial", count: industrial),
    Desglose(name: "Tecnología", count: tecnologia), Desglose(name: "Salud", count: salud), Desglose(name: "Cíclico", count: consumoCic)]
}

func getActivosInmo(viviendas: [Vivienda]) -> [Desglose] {
    var desgloses:[Desglose] = []
    viviendas.forEach {
        desgloses.append(Desglose(name: $0.direccion, count: $0.valor_cv))
    }
    return desgloses
}

func getDividendosMes(mes: Int, dividendos: [Dividendo]) -> Double {
    let yearMonth = DateComponents(month: mes)
    return dividendos.reduce(0, {
        Calendar.current.dateComponents([.month], from: getDateShort(fecha: $1.payable_date)!) == yearMonth ? $0 + $1.dividendo : $0
    })
}

func getDesgloseDividendosMensual(dividendos: [Dividendo]) -> [DesgloseBar] {
    var desgloses:[DesgloseBar] = []
    for i in 1...12 {
        desgloses.append(DesgloseBar(id: i, date: Calendar.current.date(from: DateComponents(month: i))!, count: getDividendosMes(mes: i, dividendos: dividendos)))
    }
    //print(desgloses)
    return desgloses
}

func getDesgloseRentas(rentas: [Renta]) -> [Desglose] {
    print("eee", rentas.count)
    var desgloses:[Desglose] = []
    let rents = rentas.reduce(0, { result, info in
        if (info.tipo == "Viviendas") {
            return result + Double(info.cantidad)
        } else { return result }
    })
    let divs = rentas.reduce(0, { result, info in
        if (info.tipo == "Dividendos") {
            return result + Double(info.cantidad)
        } else { return result }
    })
    desgloses.append(Desglose(name: "Viviendas", count: rents))
    desgloses.append(Desglose(name: "Dividendos", count: divs))
    return desgloses
}

func getEmpresa(symbol: String) async -> Empresa {
    var empresa = Empresa(id: 1, nombre: "", logo: "", cabecera: "", isin: "", estrategia: "", pais: "", sector: "", symbol: "", description: "", dividendo_desde: "", tipo: "", pub_date: "")
    
    guard let url = URL(string: "https://hamperblock.com/django/empresas/?symbol=" + symbol ) else {
        print("Invalid URL")
        return empresa
    }
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let decodedResponse = try? JSONDecoder().decode([Empresa].self, from: data) {
            empresa = decodedResponse[0]
        }
    } catch {
        print("ERROR: No hay datos")
    }
    return empresa
}
