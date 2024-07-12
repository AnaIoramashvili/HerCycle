//
//  LoadingView.swift
//  HerCycle
//
//  Created by Ana on 7/11/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Loading...")
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingView()
}
