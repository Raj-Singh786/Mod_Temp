//
//  StoreLocationScreen.swift
//  MOD
//
//  Created by Rajpal singh on 07/11/26.
//

import SwiftUI
import MapKit

struct StoreLocationScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - State
    @State private var searchAddress: String = "Market St, San Francisco, CA"
    @State private var selectedOrderType: OrderType = .delivery
    @State private var isOrderTypeExpanded: Bool = true
    @State private var selectedTimePreference: TimePreference = .asap
    @State private var selectedStoreId: String = "#1204"
    
    // Map Region centered in San Francisco
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7879, longitude: -122.4075),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )

    // Store Annotations for Map
    private let mapStores: [StorePin] = [
        StorePin(id: "#1204", name: "Downtown Hut", coordinate: CLLocationCoordinate2D(latitude: 37.7899, longitude: -122.4015), isSelected: true),
        StorePin(id: "#0988", name: "Westside Pavilion", coordinate: CLLocationCoordinate2D(latitude: 37.7910, longitude: -122.4180), isSelected: false),
        StorePin(id: "#1442", name: "North Metro Express", coordinate: CLLocationCoordinate2D(latitude: 37.7990, longitude: -122.4080), isSelected: false)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // MARK: - Top Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 38, height: 38)
                            .background(Color(red: 0.95, green: 0.96, blue: 0.98))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Choose Your Order Type")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible counter-balance
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(Color.white)

                // MARK: - Scrollable Form Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // 1. Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            TextField("Enter street, city or zip", text: $searchAddress)
                                .font(.system(size: 14))
                            
                            if !searchAddress.isEmpty {
                                Button(action: { searchAddress = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )

                        // 2. Use Current Location Row
                        Button(action: {}) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.08))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "scope")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                                
                                Text("Use current location")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(red: 0.12, green: 0.65, blue: 0.38))
                                        .frame(width: 6, height: 6)
                                    Text("Accurate to 15m")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                                }
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }

                        // 3. Order Type Section (Carryout vs Delivery)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("ORDER TYPE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(red: 0.12, green: 0.65, blue: 0.38))
                                        .frame(width: 6, height: 6)
                                    Text(selectedOrderType == .carryout ? "Carryout Selected" : "Delivery Selected")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                                }
                            }

                            // Outer Border Card
                            VStack(spacing: 10) {
                                // Top Header Row
                                HStack(alignment: .center, spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 0.85, green: 0.08, blue: 0.18))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: "bag.fill")
                                            .font(.system(size: 17))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text("Carryout / Pickup")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("FREE")
                                                .font(.system(size: 10, weight: .heavy))
                                                .foregroundColor(.red)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.red.opacity(0.08))
                                                .cornerRadius(4)
                                        }
                                        Text("Ready in 10–15 mins • 3 stores nearby")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation { isOrderTypeExpanded.toggle() }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 0.98, green: 0.92, blue: 0.94))
                                                .frame(width: 28, height: 28)
                                            Image(systemName: isOrderTypeExpanded ? "chevron.up" : "chevron.down")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.red)
                                        }
                                    }
                                }

                                if isOrderTypeExpanded {
                                    // Carryout Active Subcard
                                    Button(action: {
                                        withAnimation {
                                            selectedOrderType = .carryout
                                            UserDefaults.standard.set("pickup", forKey: "selectedOrderType")
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedOrderType == .carryout ? Color(red: 0.85, green: 0.08, blue: 0.18) : Color.gray.opacity(0.1))
                                                    .frame(width: 34, height: 34)
                                                Image(systemName: "bag.fill")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(selectedOrderType == .carryout ? .white : .gray)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack(spacing: 6) {
                                                    Text("Carryout / Pickup")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.black)
                                                    if selectedOrderType == .carryout {
                                                        Text("ACTIVE")
                                                            .font(.system(size: 10, weight: .heavy))
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.red)
                                                            .cornerRadius(4)
                                                    }
                                                }
                                                Text("Free • Ready in 10–15 mins • 3 stores nearby")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: selectedOrderType == .carryout ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(selectedOrderType == .carryout ? .red : .gray.opacity(0.4))
                                        }
                                        .padding(12)
                                        .background(selectedOrderType == .carryout ? Color(red: 1.0, green: 0.98, blue: 0.98) : Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedOrderType == .carryout ? Color.red : Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }

                                    // Delivery Subcard
                                    Button(action: {
                                        withAnimation {
                                            selectedOrderType = .delivery
                                            UserDefaults.standard.set("delivery", forKey: "selectedOrderType")
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedOrderType == .delivery ? Color(red: 0.85, green: 0.08, blue: 0.18) : Color.gray.opacity(0.1))
                                                    .frame(width: 34, height: 34)
                                                Image(systemName: "box.truck.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(selectedOrderType == .delivery ? .white : .gray)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack(spacing: 6) {
                                                    Text("Delivery")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.black)
                                                    Text("~$2.99 fee")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.gray)
                                                    if selectedOrderType == .delivery {
                                                        Text("ACTIVE")
                                                            .font(.system(size: 10, weight: .heavy))
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.red)
                                                            .cornerRadius(4)
                                                    }
                                                }
                                                Text("35–45 mins • Delivered straight to your door")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: selectedOrderType == .delivery ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(selectedOrderType == .delivery ? .red : .gray.opacity(0.4))
                                        }
                                        .padding(12)
                                        .background(selectedOrderType == .delivery ? Color(red: 1.0, green: 0.98, blue: 0.98) : Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedOrderType == .delivery ? Color.red : Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.red, lineWidth: 1.5)
                            )
                        }

                        // 4. Map View with Store Pins
                        ZStack(alignment: .bottomTrailing) {
                            Map(coordinateRegion: $region, annotationItems: mapStores) { store in
                                MapAnnotation(coordinate: store.coordinate) {
                                    if store.id == selectedStoreId {
                                        HStack(spacing: 4) {
                                            Image(systemName: "mappin.fill")
                                                .font(.system(size: 11))
                                            Text("\(store.name) • 0.8 mi")
                                                .font(.system(size: 11, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.red)
                                        .cornerRadius(14)
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 28, height: 28)
                                                .shadow(radius: 2)
                                            Circle()
                                                .stroke(Color.red, lineWidth: 1.5)
                                                .frame(width: 28, height: 28)
                                            Image(systemName: "storefront.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .frame(height: 175)
                            .cornerRadius(16)
                            .clipped()

                            // Floating Re-center Button
                            Button(action: {
                                withAnimation {
                                    region.center = CLLocationCoordinate2D(latitude: 37.7899, longitude: -122.4015)
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .frame(width: 38, height: 38)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                            .padding(10)
                        }

                        // 5. Ready Time Preference
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.red)
                                    Text("Ready Time Preference")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Text("Fastest Pickup")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                            }

                            HStack(spacing: 12) {
                                // ASAP
                                Button(action: { selectedTimePreference = .asap }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.red)
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("ASAP")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("10–15 mins")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.red)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedTimePreference == .asap ? "record.circle.fill" : "circle")
                                            .font(.system(size: 16))
                                            .foregroundColor(selectedTimePreference == .asap ? .red : .gray.opacity(0.4))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTimePreference == .asap ? Color(red: 1.0, green: 0.97, blue: 0.97) : Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedTimePreference == .asap ? Color.red : Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }

                                // Schedule
                                Button(action: { selectedTimePreference = .schedule }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text("Schedule")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.black)
                                            Text("Choose slot")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedTimePreference == .schedule ? "record.circle.fill" : "circle")
                                            .font(.system(size: 16))
                                            .foregroundColor(selectedTimePreference == .schedule ? .red : .gray.opacity(0.4))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTimePreference == .schedule ? Color(red: 1.0, green: 0.97, blue: 0.97) : Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedTimePreference == .schedule ? Color.red : Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                        }

                        // 6. Pickup Stores Near You List
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Pickup Stores Near You")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.black)
                                Text("(12 nearby)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    HStack(spacing: 2) {
                                        Text("View All")
                                            .font(.system(size: 13, weight: .semibold))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .semibold))
                                    }
                                    .foregroundColor(.red)
                                }
                            }

                            // Store 1: Downtown Hut (Selected)
                            StoreItemCard(
                                name: "Downtown Hut",
                                storeId: "#1204",
                                address: "452 Market St, San Francisco, CA",
                                timeText: "10–15 min",
                                distanceText: "0.8 mi",
                                hoursText: "Open until 11:00 PM",
                                isSelected: selectedStoreId == "#1204",
                                doughReady: true,
                                hasCurbside: true,
                                hasDriveThru: true,
                                cutoffText: "Cutoff: 10:45 PM",
                                onSelect: { selectedStoreId = "#1204" }
                            )

                            // Store 2: Westside Pavilion
                            StoreItemCard(
                                name: "Westside Pavilion",
                                storeId: "#0988",
                                address: "1204 Pine Ave, San Francisco, CA",
                                timeText: "15–20 min",
                                distanceText: "2.1 mi",
                                hoursText: "Open until 10:30 PM",
                                isSelected: selectedStoreId == "#0988",
                                doughReady: false,
                                hasCurbside: true,
                                hasDriveThru: false,
                                cutoffText: "Curbside only",
                                onSelect: { selectedStoreId = "#0988" }
                            )

                            // Store 3: North Metro Express
                            StoreItemCard(
                                name: "North Metro Express",
                                storeId: "#1442",
                                address: "880 Broadway, San Francisco, CA",
                                timeText: "30 min",
                                distanceText: "3.4 mi",
                                hoursText: "Open until 10:00 PM",
                                isSelected: selectedStoreId == "#1442",
                                doughReady: true,
                                hasCurbside: false,
                                hasDriveThru: false,
                                cutoffText: "Carryout Counter",
                                onSelect: { selectedStoreId = "#1442" }
                            )
                        }

                        // Bottom margin for floating bar
                        Color.clear.frame(height: 90)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }

            // MARK: - Bottom Floating Action Bar
            VStack(spacing: 8) {
                // Status Summary Line
                HStack {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 0.12, green: 0.65, blue: 0.38))
                            .frame(width: 6, height: 6)
                        Text(selectedOrderType == .carryout ? "Carryout •" : "Delivery •")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                        Text(selectedStoreName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("ASAP • 10–15 min")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.65, blue: 0.38))
                }
                .padding(.horizontal, 20)

                // Big Red Button
                Button(action: handleOpenLocationInMap) {
                    HStack(spacing: 8) {
                        Image(systemName: "map")
                            .font(.system(size: 16, weight: .bold))
                        Text("Open Location in Map")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.red)
                    .cornerRadius(16)
                    .shadow(color: Color.red.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(
                Color.white
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
            )
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.99).edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .onAppear {
            let saved = UserDefaults.standard.string(forKey: "selectedOrderType")
            if saved == "pickup" {
                selectedOrderType = .carryout
            } else {
                selectedOrderType = .delivery
            }
        }
    }

    private var selectedStoreName: String {
        switch selectedStoreId {
        case "#1204": return "Downtown Hut"
        case "#0988": return "Westside Pavilion"
        case "#1442": return "North Metro Express"
        default: return "Downtown Hut"
        }
    }

    private func handleOpenLocationInMap() {
        // Save current selection to UserDefaults
        UserDefaults.standard.set(selectedOrderType == .carryout ? "pickup" : "delivery", forKey: "selectedOrderType")

        // Open Apple Maps with selected store coordinate
        let coord: CLLocationCoordinate2D
        switch selectedStoreId {
        case "#0988":
            coord = CLLocationCoordinate2D(latitude: 37.7910, longitude: -122.4180)
        case "#1442":
            coord = CLLocationCoordinate2D(latitude: 37.7990, longitude: -122.4080)
        default:
            coord = CLLocationCoordinate2D(latitude: 37.7899, longitude: -122.4015)
        }
        
        let placemark = MKPlacemark(coordinate: coord)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = selectedStoreName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Store Item Card Component

struct StoreItemCard: View {
    let name: String
    let storeId: String
    let address: String
    let timeText: String
    let distanceText: String
    let hoursText: String
    let isSelected: Bool
    let doughReady: Bool
    let hasCurbside: Bool
    let hasDriveThru: Bool
    let cutoffText: String
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Row: Name, Badges, Select Button
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                    
                    if isSelected {
                        Text("Selected")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(4)
                    }
                    
                    Text(storeId)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.red)
                } else {
                    Button(action: onSelect) {
                        Text("Select")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.3))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }

            // Address
            Text(address)
                .font(.system(size: 13))
                .foregroundColor(.gray)

            // Status Row
            HStack(spacing: 5) {
                if isSelected {
                    Circle()
                        .fill(Color(red: 0.12, green: 0.65, blue: 0.38))
                        .frame(width: 5, height: 5)
                }
                Text(timeText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? Color(red: 0.12, green: 0.65, blue: 0.38) : .black)
                Text("•")
                    .foregroundColor(.gray)
                Text(distanceText)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text("•")
                    .foregroundColor(.gray)
                Text(hoursText)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            // Availability Mint Banner
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.12, green: 0.62, blue: 0.38))
                    Text("All items are available")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.12, green: 0.62, blue: 0.38))
                }
                
                Spacer()
                
                Text(doughReady ? "Fresh dough ready" : "Ready in 15 to 20Min")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(red: 0.90, green: 0.98, blue: 0.94))
            .cornerRadius(8)

            // Service Badges
            HStack(spacing: 8) {
                if hasCurbside {
                    HStack(spacing: 4) {
                        Text("🚗")
                            .font(.system(size: 11))
                        Text("Curbside")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.45))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.94, green: 0.96, blue: 0.98))
                    .cornerRadius(6)
                }

                if hasDriveThru {
                    HStack(spacing: 4) {
                        Text("🏪")
                            .font(.system(size: 11))
                        Text("Drive–thru")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.1))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.99, green: 0.96, blue: 0.90))
                    .cornerRadius(6)
                }
            }

            // Footer Row
            HStack {
                HStack(spacing: 2) {
                    Text("Store Hours & Nutrition")
                        .font(.system(size: 12, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(isSelected ? .red : .gray)

                Spacer()

                Text(cutoffText)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.red : Color.gray.opacity(0.18), lineWidth: isSelected ? 1.5 : 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Enums & Models

enum OrderType {
    case carryout
    case delivery
}

enum TimePreference {
    case asap
    case schedule
}

struct StorePin: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isSelected: Bool
}

#Preview {
    StoreLocationScreen()
}
