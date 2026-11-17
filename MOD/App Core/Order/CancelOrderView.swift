//
//  CancelOrderView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Cancel Order Reason Enum

enum CancelOrderReason: String, CaseIterable, Identifiable {
    case orderedByMistake = "Ordered by mistake"
    case needToChangeItems = "Need to change items"
    case wrongTimeOrLocation = "Wrong time or location"
    case takingTooLong = "Taking too long"
    case other = "Other"
    
    var id: String { rawValue }
}

// MARK: - CancelOrderView

struct CancelOrderView: View {
    
    // MARK: - Properties
    
    let order: OrderHistoryItem
    var onConfirmCancel: ((CancelOrderReason) -> Void)? = nil
    var onKeepOrder: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var selectedReason: CancelOrderReason = .orderedByMistake
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle Indicator
            Capsule()
                .fill(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0))
                .frame(width: 38, height: 4.5)
                .padding(.top, 10)
                .padding(.bottom, 14)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Top Header Row: CANCEL THIS ORDER? + Close Button
                    HStack(alignment: .center) {
                        Text("CANCEL THIS ORDER?")
                            .font(.oswaldBold(size: 22))
                            .tracking(0.6)
                            .foregroundColor(Color("app_black"))
                        
                        Spacer()
                        
                        // Close (X) Button
                        Button(action: {
                            if let onKeepOrder = onKeepOrder {
                                onKeepOrder()
                            } else {
                                dismiss()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color("app_black"))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                                        .background(Circle().fill(Color.white))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Refund & Order Metadata Note
                    Text("\(order.id) · $\(String(format: "%.2f", order.totalAmount)). You'll get a full refund to your original payment, and any points, wallet funds or service credit used will be restored. This can't be undone.")
                        .font(.barlowRegular(size: 13.5))
                        .foregroundColor(Color("text_gary"))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Reason Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reason")
                            .font(.barlowBold(size: 14))
                            .foregroundColor(Color("app_black"))
                        
                        VStack(spacing: 8) {
                            ForEach(CancelOrderReason.allCases) { reason in
                                reasonRadioRow(reason)
                            }
                        }
                    }
                    .padding(.top, 4)
                    
                    Spacer()
                        .frame(height: 12)
                }
                .padding(.horizontal, 22)
            }
            
            // Bottom Action Bar: KEEP ORDER & CANCEL ORDER
            VStack(spacing: 0) {
                Divider()
                    .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    // KEEP ORDER Button
                    Button(action: {
                        if let onKeepOrder = onKeepOrder {
                            onKeepOrder()
                        } else {
                            dismiss()
                        }
                    }) {
                        Text("KEEP ORDER")
                            .font(.oswaldMedium(size: 14.5))
                            .tracking(0.8)
                            .foregroundColor(Color("app_black"))
                            .padding(.horizontal, 16)
                            .frame(height: 46)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // CANCEL ORDER Button
                    Button(action: {
                        dismiss()
                        onConfirmCancel?(selectedReason)
                    }) {
                        Text("CANCEL ORDER")
                            .font(.oswaldMedium(size: 14.5))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 46)
                            .background(
                                Capsule()
                                    .fill(Color("Button_red"))
                                    .shadow(color: Color("Button_red").opacity(0.35), radius: 6, x: 0, y: 3)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(Color.white)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Radio Row
    
    private func reasonRadioRow(_ reason: CancelOrderReason) -> some View {
        let isSelected = selectedReason == reason
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedReason = reason
            }
        }) {
            HStack(spacing: 12) {
                // Radio Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color("Button_red") : Color(red: 0xBE / 255.0, green: 0xB8 / 255.0, blue: 0xAE / 255.0), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    
                    if isSelected {
                        Circle()
                            .fill(Color("Button_red"))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(reason.rawValue)
                    .font(isSelected ? .barlowMedium(size: 14) : .barlowRegular(size: 14))
                    .foregroundColor(Color("app_black"))
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color(red: 0xFD / 255.0, green: 0xF2 / 255.0, blue: 0xF4 / 255.0) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color("Button_red") : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - SwiftUI Preview

struct CancelOrderView_Previews: PreviewProvider {
    static var previews: some View {
        CancelOrderView(
            order: OrderHistoryItem(
                id: "MOD-604894",
                status: .accepted,
                dateString: "Nov 16, 2026",
                storeName: "Capitol Hill",
                fulfillment: .pickup,
                itemsDescription: "1× Aloha, 1× No Name Cake",
                totalAmount: 11.40,
                isGoTo: false,
                itemsDetail: ["1× Aloha Pizza - $11.40"]
            )
        )
    }
}
