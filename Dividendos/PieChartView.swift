//
//  PieChartView.swift
//  Dividendos
//
//  Created by juancarlos on 15/8/23.
//

import SwiftUI
import Charts

@available(iOS 17.0, *)
struct PieChartView: View {
    
    @State var posiciones = [Posicion]()
    
//    private var coffeeSales = [
//        (name: "Americano", count: 120),
//        (name: "Cappuccino", count: 234),
//        (name: "Espresso", count: 62),
//        (name: "Latte", count: 625),
//        (name: "Mocha", count: 320),
//        (name: "Affogato", count: 50)
//    ]
    
    var body: some View {
        Chart(posiciones, id: \.id) { data in
            SectorMark(
                angle: .value("Ventas", Double(data.cantidad))
            )
            .foregroundStyle(by: .value("Empresa", data.symbol))
        }.padding()
        
//        Chart (coffeeSales, id: \.name) { data in
//            BarMark(
//                x: .value("Cup", data.count)
//            )
//            .foregroundStyle(by: .value("Type", data.name))
//        }
        
    }
}

#Preview {
    PieChartView()
}
