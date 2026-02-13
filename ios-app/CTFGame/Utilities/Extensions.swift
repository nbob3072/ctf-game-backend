import SwiftUI
import Foundation

// MARK: - View Extensions

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Date Extensions

extension Date {
    func timeAgo() -> String {
        let now = Date()
        let interval = now.timeIntervalSince(self)
        
        let minute = 60.0
        let hour = minute * 60
        let day = hour * 24
        let week = day * 7
        
        if interval < minute {
            return "Just now"
        } else if interval < hour {
            let minutes = Int(interval / minute)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < day {
            let hours = Int(interval / hour)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if interval < week {
            let days = Int(interval / day)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            let weeks = Int(interval / week)
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        }
    }
    
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

// MARK: - Double Extensions

extension Double {
    func formattedDistance() -> String {
        if self < 1000 {
            return "\(Int(self))m"
        } else {
            return String(format: "%.1fkm", self / 1000)
        }
    }
}

// MARK: - String Extensions

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
}

// MARK: - Array Extensions

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Notification.Name Extensions

extension Notification.Name {
    static let navigateToFlag = Notification.Name("NavigateToFlag")
    static let flagCaptured = Notification.Name("FlagCaptured")
    static let userLeveledUp = Notification.Name("UserLeveledUp")
}
