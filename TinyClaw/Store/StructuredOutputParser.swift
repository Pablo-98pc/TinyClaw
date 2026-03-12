import Foundation

/// Result of parsing structured output from the chat model.
public enum ParsedOutput {
    case task(title: String, dueDate: Date?, notes: String)
    case event(title: String, date: Date?, startTime: String?, endTime: String?, recurrence: String?, notes: String)
    case none
}

/// Extracts structured JSON from model responses for task/event creation.
public enum StructuredOutputParser {

    /// Attempt to parse a task or event from the model's response text.
    /// Looks for JSON in fenced code blocks first, then raw JSON objects.
    /// Returns `.none` if no valid structured output is found.
    public static func parse(_ response: String) -> ParsedOutput {
        guard let jsonString = extractJSON(from: response),
              let data = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = dict["type"] as? String else {
            return .none
        }

        switch type {
        case "task":
            return parseTask(dict)
        case "event":
            return parseEvent(dict)
        default:
            return .none
        }
    }

    // MARK: - Private

    private static func extractJSON(from text: String) -> String? {
        // Try fenced code block first
        if let range = text.range(of: "```json"),
           let endRange = text.range(of: "```", range: range.upperBound..<text.endIndex) {
            let json = text[range.upperBound..<endRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
            if !json.isEmpty { return json }
        }

        // Fall back to finding a raw JSON object
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else {
            return nil
        }
        return String(text[start...end])
    }

    private static func parseTask(_ dict: [String: Any]) -> ParsedOutput {
        guard let title = dict["title"] as? String, !title.isEmpty else {
            return .none
        }
        let dueDate = (dict["dueDate"] as? String).flatMap { parseDate($0) }
        let notes = dict["notes"] as? String ?? ""
        return .task(title: title, dueDate: dueDate, notes: notes)
    }

    private static func parseEvent(_ dict: [String: Any]) -> ParsedOutput {
        guard let title = dict["title"] as? String, !title.isEmpty else {
            return .none
        }
        let date = (dict["date"] as? String).flatMap { parseDate($0) }
        let startTime = dict["startTime"] as? String
        let endTime = dict["endTime"] as? String
        let recurrence = dict["recurrence"] as? String
        let notes = dict["notes"] as? String ?? ""
        return .event(title: title, date: date, startTime: startTime, endTime: endTime,
                      recurrence: recurrence, notes: notes)
    }

    private static func parseDate(_ string: String) -> Date? {
        let formatters: [DateFormatter] = {
            let iso = DateFormatter()
            iso.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dateOnly = DateFormatter()
            dateOnly.dateFormat = "yyyy-MM-dd"
            return [iso, dateOnly]
        }()
        for formatter in formatters {
            if let date = formatter.date(from: string) { return date }
        }
        return nil
    }
}
