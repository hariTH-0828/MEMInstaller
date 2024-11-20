//
//  MicsNotificationPopUpViewController.swift
//  SSOKit-SSOKitBundle
//
//  Created by Sathish Kumar G on 16/01/24.
//

import UIKit
#if canImport(WebKit)
import WebKit
#endif

#if !os(watchOS)
class MicsNotificationPopUpViewController: UIViewController {
    
    var micsNotificationInfo: MicsNotificationInfo?
    weak var delegate: MicsKitDelegate?
    
    /// The POP-UP view has 60% of  parent view.
    @IBOutlet weak var popupView: UIView! {
        didSet {
            popupView.layer.cornerRadius = 10
            popupView.clipsToBounds = true
        }
    }
    @IBOutlet weak var webKitView: WKWebView! {
        didSet {
            webKitView.scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    @IBOutlet weak var verticalYCons: NSLayoutConstraint!
    @IBOutlet weak var popupHeightCons: NSLayoutConstraint!
    @IBOutlet weak var popupWidthCons: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        configureHTMLScript()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if let notificationInfo = self.micsNotificationInfo, let promotionId = notificationInfo.promotionID {
                self.delegate?.didUpdateMicsNotificationStatus(promotionId: promotionId, deliveryStatus: .delivered)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePopupPosition()

        popupView.layer.cornerRadius = 10
        popupView.clipsToBounds = true
    }
    
    static func instantiate() -> MicsNotificationPopUpViewController? {
        guard let bundelURL = Bundle(for: self.classForCoder()).resourceURL, let bundle = Bundle(url: bundelURL.appendingPathComponent("SSOKitBundle.bundle")) else {
            return nil
        }
        let ssoStroyboard = UIStoryboard(name: "SSOStoryboard", bundle: bundle)
        guard let micsNotificationViewController = ssoStroyboard.instantiateViewController(withIdentifier: "MicsNotificationPopUpViewController") as? MicsNotificationPopUpViewController else {
            return nil
        }
        return micsNotificationViewController
    }
    
    private func updatePopupPosition() {
        guard let notificationDetails = micsNotificationInfo?.notificationDetails,
                let position = notificationDetails.position else {
            return
        }
        
        let viewHt = self.view.frame.height
        let emptySpaceHt = viewHt - popupView.frame.height
        let popupPosition = (emptySpaceHt/2)/2
        
        switch position.lowercased() {
        case "top": verticalYCons.constant = -popupPosition + 35
        case "bottom": verticalYCons.constant = popupPosition - 20
        default: break
        }
        popupView.setNeedsLayout()
    }
    
    private func configureHTMLScript() {
        webKitView.navigationDelegate = self
        if let notificationDetails = micsNotificationInfo?.notificationDetails, let htmlcontent = notificationDetails.htmlcontent {
            webKitView.loadHTMLString(htmlcontent, baseURL: nil)
            if let height = notificationDetails.height {
                self.popupHeightCons.constant = self.view.frame.height * CGFloat(Double(height)/100)
            }
            if let width = notificationDetails.width {
                self.popupWidthCons.constant = self.view.frame.width * CGFloat(Double(width)/100)
            }
        }
        webKitView.configuration.userContentController.add(self, name: "ctaAction")
    }
}

extension MicsNotificationPopUpViewController: WKNavigationDelegate, WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let notificationInfo = self.micsNotificationInfo, let promotionID = notificationInfo.promotionID else {
            return
        }
        if message.name == "ctaAction", let body = message.body as? String {
            debugPrint("CTA Button Tapped: \(body)")
            guard let data = body.data(using: .utf8) else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any], let buttonAction = json["buttonAction"] as? String, let buttonValue = json["buttonValue"] as? String {
                    if let micsAction = MicsCTAAction.init(rawString: buttonAction, value: buttonValue) {
                        self.dismiss(animated: true) { [weak self] in
                            self?.delegate?.didTriggerCTAHandler(promotionId: promotionID, micsAction: micsAction)
                        }
                    }
                }
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
}
#endif
