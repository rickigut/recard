//
//  Item.swift
//  New_Recard
//
//  Created by Ricki Darmawan Putra on 18/04/26.
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
