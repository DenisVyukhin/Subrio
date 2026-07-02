import Foundation

enum CurrencyFormatter {
    static func money(_ value: Double, currency: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = value.rounded() == value ? 0 : 2
        formatter.maximumFractionDigits = value.rounded() == value ? 0 : 2
        let amount = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(symbol(for: currency))\(amount)"
    }

    private static func symbol(for currency: String) -> String {
        switch currency.uppercased() {
        case "USD": "$"
        case "EUR": "€"
        case "GBP", "GBR": "£"
        case "RUB": "₽"
        default: "\(currency) "
        }
    }
}

extension Date {
    var monthYearDisplay: String {
        let language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "language") ?? AppLanguage.english.rawValue) ?? .english
        let locale = Locale(identifier: language == .russian ? "ru_RU" : "en_US")
        return formatted(.dateTime.locale(locale).month(.wide).year())
    }

    var shortDisplay: String {
        let language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "language") ?? AppLanguage.english.rawValue) ?? .english
        let locale = Locale(identifier: language == .russian ? "ru_RU" : "en_US")
        return formatted(.dateTime.locale(locale).month(.abbreviated).day().year())
    }

    func daysUntil(from date: Date = Date()) -> Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: date), to: Calendar.current.startOfDay(for: self)).day ?? 0
    }
}
