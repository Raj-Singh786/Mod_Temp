//
//  UserDefaults+Extension.swift
//  Rmpl
//
//  Created by Rajpal singh on 03/09/26.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
       case userDetails
        case isLoggedIn
        case isMorningAttendance
}
    
    enum DayStatus: Int {
        case attendenceNotMarked = 0
        case AttendanceMarked = 1
        case dayEnded = 2
    }
    
//    var userDetails: LoginModel? {
//        get {
//            if let data = data(forKey: UserDefaultsKeys.userDetails.rawValue) {
//                return try? JSONDecoder().decode(LoginModel.self, from: data)
//            }
//            return nil
//        }
//        set {
//            if let newValue = newValue {
//                let data = try? JSONEncoder().encode(newValue)
//                set(data, forKey: UserDefaultsKeys.userDetails.rawValue)
//            } else {
//                removeObject(forKey: UserDefaultsKeys.userDetails.rawValue)
//            }
//        }
//    }
    
//    var isLoggedIn: Bool {
//        get {
//            return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
//        }
//         set {
//            set(newValue, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
//        }
//    }
    
    
    
    var dayStatus: DayStatus {
           get { DayStatus(rawValue: integer(forKey: "dayStatus")) ?? .dayEnded }
           set { set(newValue.rawValue, forKey: "dayStatus") }
       }
}
