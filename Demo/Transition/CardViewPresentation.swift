//
//  CardViewTransition.swift
//  Demo
//
//  Created by can.khac.nguyen on 7/31/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit

struct CardViewTransitionInput {
    let cardViewFrame: CGRect
    let cell: UITableViewCell
}

final class CardViewPresentation: NSObject, UIViewControllerAnimatedTransitioning {

    let input: CardViewTransitionInput

    private let animationDuration: TimeInterval
    private let animationDamping: CGFloat
    private let isUsingFrame = false

    init(input: CardViewTransitionInput) {
        self.input = input
        let animationInfo = CardViewPresentation.calculateTimeAndDampingValue(from: input)
        self.animationDamping = animationInfo.damping
        self.animationDuration = animationInfo.time
        super.init()
    }
    
    private static func calculateTimeAndDampingValue(from input: CardViewTransitionInput) -> (time: TimeInterval, damping: CGFloat) {
        let cardPositionY = input.cardViewFrame.minY
        let distanceToBounce = abs(input.cardViewFrame.minY)
        let extentToBounce = cardPositionY < 0 ? input.cardViewFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.35
        let damping: CGFloat = 1.0 - dampFactorInterval * (distanceToBounce / extentToBounce)
        
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce)/UIScreen.main.bounds.height)
        return (duration, damping)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let detailViewController = transitionContext.viewController(forKey: .to) as? CardDetailViewController,
            let detailView = transitionContext.view(forKey: .to) else {
                return
        }
        
        // prepare background view
        let backgroundView = UIView()
        containerView.addSubview(backgroundView)
        var backgroundVerticalConstraints = NSLayoutConstraint()
        if (isUsingFrame) {
            backgroundView.frame = CGRect(x: 0, y: input.cardViewFrame.minY, width: containerView.bounds.width,
                                          height: containerView.bounds.height)
        } else {
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundVerticalConstraints = backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                                                                    constant: input.cardViewFrame.minY)
            do {
                let backgroundConstraints = [
                    backgroundView.widthAnchor.constraint(equalToConstant: containerView.bounds.width),
                    backgroundView.heightAnchor.constraint(equalToConstant: containerView.bounds.height),
                    backgroundView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    backgroundVerticalConstraints
                ]
                NSLayoutConstraint.activate(backgroundConstraints)
            }
        }
        
        
        // prepare detail view
        backgroundView.addSubview(detailView)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        var cardWidthConstraint = NSLayoutConstraint()
        var cardHeightConstraint = NSLayoutConstraint()
        if isUsingFrame {
            detailView.frame = CGRect(x: backgroundView.frame.origin.x, y: backgroundView.frame.origin.y,
                                      width: input.cardViewFrame.width, height: input.cardViewFrame.height)
        } else {
            cardWidthConstraint = detailView.widthAnchor.constraint(equalToConstant: input.cardViewFrame.width)
            cardHeightConstraint = detailView.heightAnchor.constraint(equalToConstant: input.cardViewFrame.height)
            do {
                let cardDetailConstraints = [
                    detailView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -1),
                    detailView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                    cardWidthConstraint,
                    cardHeightConstraint
                ]
                NSLayoutConstraint.activate(cardDetailConstraints)
            }
        }
        detailView.layer.cornerRadius = Constant.cornerRadius
        
        // prepare from cell
        input.cell.isHidden = true
        input.cell.transform = .identity
        
        let topTemporaryFix = detailViewController.imageHeaderView.topAnchor.constraint(equalTo: detailViewController.imageHeaderView.topAnchor, constant: 0)
        topTemporaryFix.isActive = true
        containerView.layoutIfNeeded()
        
        // Animate container bouncing up
        func animateCardBouncingUp() {
            if isUsingFrame {
                backgroundView.frame.origin.y = 0
            } else {
                backgroundVerticalConstraints.constant = 0
                containerView.layoutIfNeeded()
            }
        }
        
        // Animate cardDetail filling up the container
        func animateCardFillingContent() {
            if isUsingFrame {
                detailView.frame = CGRect(x: 0, y: 0, width: backgroundView.bounds.width,
                                          height: backgroundView.bounds.height)
            } else {
                cardWidthConstraint.constant = backgroundView.bounds.width
                cardHeightConstraint.constant = backgroundView.bounds.height
                containerView.layoutIfNeeded()
            }
            
            detailView.layer.cornerRadius = 0
        }
        
        func animateComplete() {
            backgroundView.removeConstraints(backgroundView.constraints)
            backgroundView.removeFromSuperview()
            
            containerView.addSubview(detailView)
            
            detailView.removeConstraints([cardWidthConstraint, cardHeightConstraint])
            detailView.edges(to: containerView, top: -1)
            
            detailViewController.bottomConstraint.isActive = false
            detailViewController.tableView.isScrollEnabled = true
            
            let success = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(success)
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animationDamping,
                       initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
            animateCardBouncingUp()
            animateCardFillingContent()
        }) { _ in
            animateComplete()
        }
    }
}
