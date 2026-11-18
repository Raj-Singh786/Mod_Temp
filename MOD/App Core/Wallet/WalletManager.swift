//
//  WalletManager.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Wallet Activity Type

enum WalletActivityType: String, CaseIterable, Hashable {
    case wallet
    case points
    case serviceCredit
    case bonus
    
    var iconName: String {
        switch self {
        case .wallet:
            return "wallet.pass"
        case .points, .bonus:
            return "star"
        case .serviceCredit:
            return "gift"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .wallet:
            return Color(red: 0x2E / 255.0, green: 0x76 / 255.0, blue: 0x86 / 255.0)
        case .points, .bonus:
            return Color(red: 0x9E / 255.0, green: 0x2A / 255.0, blue: 0x31 / 255.0)
        case .serviceCredit:
            return Color(red: 0x4D / 255.0, green: 0x62 / 255.0, blue: 0x1C / 255.0)
        }
    }
    
    var circleBackgroundColor: Color {
        switch self {
        case .wallet:
            return Color(red: 0xE2 / 255.0, green: 0xF0 / 255.0, blue: 0xF3 / 255.0)
        case .points, .bonus:
            return Color(red: 0xF8 / 255.0, green: 0xEB / 255.0, blue: 0xDE / 255.0)
        case .serviceCredit:
            return Color(red: 0xEE / 255.0, green: 0xF3 / 255.0, blue: 0xD6 / 255.0)
        }
    }
}

// MARK: - Wallet Activity Item Model

struct WalletActivityItem: Identifiable, Hashable {
    let id: String
    var title: String
    var category: String
    var dateString: String
    var amount: Double? = nil
    var points: Int? = nil
    var type: WalletActivityType = .wallet
    var customAmountText: String? = nil
    var isPositive: Bool = true
    
    var formattedAmount: String {
        if let custom = customAmountText {
            return custom
        }
        if let pts = points {
            let prefix = isPositive ? "+" : "-"
            return "\(prefix)\(pts) pts"
        }
        if let amt = amount {
            let prefix = isPositive ? "+" : "-"
            return String(format: "%@$%.2f", prefix, abs(amt))
        }
        return ""
    }
    
    var formattedSubtitle: String {
        "\(category) · \(dateString)"
    }
}

// MARK: - Wallet Manager Singleton

final class WalletManager: ObservableObject {
    static let shared = WalletManager()
    
    // MARK: - Published Balances
    
    @Published var giftWalletFunds: Double = 25.00
    @Published var serviceCredit: Double = 5.00
    
    // MARK: - Published Activity Log (Snapshot media_1794980848254_621b516b.jpg)
    
    @Published var activities: [WalletActivityItem] = [
        WalletActivityItem(
            id: "act-1",
            title: "Wallet top-up (Apple Pay, simulated)",
            category: "Wallet",
            dateString: "Nov 17, 6:22 PM",
            amount: 10.00,
            type: .wallet
        ),
        WalletActivityItem(
            id: "act-2",
            title: "Wallet top-up (Apple Pay, simulated)",
            category: "Wallet",
            dateString: "Nov 17, 6:22 PM",
            amount: 10.00,
            type: .wallet
        ),
        WalletActivityItem(
            id: "act-3",
            title: "Earned on MOD-993013",
            category: "Earned",
            dateString: "Nov 14, 5:26 PM",
            points: 487,
            type: .points
        ),
        WalletActivityItem(
            id: "act-4",
            title: "Service credit from support (sample)",
            category: "Service credit",
            dateString: "Nov 12, 4:31 PM",
            amount: 5.00,
            type: .serviceCredit
        ),
        WalletActivityItem(
            id: "act-5",
            title: "Gift card added to wallet (sample)",
            category: "Wallet",
            dateString: "Nov 11, 4:31 PM",
            amount: 25.00,
            type: .wallet
        ),
        WalletActivityItem(
            id: "act-6",
            title: "Earned on MOD-825913",
            category: "Earned",
            dateString: "Nov 5, 5:26 PM",
            points: 262,
            type: .points
        ),
        WalletActivityItem(
            id: "act-7",
            title: "Welcome bonus (sample profile)",
            category: "Bonus",
            dateString: "Oct 8, 4:31 PM",
            points: 200,
            type: .bonus
        )
    ]
    
    // MARK: - Formatted Strings
    
    var totalFunds: Double {
        giftWalletFunds + serviceCredit
    }
    
    var formattedGiftFunds: String {
        String(format: "$%.2f", giftWalletFunds)
    }
    
    var formattedServiceCredit: String {
        String(format: "$%.2f", serviceCredit)
    }
    
    // MARK: - Actions
    
    /// Adds funds via simulated top-up
    func addGiftFunds(amount: Double, method: String = "Apple Pay, simulated") {
        guard amount > 0 else { return }
        giftWalletFunds += amount
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let dateStr = formatter.string(from: Date())
        
        let newActivity = WalletActivityItem(
            id: UUID().uuidString,
            title: "Wallet top-up (\(method))",
            category: "Wallet",
            dateString: dateStr,
            amount: amount,
            type: .wallet
        )
        activities.insert(newActivity, at: 0)
    }
    
    /// Redeems a gift card code
    @discardableResult
    func redeemGiftCard(code: String) -> (success: Bool, message: String) {
        let cleaned = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleaned.isEmpty else {
            return (false, "Please enter a valid gift card code.")
        }
        
        let amountToAdd: Double = (cleaned == "MODGIFT25") ? 25.00 : 25.00
        giftWalletFunds += amountToAdd
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let dateStr = formatter.string(from: Date())
        
        let newActivity = WalletActivityItem(
            id: UUID().uuidString,
            title: "Gift card added to wallet (\(cleaned))",
            category: "Wallet",
            dateString: dateStr,
            amount: amountToAdd,
            type: .wallet
        )
        activities.insert(newActivity, at: 0)
        
        return (true, "Code '\(cleaned)' redeemed! \(String(format: "$%.2f", amountToAdd)) added to your Gift-Wallet funds.")
    }
}
