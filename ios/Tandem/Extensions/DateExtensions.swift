import Foundation

// MARK: - Date Extensions

extension Date {

    /// Returns a formatted string for the given style.
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Returns a human-readable relative description such as "Today", "Yesterday", or "3 days ago".
    var relativeDescription: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "Today"
        }

        if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }

        let components = calendar.dateComponents([.day], from: self, to: now)
        if let days = components.day, days > 0, days < 7 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }

        let weekComponents = calendar.dateComponents([.weekOfYear], from: self, to: now)
        if let weeks = weekComponents.weekOfYear, weeks > 0, weeks < 5 {
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        }

        let monthComponents = calendar.dateComponents([.month], from: self, to: now)
        if let months = monthComponents.month, months > 0 {
            return "\(months) month\(months == 1 ? "" : "s") ago"
        }

        return formatted(style: .medium)
    }

    /// Returns the full weekday name (e.g. "Monday").
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    /// Parses an ISO 8601 date string into a Date.
    static func fromISO(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        if let date = formatter.date(from: string) {
            return date
        }
        // Retry without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}

// MARK: - String Extensions

extension String {

    /// Attempts to parse the string as an ISO 8601 date.
    func toDate() -> Date? {
        return Date.fromISO(self)
    }
}
