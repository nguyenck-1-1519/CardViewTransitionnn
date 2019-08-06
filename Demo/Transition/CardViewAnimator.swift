//
//  CardViewAnimator.swift
//  Demo
//
//  Created by can.khac.nguyen on 8/5/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit

final class CardViewAnimator: UIViewPropertyAnimator {

    init(with input: CardViewTransitionInput) {
        let cardPositionY = input.cardViewFrame.minY
        let distanceToBounce = abs(input.cardViewFrame.minY)
        let extentToBounce = cardPositionY < 0 ? input.cardViewFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.5
        let damping: CGFloat = 1.0 - dampFactorInterval * (distanceToBounce / extentToBounce)

        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce)/UIScreen.main.bounds.height)

        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        super.init(duration: duration, timingParameters: springTiming)
    }
    
}
