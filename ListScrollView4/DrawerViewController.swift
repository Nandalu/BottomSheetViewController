//
//  DrawerView.swift
//  ListScrollView4
//
//  Created by denkeni on 2018/4/24.
//  Copyright © 2018 Nandalu. All rights reserved.
//

import UIKit

public enum DrawerViewControllerType {
    /// Use rootViewController.view; no navigation bar.
    case plain
    /// Use rootViewController.view; no navigation bar.
    case blur(style: UIBlurEffectStyle)
    /// Set dataSource and delegate of rootViewController.tableView; with navigation bar.
    case tableView
}

public enum DrawerViewState {
    case collapsed, partiallyExpanded, fullyExpanded
}

public protocol DrawerViewDelegate {
    /// - parameter percentage: 0..1 where collapsed..fullyExpanded
    func didMove(to percentage: Float)
}

public final class DrawerViewController : UINavigationController {

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

    private var bottomConstraint : NSLayoutConstraint!
    private var lastTranslation = CGPoint.zero

    public init(type: DrawerViewControllerType) {
        super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)

        switch type {
        case .plain, .blur:
            isNavigationBarHidden = true
        case .tableView:
            isNavigationBarHidden = false
        }

        rootViewController.type = type
        viewControllers = [rootViewController]
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

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // will use auto layout
    public func show(in parentView: UIView, initial state: DrawerViewState) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)

        let initialConstant = constant(of: state)
        let fullHeight = height(of: .fullyExpanded)
        bottomConstraint = view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: initialConstant)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": view]) +
            [view.heightAnchor.constraint(equalToConstant: fullHeight),
                 bottomConstraint]
        )
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }

    private func height(of state: DrawerViewState) -> CGFloat {
        guard let superview = view.superview else { return 0 }
        switch state {
        case .collapsed:
            return superview.bounds.height * CGFloat(heightRatios.0)
        case .partiallyExpanded:
            return superview.bounds.height * CGFloat(heightRatios.1)
        case .fullyExpanded:
            return superview.bounds.height * CGFloat(heightRatios.2)
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

extension DrawerViewController : UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private final class NavigationBar : UINavigationBar {

    var navigationController : UINavigationController? = nil

    // More ref: https://stackoverflow.com/a/9719364
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view is UIControl {
            // Ex. UIBarButtonItem, presented as _UIButtonBarButton #available(iOS 11.0) or UINavigationButton on iOS 10
            return view
        }
        return navigationController?.topViewController?.view
    }
}

public final class DrawerRootViewController : UIViewController {

    public private(set) lazy var tableView : UITableView? = {
        switch type {
        case .plain, .blur:
            return nil
        case .tableView:
            return UITableView()
        }
    }()
    fileprivate var type : DrawerViewControllerType = .plain
    private var isFirstTimeAppear = true

    override public func loadView() {
        switch type {
        case .plain:
            let view = UIView()
            view.backgroundColor = .white
            self.view = view
        case .blur(style: let style):
            let effect = UIBlurEffect(style: style)
            let view = UIVisualEffectView(effect: effect)
            self.view = view
        case .tableView:
            view = tableView
        }
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
        if let selectedRow = tableView?.indexPathForSelectedRow {
            tableView?.deselectRow(at: selectedRow, animated: true)
        }

        // workaround to fix weird initial offset of tableView, on iOS 11 and not started at .fullyExpanded
        if isFirstTimeAppear, let nav = navigationController {
            let topOffset = nav.isNavigationBarHidden ? 0 : nav.navigationBar.frame.height
            tableView?.setContentOffset(CGPoint(x: 0, y: -topOffset), animated: false)
            isFirstTimeAppear = false
        }
    }
}
