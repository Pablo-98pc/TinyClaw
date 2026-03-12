import Foundation

/// Intent categories classified by the dispatcher.
/// Each intent maps to a specialist or action.
public enum Intent: String, CaseIterable, Codable {
    case chat
    case summarize
    case task
    case event
}
