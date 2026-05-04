//
//  Item.swift
//  MarkFlow Studio
//
//  Created by Dante Robles on 04/05/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
