//
//  ViewController.swift
//  Demo
//
//  Created by can.khac.nguyen on 7/31/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let arrImage: [UIImage] = [#imageLiteral(resourceName: "Desk_Left_1"), #imageLiteral(resourceName: "Desk_right_1"), #imageLiteral(resourceName: "Desk_Left"), #imageLiteral(resourceName: "Desk_right")]
    var selectedCellFrame: CGRect = .zero
    var selectedCell: UITableViewCell = UITableViewCell()

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    func configView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.hideEmptyCells()
        tableView.register(nibWithCellClass: CardTableViewCell.self)
        tableView.delaysContentTouches = false
    }

    func frameOfViewInWindowsCoordinateSystem(_ view: UIView) -> CGRect {
        if let superview = view.superview {
            return superview.convert(view.frame, to: nil)
        }
        print("[ANIMATION WARNING] Seems like this view is not in views hierarchy\n\(view)\nOriginal frame returned")
        return view.frame
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CardTableViewCell.self)
        cell.selectionStyle = .none
        cell.configCell(title: "Title \(indexPath.row)", description: "My hero acamdemia")
        cell.contentImageView.image = arrImage[indexPath.row % 4]
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CardTableViewCell else {
            return
        }
        cell.layoutIfNeeded()
        cell.prepareForDisplay()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? CardTableViewCell else { return }
        cell.freezeAnimations()
        cell.shadowView.layoutIfNeeded()
        selectedCellFrame = frameOfViewInWindowsCoordinateSystem(cell.shadowView)
        selectedCell = cell
        vc.image = arrImage[indexPath.row]
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        present(vc, animated: true) {
            cell.unfreezeAnimations()
        }
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardViewPresentation(input: CardViewTransitionInput(cardViewFrame: selectedCellFrame, cell: selectedCell))
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardViewDismissal(input: CardViewTransitionInput(cardViewFrame: selectedCellFrame, cell: selectedCell))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
