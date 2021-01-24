//
//  ResultsViewController.swift
//  Botch
//
//  Created by Martin Velev on 7/3/20.
//

import UIKit

class ResultsViewController: UIViewController {
    
    // MARK: Constants and Variables
    var topic = String()
    var customArray = [String]()
    
    func getResults() {
        resultPicker()
        let color = UIColor.random()
        super.view.backgroundColor = color
        switch color.isLight {
        case false:
            self.resultText.textColor = .white
        case true:
            self.resultText.textColor = .black
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        getResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getResults()
    }
    
    func resultPicker() {
        resultText.text = self.customArray.randomElement()
    }
    @IBOutlet weak var resultText: UILabel!
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
    
}
extension UIColor {

    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
