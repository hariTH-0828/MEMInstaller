//
//  MicsKit.swift
//  SSOKit-SSOKitBundle
//
//  Created by Sathish Kumar G on 16/01/24.
//

import UIKit

#if !os(watchOS)
protocol MicsKitDelegate: NSObject {
    func didUpdateMicsNotificationStatus(promotionId: String, deliveryStatus: MicsPromotionDeliveryStatus)
    func didTriggerCTAHandler(promotionId: String, micsAction: MicsCTAAction)
}

@objcMembers
public class MicsKit: NSObject {
    
    var micsService: MicsService?
    
    @objc
    public static let shared: MicsKit = MicsKit()
    
    override init() {
        guard let zuid =  ZSSOKit.getCurrentUser()?.userZUID else {
            return
        }
        self.micsService = MicsService(zuid: zuid)
    }
        
    public func showMicsNotification(parent: UIViewController) {
        guard let micsNotificationInfo = micsService?.getCachedMicsNotificationInfo() else {
            micsService?.getMicsNotification()
            return
        }
        DispatchQueue.main.async {
            self.showMicsNotificationPopUp(micsNotificationInfo: micsNotificationInfo, parent: parent)
            self.clearMICSCache()
        }
    }
            
    private func showMicsNotificationPopUp(micsNotificationInfo: MicsNotificationInfo, parent: UIViewController) {
        guard let micsNotificationViewController = MicsNotificationPopUpViewController.instantiate() else {
            return
        }
        micsNotificationViewController.micsNotificationInfo = micsNotificationInfo
        micsNotificationViewController.delegate = self
        micsNotificationViewController.modalPresentationStyle = .overFullScreen
        parent.present(micsNotificationViewController, animated: true)
    }
    
    public func clearMICSCache() {
        micsService?.clearCache()
    }
}

extension MicsKit: MicsKitDelegate {
    
    func didUpdateMicsNotificationStatus(promotionId: String, deliveryStatus: MicsPromotionDeliveryStatus) {
        micsService?.updateMicsNotificationStatus(promotionId: promotionId, deliveryStatus: deliveryStatus)
    }
    
    func didTriggerCTAHandler(promotionId: String, micsAction: MicsCTAAction) {
        switch micsAction {
        case .deeplink(let url), .weburl(let url):
            guard let url = URL(string: url), ZIAMUtil.shared().canOpen(url) else { return }
            didUpdateMicsNotificationStatus(promotionId: promotionId, deliveryStatus: .ctaClicked)
            ZIAMUtil.shared().open(url)
        case .close:
            didUpdateMicsNotificationStatus(promotionId: promotionId, deliveryStatus: .dismissed)
        }
    }
}
#endif
