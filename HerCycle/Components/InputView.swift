//
//  InputView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    var tittle: String
    var plaseholder: String
    var isSecureField = false
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(tittle)
                .bold()
                .font(.footnote)
            
            if isSecureField {
                SecureField(plaseholder, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(plaseholder, text: $text)
                    .font(.system(size: 14))
            }
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), tittle: "Email edres", plaseholder: "...@gmail.com")
}

