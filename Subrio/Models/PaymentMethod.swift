import Foundation
import SwiftData

@Model
final class PaymentMethod {
    @Attribute(.unique) var id: UUID
    var name: String
    var lastFour: String
    var tintHex: String
    var statusRaw: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        lastFour: String,
        tintHex: String,
        status: PaymentStatus = .active
    ) {
        self.id = id
        self.name = name
        self.lastFour = lastFour
        self.tintHex = tintHex
        self.statusRaw = status.rawValue
        self.createdAt = Date()
    }

    var status: PaymentStatus {
        get { PaymentStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }
}
