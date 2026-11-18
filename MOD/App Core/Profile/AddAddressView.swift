//
//  AddAddressView.swift
//  MOD
//
//  Created by Rajpal singh on 18/11/26.
//

import SwiftUI
import Combine

// MARK: - Saved Address Item Model

struct SavedAddressItem: Identifiable, Hashable {
    let id: String
    var name: String
    var address: String
    var deliveryInstructions: String?
    var isSelected: Bool
}

// MARK: - Address Manager Singleton

final class AddressManager: ObservableObject {
    static let shared = AddressManager()
    
    @Published var addresses: [SavedAddressItem] = [
        SavedAddressItem(
            id: "addr-1",
            name: "Home",
            address: "415 E Pine St, Apt 3B, Seattle, WA 98122",
            deliveryInstructions: "Buzz 3B. Leave at the door.",
            isSelected: true
        ),
        SavedAddressItem(
            id: "addr-2",
            name: "Work",
            address: "1201 2nd Ave, Floor 9, Seattle, WA 98101",
            deliveryInstructions: "Check in at the front desk.",
            isSelected: false
        )
    ]
    
    var selectedAddress: SavedAddressItem? {
        addresses.first(where: { $0.isSelected }) ?? addresses.first
    }
    
    func selectAddress(id: String) {
        for index in addresses.indices {
            addresses[index].isSelected = (addresses[index].id == id)
        }
    }
    
    func addAddress(name: String, address: String, deliveryInstructions: String?) {
        let isFirst = addresses.isEmpty
        let newAddress = SavedAddressItem(
            id: UUID().uuidString,
            name: name,
            address: address,
            deliveryInstructions: deliveryInstructions?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? deliveryInstructions : nil,
            isSelected: isFirst
        )
        addresses.append(newAddress)
    }
    
    func removeAddress(id: String) {
        addresses.removeAll(where: { $0.id == id })
        if !addresses.isEmpty && !addresses.contains(where: { $0.isSelected }) {
            addresses[0].isSelected = true
        }
    }
    
    func updateAddress(id: String, name: String, address: String, deliveryInstructions: String?) {
        if let index = addresses.firstIndex(where: { $0.id == id }) {
            addresses[index].name = name
            addresses[index].address = address
            addresses[index].deliveryInstructions = deliveryInstructions?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? deliveryInstructions : nil
        }
    }
}

// MARK: - AddAddressView

struct AddAddressView: View {
    
    // MARK: - Configuration & Callbacks
    
    var showHeader: Bool = true
    var onBack: (() -> Void)? = nil
    var onCartTap: (() -> Void)? = nil
    var onStarTap: (() -> Void)? = nil
    
    // MARK: - Observed State
    
    @ObservedObject private var addressManager = AddressManager.shared
    
    // MARK: - Form Input State
    
    @State private var newName: String = ""
    @State private var newAddress: String = ""
    @State private var newDeliveryInstructions: String = ""
    
    // Edit Sheet State
    @State private var editingAddressItem: SavedAddressItem? = nil
    @State private var showEditSheet: Bool = false
    @State private var editName: String = ""
    @State private var editAddress: String = ""
    @State private var editDeliveryInstructions: String = ""
    
    // Alerts
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
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
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showEditSheet) {
                editAddressSheetView
            }
        } else {
            contentStack
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showEditSheet) {
                    editAddressSheetView
                }
        }
    }
    
    // MARK: - 0. Custom Top Navigation Bar (Snapshot media_1794982966145_3d2f413f.png)
    
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
            Text("Addresses")
                .font(.oswaldMedium(size: 18))
                .foregroundColor(Color("app_black"))
            
            Spacer()
            
            // Right: Star & Cart Icons
            HStack(spacing: 16) {
                Button(action: {
                    if let onStarTap = onStarTap {
                        onStarTap()
                    } else {
                        AccountSheetManager.shared.handleStarTap()
                    }
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
        VStack(alignment: .leading, spacing: 18) {
            // Screen Header: SAVED ADDRESSES & Member addresses
            headerSection
            
            // Saved Addresses Cards List
            savedAddressesCardsSection
            
            // "ADD AN ADDRESS" Form Card
            addAddressFormCard
        }
    }
    
    // MARK: - 1. Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SAVED ADDRESSES")
                .font(.oswaldMedium(size: 32))
                .tracking(0.8)
                .foregroundColor(Color("app_black"))
            
            Text("Member addresses")
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("text_gary"))
        }
        .padding(.top, 4)
    }
    
    // MARK: - 2. Saved Addresses Cards Section
    
    private var savedAddressesCardsSection: some View {
        VStack(spacing: 14) {
            ForEach(addressManager.addresses) { addressItem in
                addressCard(addressItem)
            }
        }
    }
    
    private func addressCard(_ item: SavedAddressItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Row: Icon + Title & Badge
            HStack(alignment: .center, spacing: 12) {
                // Circular Badge
                if item.isSelected {
                    // Selected: Red filled circle with white checkmark
                    ZStack {
                        Circle()
                            .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    // Unselected: Neutral outline circle with location pin icon
                    ZStack {
                        Circle()
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(Circle().fill(Color.white))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "mappin")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("app_black"))
                    }
                }
                
                // Name & Optional "Selected" pill
                HStack(spacing: 8) {
                    Text(item.name)
                        .font(.barlowBold(size: 16))
                        .foregroundColor(Color("app_black"))
                    
                    if item.isSelected {
                        Text("Selected")
                            .font(.barlowBold(size: 11))
                            .foregroundColor(Color(red: 0x4D / 255.0, green: 0x62 / 255.0, blue: 0x1C / 255.0))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0xEE / 255.0, green: 0xF3 / 255.0, blue: 0xD6 / 255.0))
                            )
                    }
                }
                
                Spacer()
            }
            
            // Address Text
            Text(item.address)
                .font(.barlowRegular(size: 14))
                .foregroundColor(Color("app_black"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
            
            // Delivery Instructions (if present)
            if let instructions = item.deliveryInstructions, !instructions.isEmpty {
                Text(instructions)
                    .font(.barlowRegular(size: 12.5))
                    .foregroundColor(Color("text_gary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Action Buttons: EDIT & REMOVE
            HStack(spacing: 24) {
                // EDIT Button
                Button(action: {
                    startEditing(item)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("app_black"))
                        
                        Text("EDIT")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.6)
                            .foregroundColor(Color("app_black"))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // REMOVE Button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        addressManager.removeAddress(id: item.id)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color("Button_red"))
                        
                        Text("REMOVE")
                            .font(.oswaldMedium(size: 13))
                            .tracking(0.6)
                            .foregroundColor(Color("Button_red"))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            item.isSelected ? Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0) : Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0),
                            lineWidth: item.isSelected ? 1.5 : 1.2
                        )
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                addressManager.selectAddress(id: item.id)
            }
        }
    }
    
    // MARK: - 3. "ADD AN ADDRESS" Form Card
    
    private var addAddressFormCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("ADD AN ADDRESS")
                .font(.oswaldMedium(size: 18))
                .tracking(0.6)
                .foregroundColor(Color("app_black"))
            
            // Name Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                TextField("Home, Work...", text: $newName)
                    .font(.barlowRegular(size: 15))
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                    )
            }
            
            // Address Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Address")
                    .font(.barlowBold(size: 13.5))
                    .foregroundColor(Color("app_black"))
                
                TextField("", text: $newAddress)
                    .font(.barlowRegular(size: 15))
                    .foregroundColor(Color("app_black"))
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                    )
            }
            
            // Delivery Instructions Field
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("Delivery instructions")
                        .font(.barlowBold(size: 13.5))
                        .foregroundColor(Color("app_black"))
                    
                    Text("optional")
                        .font(.barlowRegular(size: 12))
                        .foregroundColor(Color("text_gary"))
                }
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $newDeliveryInstructions)
                        .font(.barlowRegular(size: 14))
                        .foregroundColor(Color("app_black"))
                        .padding(8)
                        .frame(height: 76)
                        .background(Color.white)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                )
            }
            
            // ADD ADDRESS Button
            Button(action: {
                submitNewAddress()
            }) {
                Text("ADD ADDRESS")
                    .font(.oswaldMedium(size: 14))
                    .tracking(0.8)
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .frame(height: 44)
                    .background(
                        Capsule()
                            .fill(Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0))
                            .shadow(color: Color(red: 0x8C / 255.0, green: 0x1E / 255.0, blue: 0x2A / 255.0).opacity(0.35), radius: 6, x: 0, y: 3)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
            
            // Footnote
            Text("Local text entry only — no live address verification.")
                .font(.barlowRegular(size: 12))
                .foregroundColor(Color("text_gary"))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(red: 0xEE / 255.0, green: 0xE8 / 255.0, blue: 0xDC / 255.0), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
    
    // MARK: - Actions
    
    private func submitNewAddress() {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = newAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            alertTitle = "Missing Name"
            alertMessage = "Please enter a label for this address (e.g. Home, Work)."
            showAlert = true
            return
        }
        
        guard !trimmedAddress.isEmpty else {
            alertTitle = "Missing Address"
            alertMessage = "Please enter a street address."
            showAlert = true
            return
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            addressManager.addAddress(
                name: trimmedName,
                address: trimmedAddress,
                deliveryInstructions: newDeliveryInstructions
            )
        }
        
        newName = ""
        newAddress = ""
        newDeliveryInstructions = ""
    }
    
    private func startEditing(_ item: SavedAddressItem) {
        editingAddressItem = item
        editName = item.name
        editAddress = item.address
        editDeliveryInstructions = item.deliveryInstructions ?? ""
        showEditSheet = true
    }
    
    // MARK: - Edit Address Sheet View
    
    private var editAddressSheetView: some View {
        NavigationView {
            ZStack {
                Color("app_background").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("Home, Work...", text: $editName)
                                .font(.barlowRegular(size: 15))
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Address")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("", text: $editAddress)
                                .font(.barlowRegular(size: 15))
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Delivery instructions")
                                .font(.barlowBold(size: 13.5))
                                .foregroundColor(Color("app_black"))
                            
                            TextField("", text: $editDeliveryInstructions)
                                .font(.barlowRegular(size: 15))
                                .foregroundColor(Color("app_black"))
                                .padding(.horizontal, 14)
                                .frame(height: 46)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 0xD8 / 255.0, green: 0xD1 / 255.0, blue: 0xC6 / 255.0), lineWidth: 1.2)
                                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white))
                                )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let item = editingAddressItem {
                            addressManager.updateAddress(
                                id: item.id,
                                name: editName,
                                address: editAddress,
                                deliveryInstructions: editDeliveryInstructions
                            )
                        }
                        showEditSheet = false
                    }
                    .font(.barlowBold(size: 16))
                    .foregroundColor(Color("Button_red"))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showEditSheet = false
                    }
                    .font(.barlowRegular(size: 16))
                    .foregroundColor(Color("text_gary"))
                }
            }
        }
    }
}

// MARK: - SwiftUI Preview

struct AddAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddAddressView(showHeader: true)
    }
}
