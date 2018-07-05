//
//  ViewController.swift
//  ListScrollView4
//
//  Created by Mac on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private let drawerNavigationController = DrawerViewController(type: .tableView)

    override func viewDidLoad() {
        super.viewDidLoad()

        let topView = UIView()
        topView.backgroundColor = .lightGray
        topView.translatesAutoresizingMaskIntoConstraints = false
        let bottomView = UIView()
        bottomView.backgroundColor = .purple
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        let viewsDict = ["topView": topView, "bottomView": bottomView]
        view.addSubview(topView)
        view.addSubview(bottomView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[topView]|", options: [], metrics: nil, views: viewsDict) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomView]|", options: [], metrics: nil, views: viewsDict) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[topView][bottomView(==topView)]|", options: [], metrics: nil, views: viewsDict)
        )

//        drawerNavigationController.heightRatios = (1 / 6, 9 / 10, 9 / 10)
        drawerNavigationController.drawerDelegate = self

        if let tableView = drawerNavigationController.rootViewController.tableView {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        }

        addChildViewController(drawerNavigationController)
        drawerNavigationController.show(in: view, initial: .collapsed)
        drawerNavigationController.didMove(toParentViewController: self)

        let item = UIBarButtonItem(title: "Expand", style: .plain, target: self, action: #selector(expand))
        drawerNavigationController.rootViewController.navigationItem.rightBarButtonItem = item
    }

    @objc private func expand() {
        drawerNavigationController.state = .fullyExpanded
    }
}

extension ViewController : DrawerViewDelegate {

    func didMove(to percentage: Float) {
        drawerNavigationController.rootViewController.title = String(format: "didMove to %.1f", percentage)
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
