//
//  ViewController.swift
//  ListScrollView4
//
//  Created by Mac on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private let bottomSheetViewController : BottomSheetViewController = {
        if #available(iOS 11.0, *) {
            return BottomSheetViewController(type: .navigation(title: "Title"))
        } else {
            return BottomSheetViewController(type: .plain)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let bodyView = UIView()
        bodyView.backgroundColor = .lightGray
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bodyView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": bodyView]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": bodyView])
        )

        bottomSheetViewController.heights = (1 / 6, 9 / 10, 9 / 10)
        bottomSheetViewController.bottomSheetDelegate = self

        let tableView = bottomSheetViewController.tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

        addChildViewController(bottomSheetViewController)
        bottomSheetViewController.show(in: view, initial: .collapsed)
        bottomSheetViewController.didMove(toParentViewController: self)

        let item = UIBarButtonItem(title: "Expand", style: .plain, target: self, action: #selector(expand))
        bottomSheetViewController.rootViewController.navigationItem.rightBarButtonItem = item
    }

    @objc private func expand() {
        bottomSheetViewController.state = .fullyExpanded
    }
}

extension ViewController : BottomSheetViewDelegate {

    func didMove(to percentage: Float) {
        bottomSheetViewController.rootViewController.title = String(format: "didMove to %.1f", percentage)
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row + 1)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if bottomSheetViewController.isNavigationBarHidden {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let vc = UIViewController()
        let cell = tableView.cellForRow(at: indexPath)
        vc.title = cell?.textLabel?.text
        vc.view.backgroundColor = .white
        bottomSheetViewController.show(vc, sender: self)
    }

//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        scrollView.setContentOffset(CGPoint.zero, animated: false)
//    }
}
