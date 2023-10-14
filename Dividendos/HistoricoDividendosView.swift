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
    @State var logo: String
    @Environment (\.presentationMode) var presentationMode
    
//    func getCagr() -> [DesgloseBar] {
//        let divs = getDesgloseDividendosAnual(dividendos: dividendos)
//        divs.max(by: {
//            $0.date < $1.date
//        })
//        print(divs)
//        return divs
//    }
    
    var body: some View {
        Button("Volver", action: {
            self.presentationMode.wrappedValue.dismiss()
        })
        Divider()
        Text("Histórico Dividendos").bold()
        Chart(getDesgloseDividendosAnual(dividendos: dividendos)) { data in
            BarMark(x: .value("Fecha", data.date, unit: .year),
                    y: .value("Dividendo", data.count))
            .annotation(position: .top, alignment: .center) {
                Text("\(String(format: "%.1f", data.count))")
                    .font(.system(size: 8))
            }
                .foregroundStyle(.yellow)
        }
        .chartXAxis {
                AxisMarks(values: .stride(by: .year)) { day in
                    AxisValueLabel(format: .dateTime.year(.twoDigits)).font(.system(size: 8))
                    AxisTick()
                    AxisGridLine()
                }
        }
        .frame(width: 355, height: 200)
            .chartBackground { proxy in
                LogoView(logo: logo).padding(10).offset(x: -130, y: -70)
                Text("CAGR 5 años: 7,40%")
                    .font(.footnote)
                    .bold()
                    .offset(x: -95, y: -35)
            }
    }
}
