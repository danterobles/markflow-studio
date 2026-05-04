//
//  AppFeedback.swift
//  MarkFlow Studio
//

import Foundation

struct AppFeedback: Identifiable, Equatable {
    enum Kind {
        case success
        case error
    }

    let id = UUID()
    let message: String
    let kind: Kind
}
