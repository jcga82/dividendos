//
//  auxiliares.swift
//  Dividendos
//
//  Created by juancarlos on 11/8/23.
//

import Foundation

func getDate(fecha: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+02:00"
    return dateFormatter.date(from: fecha)
}

func getDateShort(fecha: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: fecha)
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
    print("eee", amount as Any)
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

func getDesgloseRentas(rentas: [Renta]) -> [Desglose] {
    var desgloses:[Desglose] = []
    rentas.forEach {
        desgloses.append(Desglose(name: $0.tipo, count: $0.cantidad))
    }
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
