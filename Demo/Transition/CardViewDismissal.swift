//
//  CardViewDismissTransition.swift
//  Demo
//
//  Created by Can Khac Nguyen on 8/5/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit

final class CardViewDismissal: NSObject, UIViewControllerAnimatedTransitioning {
    
    let input: CardViewTransitionInput
    
    init(input: CardViewTransitionInput) {
        self.input = input
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let cardDetailVC = transitionContext.viewController(forKey: .from) as? CardDetailViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? ViewController,
            let cardDetailView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(true)
                return
        }
        
        let backgroundView = UIView()
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        cardDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.removeConstraints(containerView.constraints)
        
        containerView.addSubview(backgroundView)
        backgroundView.addSubview(cardDetailView)
        
        // Card fills inside animated container view
        cardDetailView.edges(to: backgroundView)
        
        backgroundView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        let backgroundTopConstraint = backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0)
        let backgroundWidthConstraint = backgroundView.widthAnchor.constraint(equalToConstant: cardDetailView.frame.width)
        let backgroundHeightConstraint = backgroundView.heightAnchor.constraint(equalToConstant: cardDetailView.frame.height)
        
        NSLayoutConstraint.activate([backgroundTopConstraint, backgroundWidthConstraint, backgroundHeightConstraint])
        
        // Fix weird top inset
        let topTemporaryFix = cardDetailVC.imageHeaderView.topAnchor.constraint(equalTo: cardDetailView.topAnchor)
        topTemporaryFix.isActive = true
        
        containerView.layoutIfNeeded()
        
        // Force card filling bottom
        let stretchCardToFillBottom = cardDetailVC.imageHeaderView.bottomAnchor.constraint(equalTo: cardDetailView.bottomAnchor)
        
        func animateCardViewBackToPlace() {
            stretchCardToFillBottom.isActive = true
            // Back to identity
            // NOTE: Animated container view in a way, helps us to not messing up `transform` with `AutoLayout` animation.
            cardDetailView.transform = CGAffineTransform.identity
            backgroundTopConstraint.constant = self.input.cardViewFrame.minY
            backgroundWidthConstraint.constant = self.input.cardViewFrame.width
            backgroundHeightConstraint.constant = self.input.cardViewFrame.height
            containerView.layoutIfNeeded()
        }
        
        func completeEverything() {
            let success = !transitionContext.transitionWasCancelled
            backgroundView.removeConstraints(backgroundView.constraints)
            backgroundView.removeFromSuperview()
            if success {
                cardDetailView.removeFromSuperview()
                input.cell.isHidden = false
            } else {
                // Remove temporary fixes if not success!
                topTemporaryFix.isActive = false
                stretchCardToFillBottom.isActive = false
                
                cardDetailView.removeConstraint(topTemporaryFix)
                cardDetailView.removeConstraint(stretchCardToFillBottom)
                
                containerView.removeConstraints(containerView.constraints)
                
                containerView.addSubview(cardDetailView)
                cardDetailView.edges(to: containerView)
            }
            transitionContext.completeTransition(success)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            animateCardViewBackToPlace()
        }) { (finished) in
            completeEverything()
        }
    }
}
    

