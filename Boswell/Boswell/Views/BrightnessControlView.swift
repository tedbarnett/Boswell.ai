//
//  BrightnessControlView.swift
//  Boswell
//
//  Created by MyMac on 01/05/23.
//

import UIKit

protocol BrightnessControlViewDelegate: NSObjectProtocol {
    func brightnessControlViewDidChange(brightness: Float)
}

class BrightnessControlView: UIView {
    weak var delegate: BrightnessControlViewDelegate?
    var brightness: Float = 1
    @IBOutlet weak var sliderBrightness: UISlider! {
        didSet{
            sliderBrightness.transform = CGAffineTransform(rotationAngle: -.pi/2)
        }
    }
    
    class func fromNib() -> BrightnessControlView {
        return Bundle(for: BrightnessControlView.self).loadNibNamed(String(describing: BrightnessControlView.self), owner: nil, options: nil)![0] as! BrightnessControlView
    }
    
    func setupUI(brightness: Float) {
        self.brightness = (1 - brightness)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        self.sliderBrightness.value = self.brightness
    }
    
    
    @IBAction func sliderBrightnessChanged(_ sender: Any) {
        self.delegate?.brightnessControlViewDidChange(brightness: (1 - sliderBrightness.value))
    }
    
}
