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
