//
//  ReceiptView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI
import UIKit

// MARK: - Receipt Line Item Model

struct ReceiptLineItem: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let name: String
    let customization: String?
    let quantity: Int
    let price: Double
    
    var totalPrice: Double {
        Double(quantity) * price
    }
}

// MARK: - Receipt Data Model

struct ReceiptData: Hashable {
    let invoiceNumber: String
    let revision: String
    let orderId: String
    let dateFormatted: String
    let statusText: String
    
    // Customer
    let customerName: String
    let customerEmail: String
    let customerPhone: String
    
    // Store
    let storeName: String
    let storeAddress: String
    let fulfillmentMethod: String
    
    // Items
    let items: [ReceiptLineItem]
    
    // Points
    let pointsText: String
    
    // Financials
    let subtotal: Double
    let tax: Double
    let tip: Double
    let total: Double
    
    // Payment
    let serviceCredit: Double
    let giftWalletFunds: Double
    let paymentMethodName: String
    let paymentMethodAmount: Double
    
    // Snapshot Default (media_1794899969295_62e349e5.png)
    static var sampleDefault: ReceiptData {
        ReceiptData(
            invoiceNumber: "INV-4677876",
            revision: "1",
            orderId: "MOD-010358",
            dateFormatted: "Nov 16, 2026 10:57 PM PST",
            statusText: "Picked up",
            customerName: "Raj",
            customerEmail: "risabhputta213@gmail.com",
            customerPhone: "(206) 555-0142",
            storeName: "MOD Capitol Hill",
            storeAddress: "1302 Pine St, Seattle, WA 98101",
            fulfillmentMethod: "In-store pickup",
            items: [
                ReceiptLineItem(
                    name: "Aloha",
                    customization: "Mini · Thin crust\nFrank's Buffalo sauce · Mozzarella (Light) · Canadian bacon · Pineapple · Cheddar (Right ½) · Red onion (Left ½) · Roasted broccoli (Right ½)",
                    quantity: 1,
                    price: 8.99
                ),
                ReceiptLineItem(
                    name: "No Name Cake",
                    customization: nil,
                    quantity: 1,
                    price: 3.99
                )
            ],
            pointsText: "150 earned · 10/$1 × 1.25 (Silver)",
            subtotal: 12.98,
            tax: 1.14,
            tip: 2.34,
            total: 16.46,
            serviceCredit: 0.0,
            giftWalletFunds: 0.0,
            paymentMethodName: "Apple Pay (simulated)",
            paymentMethodAmount: 16.46
        )
    }
    
    static func from(order: OrderHistoryItem) -> ReceiptData {
        if order.id == "MOD-010358" {
            return sampleDefault
        }
        
        // Dynamically populate from other orders
        let subtotalCalc = max(5.0, order.totalAmount * 0.78)
        let taxCalc = order.totalAmount * 0.08
        let tipCalc = order.totalAmount - subtotalCalc - taxCalc
        let earnedPoints = Int(order.totalAmount * 10 * 1.25)
        
        let lineItems: [ReceiptLineItem] = order.itemsDetail.enumerated().map { index, text in
            let parts = text.components(separatedBy: " - $")
            let namePart = parts.first ?? text
            let pricePart = Double(parts.last ?? "9.99") ?? 9.99
            return ReceiptLineItem(
                name: namePart,
                customization: index == 0 ? "11\" Pizza · MOD original crust\nHouse tomato sauce · Mozzarella · Fresh herbs" : nil,
                quantity: 1,
                price: pricePart
            )
        }
        
        return ReceiptData(
            invoiceNumber: "INV-\(abs(order.id.hashValue % 9000000 + 1000000))",
            revision: "1",
            orderId: order.id,
            dateFormatted: "\(order.dateString) 10:57 PM PST",
            statusText: order.status.rawValue,
            customerName: "Raj",
            customerEmail: "risabhputta213@gmail.com",
            customerPhone: "(206) 555-0142",
            storeName: "MOD \(order.storeName)",
            storeAddress: "1302 Pine St, Seattle, WA 98101",
            fulfillmentMethod: order.fulfillment.rawValue,
            items: lineItems.isEmpty ? sampleDefault.items : lineItems,
            pointsText: "\(earnedPoints) earned · 10/$1 × 1.25 (Silver)",
            subtotal: subtotalCalc,
            tax: taxCalc,
            tip: tipCalc,
            total: order.totalAmount,
            serviceCredit: 0.0,
            giftWalletFunds: 0.0,
            paymentMethodName: "Apple Pay (simulated)",
            paymentMethodAmount: order.totalAmount
        )
    }
}

// MARK: - ReceiptView

struct ReceiptView: View {
    
    // MARK: - Configuration
    
    var receipt: ReceiptData = .sampleDefault
    var onBack: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var toastMessage: String? = nil
    @State private var showEmailAlert: Bool = false
    
    // MARK: - Initializers
    
    init(receipt: ReceiptData = .sampleDefault, onBack: (() -> Void)? = nil, onStarTap: (() -> Void)? = nil, onCartTap: (() -> Void)? = nil) {
        self.receipt = receipt
        self.onBack = onBack
        self.onStarTap = onStarTap
        self.onCartTap = onCartTap
    }
    
    init(order: OrderHistoryItem, onBack: (() -> Void)? = nil, onStarTap: (() -> Void)? = nil, onCartTap: (() -> Void)? = nil) {
        self.receipt = ReceiptData.from(order: order)
        self.onBack = onBack
        self.onStarTap = onStarTap
        self.onCartTap = onCartTap
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color("app_background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Navigation Bar
                customNavigationBar
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // RECEIPT Title
                        Text("RECEIPT")
                            .font(.oswaldMedium(size: 32))
                            .tracking(0.8)
                            .foregroundColor(Color("app_black"))
                            .padding(.top, 4)
                        
                        // Action Buttons: DOWNLOAD PDF & PRINT
                        HStack(spacing: 12) {
                            // DOWNLOAD PDF Button
                            Button(action: {
                                handleDownloadPDF()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down.to.line")
                                        .font(.system(size: 13, weight: .bold))
                                    Text("DOWNLOAD PDF")
                                        .font(.oswaldMedium(size: 13.5))
                                        .tracking(0.8)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .frame(height: 44)
                                .background(
                                    Capsule()
                                        .fill(Color("Button_red"))
                                        .shadow(color: Color("Button_red").opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // PRINT Button
                            Button(action: {
                                handlePrint()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "printer")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("PRINT")
                                        .font(.oswaldMedium(size: 13.5))
                                        .tracking(0.8)
                                }
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 20)
                                .frame(height: 44)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // EMAIL A COPY Button
                        Button(action: {
                            showEmailAlert = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 13, weight: .medium))
                                Text("EMAIL A COPY")
                                    .font(.oswaldMedium(size: 13.5))
                                    .tracking(0.8)
                            }
                            .foregroundColor(Color("app_black"))
                            .padding(.horizontal, 20)
                            .frame(height: 44)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, -6)
                        
                        // Invoice Card (White Sheet)
                        invoiceCard
                        
                        Spacer()
                            .frame(height: 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            
            // Toast Notification Overlay
            if let toast = toastMessage {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.barlowMedium(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color("app_black").opacity(0.92))
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: toastMessage)
            }
        }
        .alert(isPresented: $showEmailAlert) {
            Alert(
                title: Text("Receipt Sent"),
                message: Text("A copy of invoice #\(receipt.invoiceNumber) has been emailed to \(receipt.customerEmail)."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Custom Top Navigation Bar
    
    private var customNavigationBar: some View {
        HStack(alignment: .center) {
            // Left: Red Back Chevron + "Back"
            Button(action: {
                if let onBack = onBack {
                    onBack()
                } else {
                    dismiss()
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
            Text("Receipt")
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
                
                Button(action: {
                    onCartTap?()
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundColor(Color("Button_red"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 70, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(Color("app_background"))
    }
    
    // MARK: - Invoice Card (Matching Snapshot)
    
    private var invoiceCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header: MOD Logo + "INVOICE" with metadata table
            HStack(alignment: .top) {
                // MOD Logo Shield
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 58)
                
                Spacer()
                
                // Invoice Details Column
                VStack(alignment: .trailing, spacing: 4) {
                    Text("INVOICE")
                        .font(.oswaldBold(size: 24))
                        .foregroundColor(Color("app_black"))
                        .padding(.bottom, 2)
                    
                    metadataRow(label: "Invoice", value: receipt.invoiceNumber)
                    metadataRow(label: "Revision", value: receipt.revision)
                    metadataRow(label: "Order", value: receipt.orderId)
                    metadataRow(label: "Date", value: receipt.dateFormatted)
                    metadataRow(label: "Status", value: receipt.statusText)
                }
            }
            
            // Red Divider Line
            Rectangle()
                .fill(Color("Button_red"))
                .frame(height: 2)
                .padding(.vertical, 2)
            
            // BILLED TO Section
            VStack(alignment: .leading, spacing: 3) {
                Text("BILLED TO")
                    .font(.oswaldMedium(size: 12))
                    .tracking(1.0)
                    .foregroundColor(Color("text_gary"))
                    .padding(.bottom, 1)
                
                Text(receipt.customerName)
                    .font(.barlowMedium(size: 14))
                    .foregroundColor(Color("app_black"))
                
                Text(receipt.customerEmail)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                Text(receipt.customerPhone)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("app_black"))
            }
            
            // STORE Section
            VStack(alignment: .leading, spacing: 3) {
                Text("STORE")
                    .font(.oswaldMedium(size: 12))
                    .tracking(1.0)
                    .foregroundColor(Color("text_gary"))
                    .padding(.bottom, 1)
                
                Text(receipt.storeName)
                    .font(.barlowMedium(size: 14))
                    .foregroundColor(Color("app_black"))
                
                Text(receipt.storeAddress)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
                
                Text(receipt.fulfillmentMethod)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("text_gary"))
            }
            .padding(.top, 4)
            
            // Table Column Headers: ITEM, QTY, PRICE, TOTAL
            VStack(spacing: 8) {
                HStack {
                    Text("ITEM")
                        .font(.oswaldMedium(size: 12))
                        .tracking(0.8)
                        .foregroundColor(Color("text_gary"))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Text("QTY")
                            .font(.oswaldMedium(size: 12))
                            .tracking(0.8)
                            .foregroundColor(Color("text_gary"))
                            .frame(width: 32, alignment: .trailing)
                        
                        Text("PRICE")
                            .font(.oswaldMedium(size: 12))
                            .tracking(0.8)
                            .foregroundColor(Color("text_gary"))
                            .frame(width: 52, alignment: .trailing)
                        
                        Text("TOTAL")
                            .font(.oswaldMedium(size: 12))
                            .tracking(0.8)
                            .foregroundColor(Color("text_gary"))
                            .frame(width: 52, alignment: .trailing)
                    }
                }
                
                Divider()
                    .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            }
            .padding(.top, 4)
            
            // Item Line Items
            VStack(spacing: 14) {
                ForEach(receipt.items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text(item.name)
                                .font(.barlowBold(size: 14.5))
                                .foregroundColor(Color("app_black"))
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Text("\(item.quantity)")
                                    .font(.barlowRegular(size: 14))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 32, alignment: .trailing)
                                
                                Text(String(format: "$%.2f", item.price))
                                    .font(.barlowRegular(size: 14))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 52, alignment: .trailing)
                                
                                Text(String(format: "$%.2f", item.totalPrice))
                                    .font(.barlowRegular(size: 14))
                                    .foregroundColor(Color("app_black"))
                                    .frame(width: 52, alignment: .trailing)
                            }
                        }
                        
                        if let customization = item.customization {
                            Text(customization)
                                .font(.barlowRegular(size: 12))
                                .foregroundColor(Color("text_gary"))
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.trailing, 100)
                        }
                    }
                    
                    if item.id != receipt.items.last?.id {
                        Divider()
                            .background(Color(red: 0xF3 / 255.0, green: 0xEE / 255.0, blue: 0xE4 / 255.0))
                    }
                }
            }
            
            // Divider
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            // Points Earned Row
            HStack(spacing: 4) {
                Text("Points:")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                Text(receipt.pointsText)
                    .font(.barlowRegular(size: 13.5))
                    .foregroundColor(Color("app_black"))
            }
            .padding(.vertical, 4)
            
            // Financial Breakdown: Subtotal, Estimated tax, Tip
            VStack(spacing: 8) {
                breakdownRow(label: "Subtotal", amount: receipt.subtotal)
                breakdownRow(label: "Estimated tax", amount: receipt.tax)
                breakdownRow(label: "Tip", amount: receipt.tip)
            }
            .padding(.top, 4)
            
            // Total Row
            HStack {
                Text("Total")
                    .font(.oswaldBold(size: 20))
                    .foregroundColor(Color("app_black"))
                
                Spacer()
                
                Text(String(format: "$%.2f", receipt.total))
                    .font(.oswaldBold(size: 22))
                    .foregroundColor(Color("app_black"))
            }
            .padding(.top, 6)
            
            // Payment Details
            VStack(spacing: 6) {
                paymentRow(label: "Service credit", amount: receipt.serviceCredit)
                paymentRow(label: "Gift-wallet funds", amount: receipt.giftWalletFunds)
                paymentRow(label: receipt.paymentMethodName, amount: receipt.paymentMethodAmount)
            }
            .padding(.top, 2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Row Helpers
    
    private func metadataRow(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.barlowRegular(size: 12.5))
                .foregroundColor(Color("text_gary"))
                .frame(width: 58, alignment: .trailing)
            
            Text(value)
                .font(label == "Invoice" || label == "Order" ? .oswaldMedium(size: 13) : .barlowMedium(size: 12.5))
                .foregroundColor(Color("app_black"))
                .frame(alignment: .trailing)
        }
    }
    
    private func breakdownRow(label: String, amount: Double) -> some View {
        HStack {
            Text(label)
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            Text(String(format: "$%.2f", amount))
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("app_black"))
        }
    }
    
    private func paymentRow(label: String, amount: Double) -> some View {
        HStack {
            Text(label)
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
            
            Spacer()
            
            Text(String(format: "$%.2f", amount))
                .font(.barlowRegular(size: 13.5))
                .foregroundColor(Color("text_gary"))
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleDownloadPDF() {
        showToast("PDF downloaded to your device files.")
    }
    
    private func handlePrint() {
        showToast("Sending invoice #\(receipt.invoiceNumber) to AirPrint printer...")
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}

// MARK: - SwiftUI Preview

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView()
    }
}
