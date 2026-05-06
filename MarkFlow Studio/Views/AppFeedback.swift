//
//  AppFeedback.swift
//  MarkFlow Studio
//

import Foundation

struct AppFeedback: Identifiable, Equatable {
    enum Kind {
        case info
        case success
        case warning
        case error
    }

    let id = UUID()
    let message: String
    let kind: Kind
}
