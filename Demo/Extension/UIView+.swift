//
//  UIView+.swift
//  Demo
//
//  Created by can.khac.nguyen on 7/31/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorner(value: CGFloat) {
        layer.cornerRadius = value
        layer.masksToBounds = true
    }

    func roundView() {
        roundCorner(value: self.bounds.height / 2)
    }

    func dropShadow(color: UIColor = .darkGray, offset: CGSize = CGSize(width: 2, height: 2), opacity: Float = 0.8,
                    shadowRadius: CGFloat = 2, cornerRadius: CGFloat = 0) {
        removeAllShapeLayer()
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor

        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = offset
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius

        layer.insertSublayer(shadowLayer, at: 0)
    }

    func removeAllShapeLayer() {
        guard let sublayers = layer.sublayers else { return }
        for layer in sublayers where layer is CAShapeLayer {
            layer.removeFromSuperlayer()
        }
    }

    func edges(to view: UIView, top: CGFloat=0, left: CGFloat=0, bottom: CGFloat=0, right: CGFloat=0) {
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
            ])
    }
}
