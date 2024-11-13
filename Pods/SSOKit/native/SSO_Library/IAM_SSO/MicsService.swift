//
//  MicsService.swift
//  SSOKit
//
//  Created by Sathish Kumar G on 16/01/24.
//

import Foundation

#if !os(watchOS)
class MicsService {
    
    let zuid: String
    lazy var preference: UserPreferenceCacheService = UserPreferenceCacheService(zuid: zuid)
    
    init(zuid: String) {
        self.zuid = zuid
    }
    
    public func getMicsNotification(completion: ((_ micsNotificationInfo: MicsNotificationInfo?, _ error: Error?) -> Void)? = nil) {
        
        guard let baseURL = ZIAMUtil.shared().getMicsBaseURL() else {
            completion?(nil, nil)
            return
        }
        let transformedURL = ZIAMUtil.shared().getTransformedURLString(forURL: baseURL) ?? baseURL
        let requestURL = transformedURL+"/MobileNotification"
        MicsApiHandler.shared.makeRequest(urlString: requestURL, params: ["Language": "en", "platform": "ios"]) { jsonResponse, error in
            if let err = error {
                debugPrint("ERROR: \(err)")
                completion?(nil, err)
                return
            }
            guard let response = jsonResponse else {
                completion?(nil, MicsAppError.invalidResponse)
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: response, options: [])
                let micNotificationInfo = try JSONDecoder().decode(MicsNotificationInfo.self, from: data)
                self.preference.cacheNotificationInfo(response)
                completion?(micNotificationInfo, nil)
            } catch let error {
                debugPrint("Mics Serialize ERROR: \(error)")
                completion?(nil, error)
            }
        }
    }
    
    public func updateMicsNotificationStatus(promotionId: String, deliveryStatus: MicsPromotionDeliveryStatus, _ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {
        
        guard let baseURL = ZIAMUtil.shared().getMicsBaseURL() else {
            return
        }
        let transformedURL = ZIAMUtil.shared().getTransformedURLString(forURL: baseURL) ?? baseURL
        let requestURL = transformedURL+"/MobileNotification"
        let params: [String: Any] = ["promotionid": promotionId, "feedback": deliveryStatus.rawValue]
        MicsApiHandler.shared.makePOSTRequest(urlString: requestURL, params: params) { jsonResponse, error in
            
            if let err = error {
                debugPrint("ERROR: \(err)")
                completion?(false, err)
                return
            }
            guard let response = jsonResponse else {
                completion?(false, MicsAppError.invalidResponse)
                return
            }
            completion?(true, nil)
        }
    }
}

extension MicsService {
    
    public func getCachedMicsNotificationInfo() -> MicsNotificationInfo? {
        guard let notificationInfoDict = preference.getNotificationInfo() else {
            return nil
        }
        return checkAndvalidateNotificationInfo(notificationInfoDict)
    }
    
    func checkAndvalidateNotificationInfo(_ notificationDict: [String: Any]) -> MicsNotificationInfo? {
        guard let requestCacheTime = notificationDict["apiRequestTime"] as? Int64, let notificationInfo = notificationDict["notificationInfo"] as? [String: Any] else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: notificationInfo, options: []), let micNotificationInfo = try? JSONDecoder().decode(MicsNotificationInfo.self, from: data) else {
            return nil
        }
        let notificationExpiresIn = Int64(micNotificationInfo.timeExpiresIn)
        let expiresTime = requestCacheTime + notificationExpiresIn
        let currentTimeInMilis = Date().timeInMillis
        guard currentTimeInMilis <= expiresTime else {
            preference.clearPreference()
            return nil
        }
        return micNotificationInfo
    }
    
    func clearCache() {
        preference.clearPreference()
    }
}

enum MicsPromotionDeliveryStatus: Int {
    case delivered = 2
    case ctaClicked = 3
    case dismissed = 4
}

enum MicsCTAAction {
    case deeplink(link: String)
    case weburl(url: String)
    case close
    
    init?(rawString: String, value: String) {
        switch rawString {
        case "deep link":
            self = .deeplink(link: value)
        case "web url":
            self = .weburl(url: value)
        case "close":
            self = .close
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .deeplink: return "deep link"
        case .weburl: return "web url"
        case .close: return "close"
        }
    }
}

// Model
public struct MicsNotificationInfo: Codable {
    
    let zuid: Int
    let timeout: Int
    let promotionID: String?
    let notificationDetails: NotificationDetails?
    let timeExpiresIn: Int

    enum CodingKeys: String, CodingKey {
        case zuid = "ZUID"
        case timeout = "Timeout"
        case promotionID = "PromotionId"
        case notificationDetails = "NotificationDetails"
        case timeExpiresIn = "AboutToExpireIn"
    }
}

// MARK: - NotificationDetails
public struct NotificationDetails: Codable {
    var position, htmlcontent, bannertype: String?
    var height, width: Int?
}

public class UserPreferenceCacheService {
    
    let preference: UserDefaults
    let zuid: String
    
    let suiteName: String = "MICS_NOTIFICATION_SERVICE"
    let notificationCacheKey: String = "MICS_NOTIFICATION_INFO_KEY"
    
    init(zuid: String) {
        self.zuid = zuid
        self.preference = UserDefaults(suiteName: "\(suiteName)_\(zuid)") ?? .standard
    }
    
    func cacheNotificationInfo(_ dict: [String: Any]) {
        var cacheDict: [String: Any] = ["apiRequestTime": Date().timeInMillis]
        cacheDict.updateValue(dict, forKey: "notificationInfo")
        self.preference.set(cacheDict, forKey: notificationCacheKey)
        self.preference.synchronize()
    }
    
    func getNotificationInfo() -> [String: Any]? {
        return self.preference.dictionary(forKey: notificationCacheKey)
    }
    
    func clearPreference() {
        self.preference.removeSuite(named: "\(suiteName)_\(zuid)")
        self.preference.removeObject(forKey: notificationCacheKey)
        self.preference.synchronize()
    }
}

extension Date {
    var timeInMillis: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
#endif
