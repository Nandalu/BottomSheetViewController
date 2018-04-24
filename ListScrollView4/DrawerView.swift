//
//  DrawerView.swift
//  ListScrollView4
//
//  Created by Mac on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit

enum DrawerViewState {
    case collapsed, partiallyExpanded, fullyExpanded
}

final class DrawerView: UIView {

    /// You have to specify table view dataSource and delegate
    let tableView = UITableView()
    var state : DrawerViewState = .collapsed

    private var bottomConstraint : NSLayoutConstraint!
    private var lastTranslation = CGPoint.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": tableView]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": tableView])
        )

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        addGestureRecognizer(pan)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // will use auto layout
    func show(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        let collapsedConstant = height(of: .fullyExpanded) - height(of: .collapsed)
        let fullHeight = height(of: .fullyExpanded)
        bottomConstraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: collapsedConstant)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": self]) +
            [heightAnchor.constraint(equalToConstant: fullHeight),
                 bottomConstraint]
        )
    }

    private func height(of state: DrawerViewState) -> CGFloat {
        guard let superview = superview else { return 0 }
        switch state {
        case .collapsed:
            return superview.bounds.height * (1 / 6)
        case .partiallyExpanded:
            return superview.bounds.height * (4 / 10)
        case .fullyExpanded:
            return superview.bounds.height * (9 / 10)
        }
    }

    private func constant(of state: DrawerViewState) -> CGFloat {
        switch state {
        case .collapsed:
            return height(of: .fullyExpanded) - height(of: .collapsed)
        case .partiallyExpanded:
            return height(of: .fullyExpanded) - height(of: .partiallyExpanded)
        case .fullyExpanded:
            return 0
        }
    }

    @objc private func didPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        sender.setTranslation(CGPoint.zero, in: superview)

        let tableViewDidReachTop = tableView.contentOffset.y <= 6   // 6: tolerance for tableView.setContentOffset(CGPoint.zero, animated: false)
        let drawerViewDidReachBottom = (bottomConstraint.constant == 0)
        let isScrollingDown = translation.y > 0
        let isScrollingUp = translation.y < 0

        // Boundary conditions
        // Magic. Don't touch.
        if isScrollingDown && !tableViewDidReachTop {
            tableView.showsVerticalScrollIndicator = true
            return
        }
        if (isScrollingUp && !drawerViewDidReachBottom) ||
            (isScrollingDown && tableViewDidReachTop) {
            tableView.setContentOffset(CGPoint.zero, animated: false)   // looks like tableView scrolling disabled
            tableView.showsVerticalScrollIndicator = false
        }
        if isScrollingUp && drawerViewDidReachBottom {
            tableView.showsVerticalScrollIndicator = true
        }
        // Move the drawerView
        let newValue = bottomConstraint.constant + 1.5 * translation.y
        var newConstant = newValue
        switch sender.state {
        case .ended:    // for .ended, translation will be CGPoint.zero
            let isScrollingDown = lastTranslation.y > 0
            let isScrollingUp = lastTranslation.y < 0
            switch newValue {
            case constant(of: .fullyExpanded) ..< constant(of: .partiallyExpanded):
                if isScrollingUp {
                    newConstant = constant(of: .fullyExpanded)
                } else if isScrollingDown {
                    newConstant = constant(of: .partiallyExpanded)
                } else {
                    if newValue > (constant(of: .partiallyExpanded) + constant(of: .fullyExpanded) ) / 2 {
                        newConstant = constant(of: .partiallyExpanded)
                    } else {
                        newConstant = constant(of: .fullyExpanded)
                    }
                }
            case constant(of: .partiallyExpanded) ..< constant(of: .collapsed):
                if isScrollingUp {
                    newConstant = constant(of: .partiallyExpanded)
                } else if isScrollingDown {
                    newConstant = constant(of: .collapsed)
                } else {
                    if newValue > (constant(of: .partiallyExpanded) + constant(of: .collapsed) ) / 2 {
                        newConstant = constant(of: .collapsed)
                    } else {
                        newConstant = constant(of: .partiallyExpanded)
                    }
                }
            default:
                newConstant = constant(of: .collapsed)
            }
            bottomConstraint.constant = newConstant
            UIView.animate(withDuration: 0.2) {
                self.superview?.layoutIfNeeded()
            }
        default:
            if newValue <= 0 {
                newConstant = 0
            }
            bottomConstraint.constant = newConstant
        }
        lastTranslation = translation
    }
}

extension DrawerView : UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
