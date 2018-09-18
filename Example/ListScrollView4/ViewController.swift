//
//  ViewController.swift
//  ListScrollView4
//
//  MIT License
//  Copyright (c) 2018 Denken Chen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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

        view.backgroundColor = .lightGray

        // If you would like to set only 2 height states, uncomment below
//        bottomSheetViewController.heights = (1 / 6, 9 / 10, 9 / 10)
        bottomSheetViewController.bottomSheetDelegate = self

        let tableView = bottomSheetViewController.tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

        addChild(bottomSheetViewController)
        bottomSheetViewController.show(in: view, initial: .collapsed)
        bottomSheetViewController.didMove(toParent: self)

        let item = UIBarButtonItem(title: "Expand", style: .plain, target: self, action: #selector(expand))
        bottomSheetViewController.rootViewController.navigationItem.rightBarButtonItem = item

        let bottomSheetView = bottomSheetViewController.view
        bottomSheetView?.layer.shadowColor = UIColor.black.cgColor
        bottomSheetView?.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        bottomSheetView?.layer.shadowRadius = 5
        bottomSheetView?.layer.shadowOpacity = 0.5
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
