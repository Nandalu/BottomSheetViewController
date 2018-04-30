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

final class DrawerNavigationController : UINavigationController {

    /// You should set dataSource and delegate
    var tableView : UITableView {
        return drawerViewController.tableView
    }
    var state : DrawerViewState = .collapsed

    private let drawerViewController = DrawerViewController()
    private var bottomConstraint : NSLayoutConstraint!
    private var lastTranslation = CGPoint.zero

    init(title: String?) {
        super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        drawerViewController.title = title
        viewControllers = [drawerViewController]
        if let navigationBar = navigationBar as? NavigationBar {
            navigationBar.navigationController = self
        }
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // will use auto layout
    func show(in parentView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)

        let initialConstant = constant(of: .partiallyExpanded)
        let fullHeight = height(of: .fullyExpanded)
        bottomConstraint = view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: initialConstant)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": view]) +
            [view.heightAnchor.constraint(equalToConstant: fullHeight),
                 bottomConstraint]
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }

    private func height(of state: DrawerViewState) -> CGFloat {
        guard let superview = view.superview else { return 0 }
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
        let superview = view.superview
        let scrollView = (topViewController?.view as? UIScrollView)
        let translation = sender.translation(in: superview)
        sender.setTranslation(CGPoint.zero, in: superview)

        let topOffset = navigationBar.frame.height
        let scrollViewDidReachTop : Bool = {
            if let scrollView = scrollView {
                return scrollView.contentOffset.y <= -topOffset
            }
            return true
        }()
        let drawerViewDidReachBottom = (bottomConstraint.constant == 0)
        let isScrollingDown = translation.y > 0
        let isScrollingUp = translation.y < 0

        // Boundary conditions
        // Magic. Don't touch.
        if isScrollingDown && !scrollViewDidReachTop {
            scrollView?.showsVerticalScrollIndicator = true
            return
        }
        if (isScrollingUp && !drawerViewDidReachBottom) ||
            (isScrollingDown && scrollViewDidReachTop) {
            scrollView?.setContentOffset(CGPoint(x: 0, y: -topOffset), animated: false)   // looks like tableView scrolling disabled
            scrollView?.showsVerticalScrollIndicator = false
        }
        if isScrollingUp && drawerViewDidReachBottom {
            scrollView?.showsVerticalScrollIndicator = true
        }
        // Move the drawerView
        let newConstant = bottomConstraint.constant + translation.y
        switch sender.state {
        case .ended:
            if drawerViewDidReachBottom {
                return  // avoid seeing animation of decelerationRate change
            }
            // For .ended gesture, translation will be CGPoint.zero
            // so we need to take the lastTranslation
            let isScrollingDown = lastTranslation.y > 0
            let isScrollingUp = lastTranslation.y < 0
            let state : DrawerViewState
            switch newConstant {
            case constant(of: .fullyExpanded) ..< constant(of: .partiallyExpanded):
                if isScrollingUp {
                    state = .fullyExpanded
                } else if isScrollingDown {
                    state = .partiallyExpanded
                } else {
                    if newConstant > (constant(of: .partiallyExpanded) + constant(of: .fullyExpanded) ) / 2 {
                        state = .partiallyExpanded
                    } else {
                        state = .fullyExpanded
                    }
                }
            case constant(of: .partiallyExpanded) ..< constant(of: .collapsed):
                if isScrollingUp {
                    state = .partiallyExpanded
                } else if isScrollingDown {
                    state = .collapsed
                } else {
                    if newConstant > (constant(of: .partiallyExpanded) + constant(of: .collapsed) ) / 2 {
                        state = .collapsed
                    } else {
                        state = .partiallyExpanded
                    }
                }
            default:
                state = .collapsed
            }
            scrollView?.decelerationRate = UIScrollViewDecelerationRateFast
            self.state = state
            bottomConstraint.constant = constant(of: state)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.view.superview?.layoutIfNeeded()
            }) { (isFinished) in
                scrollView?.decelerationRate = UIScrollViewDecelerationRateNormal
            }
        default:
            if newConstant <= 0 {
                bottomConstraint.constant = 0
            } else {
                bottomConstraint.constant = newConstant
            }
        }
        lastTranslation = translation
    }
}

extension DrawerNavigationController : UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private final class NavigationBar : UINavigationBar {

    var navigationController : UINavigationController? = nil

    // More ref: https://stackoverflow.com/a/9719364
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view is UIControl {  // like UIBarButtonItem, presented as _UIButtonBarButton #available(iOS 11.0) {
            return view
        }
        return navigationController?.topViewController?.view
    }
}

private final class DrawerViewController : UIViewController {

    let tableView = UITableView()
    private var isFirstTimeAppear = true

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationController?.navigationBar.isUserInteractionEnabled = false    // easiest way to make navigationBar pannable, requiring navigationBar overlays tableView

        // Any of two lines below breaks above code, easiest way to make navigationBar pannable.
//        navigationController?.navigationBar.isTranslucent = false   // fix weird initial offset of tableView
//        edgesForExtendedLayout = []     // fix weird initial offset of tableView while keeping translucent navigationBar

        // No need to declare default value
        // reflect the we've `let topOffset = navigationBar.frame.height`
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .always
//        } else {
//            automaticallyAdjustsScrollViewInsets = true
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // like clearsSelectionOnViewWillAppear
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }

        // workaround to fix weird initial offset of tableView, on iOS 11 and not started at .fullyExpanded
        if isFirstTimeAppear, let navBarHeight = navigationController?.navigationBar.frame.height {
            tableView.setContentOffset(CGPoint(x: 0, y: -navBarHeight), animated: false)
            isFirstTimeAppear = false
        }

    }
}
