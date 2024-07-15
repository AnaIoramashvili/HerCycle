//
//  CalendarHostingController.swift
//  HerCycle
//
//  Created by Ana on 7/15/24.
//

import SwiftUI

class CalendarHostingController: UIHostingController<CalendarView> {
    var onPreviousMonth: () -> Void = {}
    var onNextMonth: () -> Void = {}
    var onDaySelected: (Date) -> Void = { _ in }

    init(selectedDate: Binding<Date>, markedDays: Binding<[Date: PeriodType]>, selectedPeriodType: Binding<PeriodType?>) {
        let rootView = CalendarView(
            selectedDate: selectedDate,
            markedDays: markedDays,
            selectedPeriodType: selectedPeriodType,
            onPreviousMonth: {},
            onNextMonth: {},
            onDaySelected: { _ in }
        )
        super.init(rootView: rootView)
        
        self.rootView.onPreviousMonth = { [weak self] in self?.onPreviousMonth() }
        self.rootView.onNextMonth = { [weak self] in self?.onNextMonth() }
        self.rootView.onDaySelected = { [weak self] date in self?.onDaySelected(date) }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
