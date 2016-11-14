 //
// Created by Zachery Eldemire on 10/31/16.
// Copyright (c) 2016 cse.miamioh. All rights reserved.
//

import Foundation

class Investigation {
    var title: String
    var category: String
    var question: String
    var components: [Component]
    var date: Date
    var timer: Foundation.NSTimer?

    init(question: String, components: [Component], title: String, category: String) {
        self.components = components
        self.question = question
        self.date = Date()
        self.title = title
        self.category = category
    }

    var lastUpdated: String {
        get {
            let format: String
            let now = Date().timeIntervalSince1970 * 1000
            switch now - date.timeIntervalSince1970 * 1000 {
            case 0 ..< 72000000: format = "h:mm a"
            case 72000000 ..< 432000000: format = "EEEE"
            case 432000000 ..< 12000000000: format = "M/d"
            default: format = "MMM 'yy"
            }
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
    }
}
 
class Investigations {
    static let instance = Investigations()
    var investigations = [Investigation]()
    var categories = NSMutableOrderedSet()
    
    /// Adds investigation and category
    func addInvestigation(investigation: Investigation) {
        investigations.append(investigation)
        categories.add(investigation.category)
    }
}

