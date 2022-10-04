//
//  GradientButton.swift
//  SecretGallery
//
//  Created by Антон Стафеев on 04.10.2022.
//

import UIKit

class GradientButton: UIButton {
    
    let gradient = CAGradientLayer()
    
    init(colors: [CGColor]) {
        super.init(frame: .zero)
        gradient.frame = bounds
        gradient.colors = colors
        gradient.cornerRadius = 10
        gradient.borderColor = UIColor.darkGray.cgColor
        gradient.borderWidth = 1
        
        gradient.shadowRadius = 10
        gradient.shadowColor   = UIColor.systemMint.cgColor
        gradient.shadowOpacity = 0.8
        layer.addSublayer(gradient)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
