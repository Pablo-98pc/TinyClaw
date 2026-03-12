import Foundation
import SwiftData
import TinyClawCore

public enum MessageRole: String, Codable {
    case user
    case assistant
}

@Model
public final class Message {
    public var role: MessageRole
    public var content: String
    public var specialistBadge: String?  // "chat", "summarize", "task", "event"
    public var isVoiceInput: Bool
    public var timestamp: Date

    public init(role: MessageRole, content: String, specialistBadge: String? = nil,
                isVoiceInput: Bool = false) {
        self.role = role
        self.content = content
        self.specialistBadge = specialistBadge
        self.isVoiceInput = isVoiceInput
        self.timestamp = Date()
    }
}
