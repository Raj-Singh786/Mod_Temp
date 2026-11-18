//
//  AllWalletActivityView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI

// MARK: - AllWalletActivityView

struct AllWalletActivityView: View {
    
    // MARK: - Configuration & Callbacks
    
    var showHeader: Bool = true
    var onBack: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var walletManager = WalletManager.shared
    
    // MARK: - Body
    
    var body: some View {
        if showHeader {
            ZStack {
                Color("app_background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Custom Navigation Bar
                    customNavigationBar
                    
                    // Scrollable Main Content
                    ScrollView(showsIndicators: false) {
                        contentStack
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .padding(.bottom, 36)
                    }
                }
            }
        } else {
            contentStack
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar (Snapshot media_1794980848254_621b516b.jpg)
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Back Button
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootNav = windowScene.windows.first?.rootViewController as? UINavigationController {
                    rootNav.popViewController(animated: true)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 15, weight: .bold))
                    
                    Text("Back")
                        .font(.barlowBold(size: 16))
                }
                .foregroundColor(Color("Button_red"))
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Center: Title
            Text("Activity")
                .font(.oswaldMedium(size: 18))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart Icons
            HStack(spacing: 16) {
                Button(action: {
                    onStarTap?()
                }) {
                    Image(systemName: "star")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("app_black"))
                }
                .buttonStyle(PlainButtonStyle())
                
                TopCartButton(action: onCartTap)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - Content Stack
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Screen Header: REWARDS & WALLET ACTIVITY
            Text("REWARDS & WALLET ACTIVITY")
                .font(.oswaldMedium(size: 30))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
                .padding(.top, 4)
            
            // Activity List Card
            activityListCard
        }
    }
    
    // MARK: - Activity List Card
    
    private var activityListCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(walletManager.activities.enumerated()), id: \.element.id) { index, item in
                VStack(spacing: 0) {
                    // Row Item
                    activityRow(item: item)
                    
                    // Divider between rows
                    if index < walletManager.activities.count - 1 {
                        Rectangle()
                            .fill(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
                            .frame(height: 1)
                    }
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Single Activity Row
    
    private func activityRow(item: WalletActivityItem) -> some View {
        HStack(alignment: .center, spacing: 14) {
            // Leading Circular Icon Badge
            ZStack {
                Circle()
                    .fill(item.type.circleBackgroundColor)
                    .frame(width: 38, height: 38)
                
                Image(systemName: item.type.iconName)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(item.type.iconColor)
            }
            
            // Middle Content: Title & Subtitle
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.barlowBold(size: 14.5))
                    .foregroundColor(Color("app_black"))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(item.formattedSubtitle)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
            }
            
            Spacer()
            
            // Trailing Formatted Amount
            Text(item.formattedAmount)
                .font(.barlowBold(size: 15.5))
                .foregroundColor(Color(red: 0x4D / 255.0, green: 0x62 / 255.0, blue: 0x1C / 255.0))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - SwiftUI Preview

struct AllWalletActivityView_Previews: PreviewProvider {
    static var previews: some View {
        AllWalletActivityView(showHeader: true)
    }
}
