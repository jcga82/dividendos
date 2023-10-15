//
//  HistoricoEmpresaView.swift
//  Dividendos
//
//  Created by juancarlos on 13/10/23.
//

import SwiftUI
import Charts


struct HistoricoEmpresaView: View {
    @Binding var historico: [HistoricoEmpresa]
    @State var logo: String
    @Environment (\.presentationMode) var presentationMode
    
    func getLastHistorico() -> HistoricoEmpresa {
        return historico.sorted(by: { (($0.fiscalDateEnding).compare($1.fiscalDateEnding)) == .orderedDescending })[0]
    }
    
    func getLastYear() -> String {
        return getLastHistorico().fiscalDateEnding
    }
    
    func getTotalBalance() -> [(name: String, count: Double)] {
        let hist: HistoricoEmpresa = historico.filter({$0.fiscalDateEnding.prefix(4) == getLastYear().prefix(4)})[0]
        return [
            (name: "Activo C", count: hist.totalCurrentAssets/1000000),
            (name: "Activo NC", count: hist.totalNonCurrentAssets/1000000),
            (name: "Pasivo C", count: hist.totalCurrentLiabilities/1000000),
            (name: "Pasivo NC", count: hist.totalNonCurrentLiabilities/1000000),
            (name: "PN", count: (hist.totalCurrentAssets + hist.totalNonCurrentAssets-hist.totalCurrentLiabilities-hist.totalNonCurrentLiabilities)/1000000),
        ]
    }
    
    func getDesgloseCashFlow() -> [Desglose] {
        let hist: HistoricoEmpresa = historico.filter({$0.fiscalDateEnding.prefix(4) == getLastYear().prefix(4)})[0]
        return [ Desglose(name: "Dividendos", count: hist.dividendPayout),
                 Desglose(name: "Recompras", count: hist.paymentsForRepurchaseOfCommonStock),
                 Desglose(name: "CAPEX", count: hist.capitalExpenditures),
//                 Desglose(name: "Otros", count: otros)
        ]
    }
    
    var body: some View {
        Button("Volver", action: {
            self.presentationMode.wrappedValue.dismiss()
        })
        VStack {
            Text("Cuenta Resultados (\(historico.count) últimos años)").bold()
            Chart(historico ) { data in
                BarMark(
                    x: .value("Fecha", Calendar.current.date(from: DateComponents(year: Int(data.fiscalDateEnding.prefix(4))))!, unit: .year),
                    y: .value("Ventas", (data.totalRevenue - data.grossProfit)/1000000)
                )
                .foregroundStyle(by: .value("Value", "Ventas"))
                .annotation(position: .overlay, alignment: .center) {
                    Text("\(String(format: "%.0f", data.totalRevenue/1000000000))B$").font(.footnote)
                }
                BarMark(
                    x: .value("Fecha", Calendar.current.date(from: DateComponents(year: Int(data.fiscalDateEnding.prefix(4))))!, unit: .year),
                    y: .value("netIncome", data.netIncome/1000000)
                )
                .foregroundStyle(by: .value("Value", "Beneficio Neto"))
                .annotation(position: .overlay, alignment: .center) {
//                    Text("\(String(format: "%.0f", data.totalRevenue/1000000))").font(.footnote)
                    Text("BPA \(String(format: "%.2f", data.netIncome/data.commonStockSharesOutstanding))").font(.system(size: 9))
                }
                BarMark(
                    x: .value("Fecha", Calendar.current.date(from: DateComponents(year: Int(data.fiscalDateEnding.prefix(4))))!, unit: .year),
                    y: .value("grossProfit", (data.grossProfit - data.netIncome)/1000000)
                )
                .foregroundStyle(by: .value("Value", "Benef. Bruto"))
                .annotation(position: .top, alignment: .center) {
                    Text("M.Bruto \(String(format: "%.1f", data.grossProfit*100/data.totalRevenue)) %").font(.system(size: 9))
                }
            }
            .frame(width: 350, height: 250)
            
            Text("Balance \(getLastYear())").bold()
            Chart(getTotalBalance(), id: \.name) { data in
                SectorMark(
                angle: .value("Balance", data.count),
                    innerRadius: .ratio(0.55),
                    angularInset: 2.0
                )
                .foregroundStyle(by: .value("Type", data.name))
                //.foregroundStyle(by: .value("Empresa", "\(data.totalCurrentAssets): \(String(format: "%.0f",data.totalCurrentAssets))$"))
                .annotation(position: .overlay) {
                    Text("\(String(format: "%.0f", data.count/1000))B$")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            }.frame(height: 200).padding()
            .chartBackground { proxy in
                Text("💰").font(.system(size: 40))
            }
            
            Text("Cash Flow \(getLastYear())").bold()
            Text("FCF: \(String(format: "%.0f",(getLastHistorico().operatingCashflow - getLastHistorico().capitalExpenditures)/1000000)) M$").font(.footnote)
            Chart (getDesgloseCashFlow(), id: \.name) { data in
                BarMark(
                    x: .value("CashFlow", data.count/1000000)
                )
                .foregroundStyle(by: .value("CashFlow", "\(data.name): \(String(format: "%.0f",data.count/1000000)) M$"))
            }.frame(height: 60).padding()
            Text("Total: \(String(format: "%.0f",getLastHistorico().commonStockSharesOutstanding/1000000)) Mill.acc - Payout: \(String(format: "%.1f", (getLastHistorico().dividendPayout*100/getLastHistorico().netIncome))) %").bold().font(.footnote)
            

        
        }
    }
}
