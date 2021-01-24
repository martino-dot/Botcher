//
//  ColorSelectViewController.swift
//  Botch
//
//  Created by Martin Velev on 8/21/20.
//

import UIKit
import ChromaColorPicker
import UIColor_Hex_Swift

class ColorSelectViewController: UIViewController, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var selectButton: UIButton!
    weak var delegate: ColorPickerDelegate?
    var color: UIColor?
    var isItBackgroundColor = Bool()
    
    var brightnessSlider = ChromaBrightnessSlider(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
    
    @IBAction func didTapSaveButton() {
        color = brightnessSlider.currentColor
        let color = UIColor(cgColor: self.color!.cgColor).hexString()
        delegate?.didGetColor(color: color, isItForBackground: isItBackgroundColor)
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        colorPicker.center = CGPoint(x: self.view.frame.size.width / 2, y: (self.view.frame.size.height / 2) - 95)
        brightnessSlider.center = CGPoint(x: self.view.frame.size.width / 2, y: (self.view.frame.size.height / 2) + 40)
        selectButton.center = CGPoint(x: self.view.frame.size.width / 2, y: (self.view.frame.size.height / 2) + 115)
        if color == nil {
            let peachColor = UIColor(red: 1, green: 203 / 255, blue: 164 / 255, alpha: 1)
            colorPicker.addHandle()
            self.view.addSubview(colorPicker)
            brightnessSlider.trackColor = peachColor
            self.view.addSubview(brightnessSlider)
            colorPicker.connect(brightnessSlider)
        } else {
            colorPicker.addHandle()
            self.view.addSubview(colorPicker)
            self.view.addSubview(brightnessSlider)
            brightnessSlider.trackColor = color!
            colorPicker.connect(brightnessSlider)
        }
    }

}

protocol ColorPickerDelegate: AnyObject {
    func didGetColor(color: String, isItForBackground: Bool)
}
