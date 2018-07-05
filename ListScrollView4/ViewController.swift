//
//  ViewController.swift
//  ListScrollView4
//
//  Created by Mac on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private let drawerNavigationController = DrawerViewController(type: .navigation(title: "Title"))

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

        let tableView = drawerNavigationController.tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

        addChildViewController(drawerNavigationController)
        drawerNavigationController.show(in: view)
        drawerNavigationController.didMove(toParentViewController: self)
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
        if drawerNavigationController.isNavigationBarHidden {
            return
        }
        let vc = UIViewController()
        let cell = tableView.cellForRow(at: indexPath)
        vc.title = cell?.textLabel?.text
        vc.view.backgroundColor = .white
        drawerNavigationController.show(vc, sender: self)
    }

//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        scrollView.setContentOffset(CGPoint.zero, animated: false)
//    }
}
