import Foundation
import SwiftData

@Model
public final class EventItem {
    public var title: String
    public var date: Date
    public var startTime: String?
    public var endTime: String?
    public var recurrence: String?  // "daily", "weekly", "monthly", or nil
    public var notes: String
    public var createdAt: Date

    public init(title: String, date: Date, startTime: String? = nil, endTime: String? = nil,
                recurrence: String? = nil, notes: String = "") {
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.recurrence = recurrence
        self.notes = notes
        self.createdAt = Date()
    }
}
