//
//  OnboardingPage.swift
//  HerCycle
//
//  Created by Ana on 7/23/24.
//

import Foundation

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
}

struct OnboardingModel {
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Accurate Predictions", subtitle: "Our expert-backed algorithms bring you accurate menstrual cycle predictions.", imageName: "Period1"),
        OnboardingPage(title: "Cycle Harmony", subtitle: "Based on your inputs and data, you'll have guidance and knowledge relevant to your unique patterns.", imageName: "Period2"),
        OnboardingPage(title: "Keep track of your period", subtitle: "Easily and accurately track each phase of your menstrual cycle.", imageName: "")
    ]
}
