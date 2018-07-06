//
//  DrawerView.swift
//  ListScrollView4
//
//  Created by denkeni on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit

public enum DrawerViewControllerType {
    case plain

    @available(iOS 11.0, *)
    case navigation(title: String?)
}

public enum DrawerViewState {
    case collapsed, partiallyExpanded, fullyExpanded
}

public protocol DrawerViewDelegate {
    /// - parameter percentage: 0..1 where collapsed..fullyExpanded
    func didMove(to percentage: Float)
}

public final class DrawerViewController : UINavigationController {

    /// Set dataSource and delegate
    public var tableView : UITableView {
        return rootViewController.tableView
    }
    public let rootViewController = DrawerRootViewController()

    public var state : DrawerViewState = .collapsed {
        didSet {
            let scrollView = (topViewController?.view as? UIScrollView)
            scrollView?.decelerationRate = UIScrollViewDecelerationRateFast
            bottomConstraint.constant = constant(of: state)
            drawerDelegate?.didMove(to: 1 - Float(constant(of: state) / constant(of: .collapsed)))
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.view.superview?.layoutIfNeeded()
            }) { (isFinished) in
                scrollView?.decelerationRate = UIScrollViewDecelerationRateNormal
            }
        }
    }
    /// of parentView (collapsed, partiallyExpanded, fullyExpanded)
    public var heightRatios : (Float, Float, Float) = (1 / 6, 4 / 10, 9 / 10)
    public var drawerDelegate : DrawerViewDelegate? = nil

    private lazy var size : CGSize = {
        guard let superview = view.superview else { return CGSize.zero }
        return superview.bounds.size
    }()
    private var bottomConstraint : NSLayoutConstraint!
    private var heightConstraint : NSLayoutConstraint!
    private var lastTranslation = CGPoint.zero

    public init(type: DrawerViewControllerType) {
        super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)

        switch type {
        case .plain:
            isNavigationBarHidden = true
        case .navigation(let title):
            rootViewController.title = title
        }

        viewControllers = [rootViewController]
        if let navigationBar = navigationBar as? NavigationBar {
            navigationBar.navigationController = self
            navigationBar.type = type
        }
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // will use auto layout
    public func show(in parentView: UIView, initial state: DrawerViewState) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)

        let initialConstant = constant(of: state)
        bottomConstraint = view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: initialConstant)
        let fullHeight = height(of: .fullyExpanded)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: fullHeight)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": view]) +
            [bottomConstraint, heightConstraint]
        )
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }

    public func height(of state: DrawerViewState) -> CGFloat {
        switch state {
        case .collapsed:
            return size.height * CGFloat(heightRatios.0)
        case .partiallyExpanded:
            return size.height * CGFloat(heightRatios.1)
        case .fullyExpanded:
            return size.height * CGFloat(heightRatios.2)
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

        let topOffset = isNavigationBarHidden ? 0 : navigationBar.frame.height
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
            self.state = state
        default:
            if newConstant <= 0 {
                bottomConstraint.constant = 0
                drawerDelegate?.didMove(to: 1)
            } else {
                bottomConstraint.constant = newConstant
                drawerDelegate?.didMove(to: 1 - Float(newConstant / constant(of: .collapsed)))
            }
        }
        lastTranslation = translation
    }
}

extension DrawerViewController {

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.size = size
        let fullHeight = height(of: .fullyExpanded)
        heightConstraint.constant = fullHeight
        let state = self.state
        self.state = state  // update bottomConstraint
    }
}

extension DrawerViewController : UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: -

private final class NavigationBar : UINavigationBar {

    var navigationController : UINavigationController? = nil
    var type : DrawerViewControllerType = .plain

    // More ref: https://stackoverflow.com/a/9719364
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        switch type {
        case .plain:
            return view
        case .navigation(title: _):
            if view is UIControl {
                // Ex. UIBarButtonItem, presented as _UIButtonBarButton #available(iOS 11.0) or UINavigationButton on iOS 10
                // Known issue: Custom UI elements (on the tableHeaderView) are unresponsive
                // Known issue: On iOS 10, back button is unresponsive
                return view
            }
            return navigationController?.topViewController?.view
        }
    }
}

public final class DrawerRootViewController : UIViewController {

    public let tableView = UITableView()
    private var isFirstTimeAppear = true

    override public func loadView() {
        view = tableView
    }

    override public func viewDidLoad() {
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

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // like clearsSelectionOnViewWillAppear
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }

        // workaround to fix weird initial offset of tableView, on iOS 11 and not started at .fullyExpanded
        if isFirstTimeAppear, let nav = navigationController {
            let topOffset = nav.isNavigationBarHidden ? 0 : nav.navigationBar.frame.height
            tableView.setContentOffset(CGPoint(x: 0, y: -topOffset), animated: false)
            isFirstTimeAppear = false
        }

    }
}
