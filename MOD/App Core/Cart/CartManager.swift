//
//  CartManager.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Cart Item Model

struct CartItem: Identifiable, Hashable {
    let id: String
    var title: String
    var price: Double
    var quantity: Int
    var details: String?
    var calories: Int?
    var imageName: String?
    
    var formattedItemTotal: String {
        String(format: "$%.2f", price * Double(quantity))
    }
}

// MARK: - Cart Manager Singleton

final class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var items: [CartItem] = []
    @Published var showCartSheet: Bool = false
    
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var formattedTotalPrice: String {
        String(format: "$%.2f", totalPrice)
    }
    
    // Add item to cart
    func addItem(
        id: String = UUID().uuidString,
        title: String,
        price: Double,
        quantity: Int = 1,
        details: String? = nil,
        calories: Int? = nil,
        imageName: String? = nil
    ) {
        if let existingIndex = items.firstIndex(where: { $0.title == title && $0.details == details }) {
            items[existingIndex].quantity += quantity
        } else {
            let newItem = CartItem(
                id: id,
                title: title,
                price: price,
                quantity: quantity,
                details: details,
                calories: calories,
                imageName: imageName
            )
            items.append(newItem)
        }
        postUpdates()
    }
    
    func updateQuantity(for id: String, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
            postUpdates()
        }
    }
    
    func removeItem(id: String) {
        items.removeAll(where: { $0.id == id })
        postUpdates()
    }
    
    func clearCart() {
        items.removeAll()
        postUpdates()
    }
    
    private func postUpdates() {
        NotificationCenter.default.post(name: .cartUpdatedNotification, object: nil)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let cartUpdatedNotification = Notification.Name("cartUpdatedNotification")
    static let showCartNotification = Notification.Name("showCartNotification")
}

// MARK: - Persistent Floating Cart Bar View

struct PersistentFloatingCartBar: View {
    @ObservedObject private var cartManager = CartManager.shared
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if cartManager.totalItemCount > 0 {
                Button(action: {
                    if let onTap = onTap {
                        onTap()
                    } else {
                        CartManager.shared.showCartSheet = true
                        NotificationCenter.default.post(name: .showCartNotification, object: nil)
                    }
                }) {
                    HStack(spacing: 12) {
                        // Left: Quantity Badge [ 1 ]
                        Text("\(cartManager.totalItemCount)")
                            .font(.barlowBold(size: 15))
                            .foregroundColor(.white)
                            .frame(minWidth: 28, minHeight: 28)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.white.opacity(0.22))
                            )
                        
                        // "View cart"
                        Text("View cart")
                            .font(.barlowBold(size: 16))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Right: Total Price "$11.99"
                        Text(cartManager.formattedTotalPrice)
                            .font(.oswaldBold(size: 18))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("Button_red"))
                            .shadow(color: Color("Button_red").opacity(0.35), radius: 8, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: cartManager.totalItemCount)
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Top Navigation Cart Button with Badge

struct TopCartButton: View {
    @ObservedObject private var cartManager = CartManager.shared
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            if let action = action {
                action()
            } else {
                CartManager.shared.showCartSheet = true
                NotificationCenter.default.post(name: .showCartNotification, object: nil)
            }
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color("Button_red"))
                    .frame(width: 34, height: 34)
                
                if cartManager.totalItemCount > 0 {
                    Text("\(cartManager.totalItemCount)")
                        .font(.barlowBold(size: 10))
                        .foregroundColor(.white)
                        .frame(width: 17, height: 17)
                        .background(Circle().fill(Color("Button_red")))
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.2))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
