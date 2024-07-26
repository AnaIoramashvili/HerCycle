//
//  CalendarHostingController.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import SwiftUI

class CalendarHostingController: UIHostingController<AnyView> {
    init(authViewModel: AuthViewModel) {
        let rootView = AnyView(CalendarView(authViewModel: authViewModel).environmentObject(authViewModel))
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
