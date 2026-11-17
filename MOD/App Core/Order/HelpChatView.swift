//
//  HelpChatView.swift
//  MOD
//
//  Created by Rajpal singh on 17/11/26.
//

import SwiftUI

// MARK: - Help Chat Message Model

struct ChatMessageItem: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let text: String
    let isUser: Bool
    let timestamp: String
}

// MARK: - HelpChatView (Snapshot media_1794902173741_821ac69e.jpg)

struct HelpChatView: View {
    
    // MARK: - Callbacks
    
    var onDismiss: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var messageInput: String = ""
    @State private var messages: [ChatMessageItem] = [
        ChatMessageItem(text: "hi", isUser: true, timestamp: "1:07 PM"),
        ChatMessageItem(text: "Thanks — a support teammate has the details and will follow up here.", isUser: false, timestamp: "1:07 PM"),
        ChatMessageItem(text: "Where is my order?", isUser: true, timestamp: "1:07 PM"),
        ChatMessageItem(text: "Your order is “Scheduled”. Current ETA is 4:45 PM PST.", isUser: false, timestamp: "1:07 PM")
    ]
    
    // Suggested Prompt Chips
    private let suggestionChips: [String] = [
        "Where is my order?",
        "Driver can’t find me",
        "Update instructions"
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle Indicator
            Capsule()
                .fill(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0))
                .frame(width: 38, height: 4.5)
                .padding(.top, 10)
                .padding(.bottom, 12)
            
            // Header: DELIVERY SUPPORT CHAT + Close (X)
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    Text("DELIVERY SUPPORT CHAT")
                        .font(.oswaldBold(size: 21))
                        .tracking(0.6)
                        .foregroundColor(Color("app_black"))
                    
                    Spacer()
                    
                    // Close (X) Button
                    Button(action: {
                        if let onDismiss = onDismiss {
                            onDismiss()
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
                
                // Subtle Tan Divider Bar
                Capsule()
                    .fill(Color(red: 0xF3 / 255.0, green: 0xE8 / 255.0, blue: 0xD7 / 255.0))
                    .frame(height: 3)
                    .frame(maxWidth: 240, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Chat Conversation Messages
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(messages) { message in
                        chatBubble(message)
                    }
                    
                    // Quick Action Chips Row
                    quickChipsSection
                        .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 14)
            }
            
            // Bottom Message Input Bar
            bottomInputBar
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Chat Bubble
    
    private func chatBubble(_ message: ChatMessageItem) -> some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color("Button_red"))
                        )
                    
                    Text(message.timestamp)
                        .font(.barlowRegular(size: 11))
                        .foregroundColor(Color("text_gary"))
                        .padding(.trailing, 4)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .lineSpacing(2)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(red: 0xF7 / 255.0, green: 0xF0 / 255.0, blue: 0xE4 / 255.0))
                        )
                    
                    Text(message.timestamp)
                        .font(.barlowRegular(size: 11))
                        .foregroundColor(Color("text_gary"))
                        .padding(.leading, 4)
                }
                
                Spacer(minLength: 40)
            }
        }
    }
    
    // MARK: - Quick Chips Section
    
    private var quickChipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row 1
            HStack(spacing: 8) {
                chipButton(text: "Where is my order?")
                chipButton(text: "Driver can’t find me")
                Spacer()
            }
            
            // Row 2
            HStack(spacing: 8) {
                chipButton(text: "Update instructions")
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func chipButton(text: String) -> some View {
        Button(action: {
            messageInput = text
        }) {
            Text(text)
                .font(.barlowSemiBold(size: 13.5))
                .foregroundColor(Color("app_black"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Bottom Input Bar
    
    private var bottomInputBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0))
            
            HStack(spacing: 10) {
                // Text Field
                TextField("Type a message", text: $messageInput)
                    .font(.barlowRegular(size: 14))
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                    )
                
                // SEND Button
                Button(action: {
                    let trimmed = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    messages.append(ChatMessageItem(text: trimmed, isUser: true, timestamp: "1:08 PM"))
                    messageInput = ""
                }) {
                    Text("SEND")
                        .font(.oswaldMedium(size: 14))
                        .tracking(0.8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .frame(height: 46)
                        .background(
                            Capsule()
                                .fill(Color("Button_red"))
                                .shadow(color: Color("Button_red").opacity(0.35), radius: 5, x: 0, y: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }
}

// MARK: - SwiftUI Preview

struct HelpChatView_Previews: PreviewProvider {
    static var previews: some View {
        HelpChatView()
    }
}
