//
//  ViewController.swift
//  ListScrollView4
//
//  Created by Mac on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit
import MapKit

final class ViewController: UIViewController {

    private let mapView = MKMapView()
    private let drawerView = UIView()
    private let tableView = UITableView()
    private var bottomConstraint : NSLayoutConstraint!
    private let drawerViewHeight : CGFloat = 300.0
    private let drawerViewHeightInitial : CGFloat = 100.0

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": mapView]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": mapView])
        )

        drawerView.backgroundColor = .white
        drawerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawerView)
        bottomConstraint = drawerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: drawerViewHeight - drawerViewHeightInitial )
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": drawerView]) +
            [drawerView.heightAnchor.constraint(equalToConstant: drawerViewHeight),
             bottomConstraint]
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        drawerView.addSubview(tableView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": tableView]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": tableView])
        )

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        drawerView.addGestureRecognizer(pan)
    }

    @objc private func didPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        sender.setTranslation(CGPoint.zero, in: self.view)

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

extension ViewController : UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

extension ViewController : UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
