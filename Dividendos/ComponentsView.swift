//
//  ComponentsView.swift
//  Dividendos
//
//  Created by juancarlos on 1/9/23.
//

import SwiftUI

struct LogoView: View {
    var logo: String
    var body: some View {
        AsyncImage(url: URL(string: "https://logo.clearbit.com/\(logo).com")) { image in
            image
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
            
        } placeholder: {
            Color.gray
        }
        .frame(width: 45, height: 45)
    }
}

#Preview {
    LogoView(logo: "")
}
