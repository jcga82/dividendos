//
//  HistoricoDividendosView.swift
//  Dividendos
//
//  Created by Juan Carlos García Abril on 22/9/23.
//

import SwiftUI
import Charts


struct HistoricoDividendosView: View {
    
    @Binding var dividendos: [Dividendo]
    
    func getDividendosAnuales(dividendos: [Dividendo]) -> Double {
        return dividendos.reduce(0, {
            let year = DateComponents(year: Int($1.date))
            return Calendar.current.dateComponents([.year], from: getDateShort(fecha: $1.payable_date)!) == year ? $0 + $1.dividendo : $0
        })
    }
    
    func getDesgloseDividendosAnual(dividendos: [Dividendo]) -> [DesgloseBar] {
        var desgloses:[DesgloseBar] = []
        for dividendo in dividendos {
            desgloses.append(DesgloseBar(id: dividendo.id, date: Calendar.current.date(from: DateComponents(year: Int(dividendo.payable_date)))!, count: getDividendosAnuales(dividendos: dividendos)))
        }
        print(desgloses)
        return desgloses
    }
    
    var body: some View {
        Chart(getDesgloseDividendosAnual(dividendos: dividendos)) { data in
            BarMark(x: .value("Fecha", data.date, unit: .year),
                    y: .value("Dividendo", data.count))
            .annotation(position: .top, alignment: .center) {
                Text("\(String(format: "%.0f", data.count))")
                    .font(.system(size: 10))
            }
                .foregroundStyle(.yellow)
//            RuleMark(y: .value("Media", getDiv()/12))
//                .foregroundStyle(.gray)
//                .annotation(position: .top, alignment: .leading) {
//                    Label("\(Int(getDiv()/12))", systemImage: "flag.checkered")
//                        .foregroundColor(.gray)
//                        .font(.footnote)
//                        .bold()
//                }
        }.frame(width: 350, height: 200)
    }
}
