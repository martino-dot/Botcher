//
//  FeedbackViewController.swift
//  Botch
//
//  Created by Martin Velev on 7/3/20.
//

import UIKit
import Valet
import SwiftyStoreKit

class FeedbackViewController: UIViewController {
    
    @IBAction func privacyPolicy(_ sender: Any) {
        if let url = URL(string: "https://blurrmc.com/Botcher/Privacy-policy/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func termsOfService(_ sender: Any) {
        if let url = URL(string: "https://blurrmc.com/Botcher/Terms-of-service/") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func openGithubProject(_ sender: Any) {
        if let url = URL(string: "https://github.com/martino-dot/botcher") {
            UIApplication.shared.open(url)
        }
    }
    
    let myValet = Valet.valet(with: Identifier(nonEmpty: "Purchased")!, accessibility: .whenUnlocked)
    
    @IBOutlet weak var restoreButtonOutlet: UIButton!
    @IBOutlet weak var purchaseButtonOutlet: UIButton!
    @IBOutlet weak var githubProjectImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(openGithubProject(_:)))
        githubProjectImage.addGestureRecognizer(imageGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let userId: String? = try? myValet.string(forKey: "Purchased")
        if userId == "true" {
            self.purchaseButtonOutlet.isEnabled = false
            self.purchaseButtonOutlet.setTitle("Subscribed", for: .normal)
            self.restoreButtonOutlet.isEnabled = false
            self.purchaseButtonOutlet.setTitleColor(UIColor.gray, for: .disabled)
            self.restoreButtonOutlet.setTitleColor(UIColor.gray, for: .disabled)
        }
    }
    
    func restoreProduct() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.showMessage(title: "Restore Failed", message: "The restore has failed. Try again later.", action: "OK")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                try? self.myValet.setString("true", forKey: "Purchased")
                self.showMessage(title: "Your all set!", message: "The restore was successful!", action: "OK")
                DispatchQueue.main.async {
                    self.parent?.dismiss(animated: true, completion: nil)
                }
            }
            else {
                print("Nothing to Restore")
                self.showMessage(title: "Error", message: "There is nothing to restore.", action: "OK")
            }
        }
    }
    
    func purchaseProduct() {
        SwiftyStoreKit.purchaseProduct("com.blurrmc.botcher.support", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                try? self.myValet.setString("true", forKey: "Purchased")
                self.showMessage(title: "Your all set!", message: "Your purchase has been successful. Thank you!", action: "OK")
                DispatchQueue.main.async {
                    self.purchaseButtonOutlet.isEnabled = false
                    self.restoreButtonOutlet.isEnabled = false
                    self.purchaseButtonOutlet.setTitleColor(UIColor.gray, for: .disabled)
                    self.restoreButtonOutlet.setTitleColor(UIColor.gray, for: .disabled)
                }
            case .error(let error):
                switch error.code {
                case .unknown:
                    self.showMessage(title: "Error", message: "An unkown error has occured.", action: "OK")
                    print("Unkown error")
                case .clientInvalid:
                    try? self.myValet.setString("false", forKey: "Purchased")
                    self.showMessage(title: "Error", message: "You are not allowed to make the payment.", action: "OK")
                    print("Not allowed to make the payment")
                case .paymentCancelled:
                    try? self.myValet.setString("false", forKey: "Purchased")
                case .paymentInvalid:
                    self.showMessage(title: "Error", message: "Purchase identifier was invalid. Try again later.", action: "OK")
                    print("The purchase identifier was invalid")
                case .paymentNotAllowed:
                    try? self.myValet.setString("false", forKey: "Purchased")
                    self.showMessage(title: "Error", message: "This device is not allowed to make payments.", action: "OK")
                    print("The device is not allowed to make the payment")
                case .storeProductNotAvailable:
                    try? self.myValet.setString("false", forKey: "Purchased")
                    self.showMessage(title: "Error", message: "The subscription is not available in your storefront.", action: "OK")
                    print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied:
                    try? self.myValet.setString("false", forKey: "Purchased")
                    self.showMessage(title: "Error", message: "Access to cloud service is not allowed.", action: "OK")
                    print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    self.showMessage(title: "Error", message: "Could not connect to the network.", action: "OK")
                    print("Could not connect to the network")
                case .cloudServiceRevoked:
                    try? self.myValet.setString("false", forKey: "Purchased")
                    print("User has revoked permission to use this cloud service")
                default:
                    print((error as NSError).localizedDescription)
                }
            }
        }
    }

    @IBAction func purchaseButton(_ sender: Any) {
        purchaseProduct()
    }
    @IBAction func restoreButton(_ sender: Any) {
        restoreProduct()
    }
    func showMessage(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
        alert.addAction(UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    private func updateFetchingIndicator(isVisible: Bool) {
            if isVisible {
                let indicatorView = UIActivityIndicatorView(style: .medium)
                indicatorView.startAnimating()
                
                let barButtonItem = UIBarButtonItem(customView: indicatorView)
                
                self.navigationItem.rightBarButtonItem = barButtonItem
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    
}
