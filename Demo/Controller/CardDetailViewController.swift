//
//  CardDetailViewController.swift
//  Demo
//
//  Created by can.khac.nguyen on 7/31/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageHeaderView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var image: UIImage!
    var interactiveStartingPoint: CGPoint?
    var dismissalAnimator: UIViewPropertyAnimator?
    
    let imageViewHeaderHeight: CGFloat = 400
    let stretchMaxHeight: CGFloat = 550
    let targetShrinkScale: CGFloat = 0.7
    
    deinit {
        print("Card detail deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        configObserverAndGesture()
        closeButton.isHidden = true
    }

    func configView() {
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: imageViewHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        
        imageHeaderView.image = image
        imageHeaderView.contentMode = .scaleAspectFill
        imageHeaderView.clipsToBounds = true
    }
    
    func configObserverAndGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(panGesture)
        tableView.panGestureRecognizer.require(toFail: panGesture)
    }

    @IBAction func onCloseButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    
        let targetAnimatedView = gesture.view!
        let startingPoint: CGPoint
        
        if let p = interactiveStartingPoint {
            startingPoint = p
        } else {
            // Initial location
            startingPoint = gesture.location(in: nil)
            interactiveStartingPoint = startingPoint
        }
        
        let currentLocation = gesture.location(in: nil)
        let progress = (currentLocation.y - startingPoint.y) / 100
        let targetCornerRadius: CGFloat = Constant.cornerRadius
        
        func createInteractiveDismissalAnimatorIfNeeded() -> UIViewPropertyAnimator {
            if let animator = dismissalAnimator {
                return animator
            } else {
                let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: { [unowned self] in
                    targetAnimatedView.transform = .init(scaleX: self.targetShrinkScale, y: self.targetShrinkScale)
                    targetAnimatedView.layer.cornerRadius = targetCornerRadius
                    targetAnimatedView.layer.masksToBounds = true
                })
                animator.isReversed = false
                animator.pauseAnimation()
                animator.fractionComplete = progress
                return animator
            }
        }
        
        switch gesture.state {
        case .began:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
        case .changed:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
            
            let actualProgress = progress
            let isDismissalSuccess = actualProgress >= 1.0
            
            dismissalAnimator!.fractionComplete = actualProgress
            
            if isDismissalSuccess {
                dismissalAnimator!.stopAnimation(false)
                dismissalAnimator!.addCompletion { [weak self] (pos) in
                    switch pos {
                    case .end:
                        self?.dismiss(animated: true)
                        print("-_-")
                    default:
                        fatalError("Must finish dismissal at end!")
                    }
                }
                dismissalAnimator!.finishAnimation(at: .end)
            }
            
        case .ended, .cancelled:
            if dismissalAnimator == nil {
                // Gesture's too quick that it doesn't have dismissalAnimator!
                print("Too quick there's no animator!")
                interactiveStartingPoint = nil
                dismissalAnimator = nil
                return
            }
            
            // Ended, Animate back to start
            dismissalAnimator!.pauseAnimation()
            dismissalAnimator!.isReversed = true
            
            // Disable gesture until reverse closing animation finishes.
            gesture.isEnabled = false
            dismissalAnimator!.addCompletion { [weak self] _ in
                self?.interactiveStartingPoint = nil
                self?.dismissalAnimator = nil
                gesture.isEnabled = true
            }
            dismissalAnimator!.startAnimation()
        default:
            fatalError("Impossible gesture state? \(gesture.state.rawValue)")
        }
    }
}

extension CardDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Index \(indexPath.row)"
        return cell
    }
}

extension CardDetailViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = imageViewHeaderHeight - (scrollView.contentOffset.y + imageViewHeaderHeight)
        let height = min(max(y, 60), stretchMaxHeight)
        imageHeaderView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
    }
}
