//
//  DrawerView.swift
//  ListScrollView4
//
//  Created by Mac on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit

final class DrawerView: UIView {

    /// You have to specify table view dataSource and delegate
    let tableView = UITableView()

    private var bottomConstraint : NSLayoutConstraint!
    private let drawerViewHeight : CGFloat = 300.0
    private let drawerViewHeightInitial : CGFloat = 100.0

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
        bottomConstraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: drawerViewHeight - drawerViewHeightInitial)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": self]) +
                [heightAnchor.constraint(equalToConstant: drawerViewHeight),
                 bottomConstraint]
        )
    }

    @objc private func didPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        sender.setTranslation(CGPoint.zero, in: superview)

        let tableViewDidReachTop = tableView.contentOffset.y <= 0
        let drawerViewDidReachBottom = (bottomConstraint.constant == 0)
        let isScrollingDown = translation.y > 0
        let isScrollingUp = translation.y < 0

        // Boundary conditions
        if isScrollingDown && !tableViewDidReachTop {
            return
        }
        if (isScrollingUp && !drawerViewDidReachBottom) ||
            (isScrollingDown && tableViewDidReachTop) {
            tableView.setContentOffset(CGPoint.zero, animated: false)
            tableView.showsVerticalScrollIndicator = false
        }
        // Move the drawerView
        let newValue = self.bottomConstraint.constant + 1.5 * translation.y
        var newConstant = newValue
        if newValue >= self.drawerViewHeight - self.drawerViewHeightInitial {
            newConstant = self.drawerViewHeight - self.drawerViewHeightInitial
        } else if newValue <= 0 {
            newConstant = 0
        }
        self.bottomConstraint.constant = newConstant
    }
}

extension DrawerView : UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
