//
//  AddViewController.swift
//  Botch
//
//  Created by Martin Velev on 8/20/20.
//

import UIKit
import UIColor_Hex_Swift

class AddViewController: UIViewController, UITextFieldDelegate, ColorPickerDelegate {
    func didGetColor(color: String, isItForBackground: Bool) {
        if isItForBackground == true {
            self.backgroundColor = color
        } else {
            self.titleColor = color
        }
    }
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var results: UITextField!
    
    public var completion: ((String, String, String, String) -> Void)?
    var isItBeingEdited: Bool = false
    var theExsistingTitle = String()
    var theExsistingResults = String()
    let color = ColorSelectViewController()
    var backgroundColor = String()
    var titleColor = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        results.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    
    @IBAction func pickTitleColor(_ sender: Any) {
        color.isItBackgroundColor = false
        // let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard?.instantiateViewController(withIdentifier: "ColorSelectViewController") as! ColorSelectViewController
        vc.isItBackgroundColor = false
        vc.delegate = self
        vc.color = UIColor(titleColor)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func pickBackgroundColor(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ColorSelectViewController") as! ColorSelectViewController
        vc.delegate = self
        vc.isItBackgroundColor = true
        vc.color = UIColor(backgroundColor)
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isItBeingEdited == true {
            DispatchQueue.main.async {
                self.titleField.text = self.theExsistingTitle
                self.results.text = self.theExsistingResults
            }
        }
    }
    
    @objc func cancel() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty, let resultText = results.text, !resultText.isEmpty {
            print("the title color: \(titleColor). The background color: \(backgroundColor)")
            // str.prefix(2) == "He"
            if backgroundColor.prefix(1) != "#" && titleColor.prefix(1) == "#" {
                let color = UIColor.random()
                backgroundColor = color.hexString()
            } else if backgroundColor.prefix(1) != "#" && titleColor.prefix(2) != "#" {
                let color = UIColor.random()
                backgroundColor = color.hexString()
                if color.isLight {
                    self.titleColor = UIColor.black.hexString()
                } else {
                    self.titleColor = UIColor.white.hexString()
                }
            } else if backgroundColor.prefix(1) == "#" && titleColor.prefix(1) != "#" {
                if UIColor(backgroundColor).isLight {
                    self.titleColor = UIColor.black.hexString()
                } else {
                    self.titleColor = UIColor.white.hexString()
                }
            }
            completion?(titleText, resultText, backgroundColor, titleColor)
        } else if titleField.text!.isEmpty && !results.text!.isEmpty {
            showPleaseTypeACategory()
        } else if !titleField.text!.isEmpty && results.text!.isEmpty {
            showPleaseTypeAResult()
        } else if titleField.text!.isEmpty && results.text!.isEmpty {
            showPleaseTypeSomething()
        } // Else if isn't a good idea but eh.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func showPleaseTypeACategory() {
        
            // create the alert
        let alert = UIAlertController(title: "Error", message: "Please type a category name!", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    func showPleaseTypeAResult() {
        
            // create the alert
        let alert = UIAlertController(title: "Error", message: "Please type some results!", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    func showPleaseTypeSomething() {
        let alert = UIAlertController(title: "Error", message: "You need to type a category name and results!", preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }

}
