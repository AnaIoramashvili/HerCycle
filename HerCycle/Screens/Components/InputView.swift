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
    @State private var isSecureTextVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(tittle)
                .bold()
                .font(.footnote)
            
            if isSecureField {
                HStack {
                    Group {
                        if isSecureTextVisible {
                            TextField(plaseholder, text: $text)
                        } else {
                            SecureField(plaseholder, text: $text)
                        }
                    }
                    .font(.system(size: 14))
                    
                    Button(action: {
                        isSecureTextVisible.toggle()
                    }) {
                        Image(systemName: isSecureTextVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.color6)
                    }
                }
            } else {
                TextField(plaseholder, text: $text)
                    .font(.system(size: 14))
            }
            Divider()
        }
    }
}

#Preview {
    VStack {
        InputView(text: .constant(""), tittle: "Email address", plaseholder: "...@gmail.com")
        InputView(text: .constant(""), tittle: "Password", plaseholder: "Enter your password", isSecureField: true)
    }
    .padding()
}
