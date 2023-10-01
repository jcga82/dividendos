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
    @Environment (\.presentationMode) var presentationMode
    
    var body: some View {
        Button("Volver", action: {
            self.presentationMode.wrappedValue.dismiss()
        })
        
        Chart(getDesgloseDividendosAnual(dividendos: dividendos)) { data in
            BarMark(x: .value("Fecha", data.date, unit: .year),
                    y: .value("Dividendo", data.count))
            .annotation(position: .top, alignment: .center) {
                Text("\(String(format: "%.1f", data.count))")
                    .font(.system(size: 8))
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
