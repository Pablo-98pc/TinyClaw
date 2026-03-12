import Foundation
import SwiftData

@Model
public final class TaskItem {
    public var title: String
    public var dueDate: Date?
    public var isCompleted: Bool
    public var notes: String
    public var createdAt: Date

    public init(title: String, dueDate: Date? = nil, notes: String = "") {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = false
        self.notes = notes
        self.createdAt = Date()
    }
}
